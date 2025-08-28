import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/data/models/user_model.dart';
import 'package:hybrid_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:hybrid_erp_app/features/dashboard/view_models/main_view_model.dart';
import 'package:hybrid_erp_app/features/notifications/notification_list_screen.dart';

import 'package:webview_flutter/webview_flutter.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final MainViewModel _viewModel;
  late final WebViewController _controller;
  bool _isLoading = true;
  String homeUrl = '';
  @override
  void initState() {
    super.initState();
    _initializeWebView();
    setState(() {
      _isLoading = true;
    });
    _viewModel = MainViewModel();
    Future.wait([_viewModel.initialize(widget.user)]).then((value) {
      homeUrl = 'https://${widget.user.erpUrl}/Home';
      _controller
          .loadRequest(Uri.parse(_viewModel.currentUrl ?? homeUrl))
          .catchError((error) {
            _isLoading = false;
            setState(() {});
          });
    });

    setState(() {
      _isLoading = false;
    });
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
            if (![
              '.doc',
              '.docx',
              '.pdf',
              '.xls',
              '.xlsx',
              '.ppt',
              '.pptx',
            ].contains(request.url)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            if (url.contains('Account/LogOff')) {
              _viewModel.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            }

            setState(() {
              _viewModel.currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _viewModel.currentUrl = url;
            });
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Có lỗi xảy ra: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      );
  }

  void _onBackPressed() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      // If can't go back, show confirmation dialog
      if (mounted) {
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
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    exit(0);
                    // _viewModel.signOut();
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(builder: (context) => SignInPage()),
                    // );
                  },
                  child: const Text(
                    'Thoát',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),

          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back_ios),
            label: 'Quay lại',
          ),
        ],
      ),
    );
  }
}
