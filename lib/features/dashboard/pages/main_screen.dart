import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hybrid_erp_app/data/services/file_download_service.dart';
import 'package:hybrid_erp_app/di/di.dart';

import 'package:hybrid_erp_app/features/dashboard/view_models/main_view_model.dart';
import 'package:hybrid_erp_app/features/document/pages/document_preview_screen.dart';
import 'package:hybrid_erp_app/shared/helpers/network_helper.dart';
import 'package:hybrid_erp_app/shared/helpers/url_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/webview_config.dart';
import '../constants/main_screen_constants.dart';
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
  late final MainViewModel _viewModel = getIt<MainViewModel>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? timeLastPaused;
  bool _isLoading = true;
  String? initialUrl;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        if (message.data['open_url'] == "true") {
          if (message.data['url'] != null && message.data['url']!.isNotEmpty) {
            setState(() {
              initialUrl = message.data['url']!;
            });
            await _viewModel.initialize(message.data['url']);
          }
        }
      } else {
        setState(() {
          initialUrl = widget.initialUrl;
        });
        await _viewModel.initialize(initialUrl);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> handleUrl(String url) async {
    final hasConnection = await NetworkHelper.instance.canReachUrl(url);
    if (!hasConnection) {
      if (mounted) {
        NetworkHelper.showNoConnectionSnackBar(context);
      }
      return true;
    }

    if (!MainScreenConstants.authRedirectPaths.any(
      (path) => Uri.parse(url).path == path,
    )) {
      _viewModel.lastNonAuthNavigatingUrl = url;
    }

    if (UrlHelper.isPreviewFile(url)) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DocumentPreviewScreen(url: url),
          ),
        );
      }
      return true;
    } else if (UrlHelper.isDownloadFile(url)) {
      if (mounted) {
        await FileDownloadService.downloadFile(
          url: url,
          fileName: FileDownloadService.extractFileName(url),
          context: context,
        );
      }
      return true;
    } else if (UrlHelper.isExternalUrl(url, _viewModel.erpUrl ?? '')) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return true;
    } else if (MainScreenConstants.authRedirectPaths.any(
      (path) => Uri.parse(url).path == path,
    )) {
      await _viewModel.handleAuthRedirect(url);
      return true;
    }
    return false;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (timeLastPaused != null) {
          final duration = DateTime.now().difference(timeLastPaused!);
          if (duration.inMinutes > 15) {
            await _viewModel.webViewController?.reload();
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: WBottomNavBar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildWebView(),
            if (_isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.2),
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the InAppWebView
  Widget _buildWebView() {
    return InAppWebView(
      initialSettings: WebViewConfig.defaultSettings,
      onWebViewCreated: (controller) {
        _viewModel.webViewController = controller;
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
        final url = createWindowAction.request.url;

        if (url != null) {
          if (await handleUrl(url.toString())) {
            return false;
          }
          _viewModel.webViewController?.loadUrl(
            urlRequest: URLRequest(url: url),
          );
          return true;
        }
        return false;
      },

      onLoadStop: (controller, url) {
        setState(() {
          _isLoading = false;
        });
      },
      onLoadStart: (controller, url) {
        setState(() {
          _isLoading = true;
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        setState(() {
          _isLoading = true;
        });
        if (await handleUrl(navigationAction.request.url?.toString() ?? '')) {
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
