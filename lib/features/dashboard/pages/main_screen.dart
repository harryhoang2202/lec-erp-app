import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hybrid_erp_app/data/services/file_download_service.dart';

import 'package:hybrid_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:hybrid_erp_app/features/document/pages/document_preview_screen.dart';
import 'package:hybrid_erp_app/features/dashboard/view_models/main_view_model.dart';
import 'package:hybrid_erp_app/features/dashboard/constants/main_screen_constants.dart';
import 'package:hybrid_erp_app/features/dashboard/widgets/exit_confirmation_dialog.dart';

import 'package:hybrid_erp_app/features/notifications/notification_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/webview_config.dart';
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

  /// Check if the URL points to a previewable file
  bool _isPreviewFile(String url) {
    return MainScreenConstants.previewFileExtensions.any(
      (extension) => url.toLowerCase().endsWith(extension),
    );
  }

  /// Check if the URL points to a downloadable file
  bool _isDownloadFile(String url) {
    return MainScreenConstants.downloadFileExtensions.any(
      (extension) => url.toLowerCase().endsWith(extension),
    );
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
      debugPrint(
        'Auth redirect detected, retrying initialization (attempt $_retryCount/${MainScreenConstants.maxRetries})',
      );

      try {
        await _retryInitialization();
      } catch (e) {
        debugPrint('Retry failed: $e');
        if (_retryCount >= MainScreenConstants.maxRetries) {
          _redirectToSignIn();
        }
      }
    } else {
      debugPrint('Max retries reached, redirecting to SignInPage');
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't reload WebView on resume to prevent file upload interruption
    // The WebView will maintain its state automatically
    debugPrint('App lifecycle changed to: $state');
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              _buildWebView(),
              Positioned(
                bottom: 16.0,
                left: 0,
                right: 0,
                child: WBottomNavBar(
                  onPressed: (index) {
                    switch (index) {
                      case 0:
                        _onHomePressed();
                        break;
                      case 1:
                        _onNotificationPressed();
                        break;
                      case 2:
                        _onBackPressed();
                        break;
                    }
                  },
                  activeIndex: MainScreenConstants.homeTabIndex,
                ),
              ),
            ],
          ),
        ),
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
      onCreateWindow: (controller, createWindowAction) async {
        debugPrint('Create window: ${createWindowAction.request.url}');
        // Handle file preview/download
        final url = createWindowAction.request.url;

        if (url != null) {
          final urlString = url.toString();
          if (_isPreviewFile(urlString)) {
            _navigateToDocumentPreview(urlString);
            return false;
          } else if (_isDownloadFile(urlString)) {
            _handleFileDownload(urlString);
            return false;
          } else if (_isAuthRedirect(urlString)) {
            _handleAuthRedirect(urlString);
            return false;
          }
        }
        return true;
      },

      onLoadStart: (controller, url) {
        debugPrint('Load started: $url');
        // Don't show loading indicator for file uploads
        if (url?.toString().contains('file://') == true) {
          return;
        }
      },
      onLoadStop: (controller, url) {
        debugPrint('Load finished: $url');
        setState(() {
          if (url != null) {
            _viewModel.currentUrl = url.toString();
          }
        });
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView error: ${error.description}');
        // Handle specific errors
        if (error.type == WebResourceErrorType.HOST_LOOKUP) {
          debugPrint('Network error - check internet connection');
        } else if (error.type == WebResourceErrorType.TIMEOUT) {
          debugPrint('Request timeout');
        }
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        debugPrint('HTTP Error ${errorResponse.statusCode}: ${request.url}');
        // Don't show error for image requests
        if (request.url.toString().contains('/LAIP/imgnv/')) {
          return;
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('Console: ${consoleMessage.message}');
      },

      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url!;

        if (![
              'http',
              'https',
              'file',
              'chrome',
              'data',
              'javascript',
              'about',
            ].contains(uri.scheme) ||
            uri.host != _viewModel.erpUrl) {
          if (await canLaunchUrl(uri)) {
            // Launch the App
            await launchUrl(uri);
            // and cancel the request
            return NavigationActionPolicy.CANCEL;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
