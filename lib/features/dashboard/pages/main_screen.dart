import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hybrid_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:hybrid_erp_app/features/document/pages/document_preview_screen.dart';
import 'package:hybrid_erp_app/features/dashboard/view_models/main_view_model.dart';
import 'package:hybrid_erp_app/features/notifications/notification_list_screen.dart';
import 'package:hybrid_erp_app/shared/dimens/app_dimen.dart';

import 'package:webview_flutter/webview_flutter.dart';

class MainScreen extends StatefulWidget {
  final String? initialUrl;
  const MainScreen({super.key, this.initialUrl});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final MainViewModel _viewModel;
  late final WebViewController _controller;
  bool _isLoading = true;
  String homeUrl = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;
  @override
  void initState() {
    super.initState();
    _initializeWebView();
    setState(() {
      _isLoading = true;
    });
    _viewModel = MainViewModel();
    Future.wait([_viewModel.initialize()]).then((value) {
      _retryCount = 0; // Reset retry counter on successful initialization
      homeUrl = 'https://${_viewModel.erpUrl}/Home';
      _controller
          .loadRequest(Uri.parse(_viewModel.currentUrl ?? homeUrl))
          .catchError((error) {
            _isLoading = false;
            setState(() {});
          });
      if (widget.initialUrl != null) {
        _controller.loadRequest(Uri.parse(widget.initialUrl!));
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  bool checkIsDocument(String url) {
    return [
      '.doc',
      '.docx',
      '.pdf',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
    ].any((e) => url.endsWith(e));
  }

  Future<void> _handleAuthRedirect(String url) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint(
        'Auth redirect detected, retrying initialization (attempt $_retryCount/$_maxRetries)',
      );

      try {
        await _viewModel.initialize();
        _retryCount = 0; // Reset retry counter on successful retry
        homeUrl = 'https://${_viewModel.erpUrl}/Home';
        await _controller.loadRequest(
          Uri.parse(_viewModel.currentUrl ?? homeUrl),
        );
      } catch (e) {
        debugPrint('Retry failed: $e');
        if (_retryCount >= _maxRetries) {
          _redirectToSignIn();
        }
      }
    } else {
      debugPrint('Max retries reached, redirecting to SignInPage');
      _redirectToSignIn();
    }
  }

  void _redirectToSignIn() {
    _viewModel.signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
  }

  Future<void> _initializeWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
          },

          onNavigationRequest: (request) {
            debugPrint('navigation request to ${request.url}');
            if (!checkIsDocument(request.url)) {
              return NavigationDecision.navigate;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DocumentPreviewScreen(url: request.url),
              ),
            );
            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            debugPrint('page started to $url');
            if (!checkIsDocument(url)) {
              if ([
                'Account/LogOff',
                'Account/LogOn',
              ].any((e) => url.contains(e))) {
                _viewModel.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              }
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DocumentPreviewScreen(url: url),
                ),
              );
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _viewModel.currentUrl = url;
            });
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
            if (checkIsDocument(change.url ?? '')) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DocumentPreviewScreen(url: change.url ?? ''),
                ),
              );
            }
          },
          onWebResourceError: (WebResourceError error) async {
            debugPrint('web resource error: ${error.description}');
            _handleAuthRedirect(error.url ?? '');
          },
        ),
      );
  }

  void _onBackPressed() async {
    if (await _controller.canGoBack()) {
      if ((await _controller.currentUrl()) == homeUrl) {
        _showBackDialog();
      } else {
        await _controller.goBack();
      }
    } else {
      // If can't go back, show confirmation dialog
      if (mounted) {
        _showBackDialog();
      }
    }
  }

  _showBackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Thoát ứng dụng',
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Bạn có chắc chắn muốn thoát khỏi ứng dụng?',
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                exit(0);
              },
              child: const Text('Thoát', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _onHomePressed() async {
    // Navigate to home URL
    if (homeUrl.isNotEmpty) {
      await _controller.loadRequest(Uri.parse(homeUrl));
    }
  }

  void _onNotificationPressed() {
    // Navigate to notification screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(child: WebViewWidget(controller: _controller)),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            _onNotificationPressed();
          } else if (index == 1) {
            _onHomePressed();
          } else if (index == 2) {
            _onBackPressed();
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 32.0.resp(small: 28),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          if (!Platform.isAndroid)
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_back_ios),
              label: '',
            ),
        ],
      ),
    );
  }
}
