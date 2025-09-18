import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hybrid_erp_app/data/services/file_download_service.dart';

import 'package:hybrid_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:hybrid_erp_app/features/document/pages/document_preview_screen.dart';
import 'package:hybrid_erp_app/features/dashboard/view_models/main_view_model.dart';
import 'package:hybrid_erp_app/features/dashboard/constants/main_screen_constants.dart';
import 'package:hybrid_erp_app/features/dashboard/widgets/exit_confirmation_dialog.dart';

import 'package:hybrid_erp_app/features/notifications/notification_list_screen.dart';
import 'package:hybrid_erp_app/shared/helpers/url_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/webview_config.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/w_bottom_nav_bar.dart';

/// Main screen that displays the ERP web application in a WebView
class MainScreen extends StatefulWidget {
  final String? initialUrl;

  const MainScreen({super.key, this.initialUrl});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // State variables
  late final MainViewModel _viewModel;
  InAppWebViewController? _webViewController;
  String _homeUrl = '';
  int _retryCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? timeLastPaused;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeComponents();
  }

  /// Initialize all components and load the initial URL
  Future<void> _initializeComponents() async {
    _viewModel = MainViewModel();
    await _initializeViewModelAndLoadUrl();
  }

  /// Initialize view model and load URL (shared logic)
  Future<void> _initializeViewModelAndLoadUrl() async {
    try {
      await _viewModel.initialize();
      _retryCount = 0; // Reset retry counter on successful initialization
      _homeUrl = 'https://${_viewModel.erpUrl}/Home';

      // Use initial URL if provided, otherwise use current URL or home URL
      final initialUrl = widget.initialUrl ?? _viewModel.currentUrl ?? _homeUrl;
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(initialUrl)),
      );
    } catch (error) {
      debugPrint('Initialization error: $error');
    }
  }

  /// Check if the URL contains authentication redirect paths
  bool _isAuthRedirect(String url) {
    return MainScreenConstants.authRedirectPaths.any(
      (path) => url.contains(path),
    );
  }

  /// Handle authentication redirect with retry logic
  Future<void> _handleAuthRedirect(String url) async {
    if (_retryCount < MainScreenConstants.maxRetries) {
      _retryCount++;

      try {
        await _retryInitialization();
      } catch (e) {
        if (_retryCount >= MainScreenConstants.maxRetries) {
          _redirectToSignIn();
        }
      }
    } else {
      _redirectToSignIn();
    }
  }

  /// Retry initialization logic (shared between initial load and auth redirect)
  Future<void> _retryInitialization() async {
    await _viewModel.initialize();
    _retryCount = 0; // Reset retry counter on successful retry
    _homeUrl = 'https://${_viewModel.erpUrl}/Home';
    await _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_viewModel.currentUrl ?? _homeUrl)),
    );
  }

  /// Redirect to sign in page
  void _redirectToSignIn() {
    _viewModel.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  /// Navigate to document preview screen
  void _navigateToDocumentPreview(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DocumentPreviewScreen(url: url)),
    );
  }

  /// Handle file download
  Future<void> _handleFileDownload(String url) async {
    final fileName = FileDownloadService.extractFileName(url);
    await FileDownloadService.downloadFile(
      url: url,
      fileName: fileName,
      context: context,
    );
  }

  /// Handle back button press
  Future<void> _onBackPressed() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;

    if (canGoBack) {
      final currentUrl = await _webViewController?.getUrl();
      if (currentUrl?.toString() == _homeUrl) {
        _showExitDialog();
      } else {
        await _webViewController?.goBack();
      }
    } else if (mounted) {
      // If can't go back, show confirmation dialog
      _showExitDialog();
    }
  }

  /// Show exit confirmation dialog
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => const ExitConfirmationDialog(),
    );
  }

  /// Show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const LogoutConfirmationDialog(),
    );
    if (result == true) {
      _redirectToSignIn();
    }
  }

  /// Open external URL
  Future<void> _openExternalUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Navigate to home URL
  Future<void> _onHomePressed() async {
    if (_homeUrl.isNotEmpty) {
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_homeUrl)),
      );
    }
  }

  /// Navigate to notification screen
  void _onNotificationPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationListScreen()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Don't reload WebView on resume to prevent file upload interruption
    // The WebView will maintain its state automatically

    switch (state) {
      case AppLifecycleState.resumed:
        if (timeLastPaused != null) {
          final duration = DateTime.now().difference(timeLastPaused!);
          if (duration.inMinutes > 15) {
            await _webViewController?.reload();
          }
        }
        break;
      case AppLifecycleState.paused:
        timeLastPaused = DateTime.now();
        break;
      case AppLifecycleState.detached:
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onBackPressed();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,

        backgroundColor: Colors.white,
        bottomNavigationBar: WBottomNavBar(
          onPressed: (index) {
            switch (index) {
              case 0:
                _showLogoutDialog();
                break;
              case 1:
                _onHomePressed();
                break;
              case 2:
                _onNotificationPressed();
                break;
              case 3:
                _onBackPressed();
                break;
            }
          },
          activeIndex: MainScreenConstants.homeTabIndex,
        ),
        body: SafeArea(child: _buildWebView()),
      ),
    );
  }

  /// Build the InAppWebView
  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_homeUrl)),
      initialSettings: WebViewConfig.defaultSettings,
      onWebViewCreated: (controller) async {
        _webViewController = controller;
      },
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onGeolocationPermissionsShowPrompt: (controller, origin) async {
        return GeolocationPermissionShowPromptResponse(
          origin: origin,
          allow: true,
          retain: true,
        );
      },

      onCreateWindow: (controller, createWindowAction) async {
        // Handle file preview/download
        final url = createWindowAction.request.url;

        if (url != null) {
          final urlString = url.toString();
          if (UrlHelper.isPreviewFile(urlString)) {
            _navigateToDocumentPreview(urlString);
            return false;
          } else if (UrlHelper.isDownloadFile(urlString)) {
            _handleFileDownload(urlString);
            return false;
          } else if (_isAuthRedirect(urlString)) {
            _handleAuthRedirect(urlString);
            return false;
          } else if (UrlHelper.isExternalUrl(
            url.toString(),
            _viewModel.erpUrl ?? '',
          )) {
            _openExternalUrl(url.toString());
            return false;
          }
        }
        return true;
      },

      onLoadStop: (controller, url) {
        setState(() {
          if (url != null) {
            _viewModel.currentUrl = url.toString();
          }
        });
      },

      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';

        // Don't show loading indicator for file uploads

        if (UrlHelper.isPreviewFile(url)) {
          _navigateToDocumentPreview(url);
          return NavigationActionPolicy.CANCEL;
        }
        if (UrlHelper.isDownloadFile(url)) {
          _handleFileDownload(url);
          return NavigationActionPolicy.CANCEL;
        }
        if (_isAuthRedirect(url)) {
          _handleAuthRedirect(url);
          return NavigationActionPolicy.CANCEL;
        }
        if (UrlHelper.isExternalUrl(url, _viewModel.erpUrl ?? '')) {
          _openExternalUrl(url);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
