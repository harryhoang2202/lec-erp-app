import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lec_erp_app/di/di.dart';
import 'package:lec_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:lec_erp_app/features/notifications/notification_list_screen.dart';

import '../view_models/main_view_model.dart';
import 'exit_confirmation_dialog.dart';
import 'logout_confirmation_dialog.dart';

class WBottomNavBar extends StatefulWidget {
  const WBottomNavBar({super.key});

  @override
  State<WBottomNavBar> createState() => _WBottomNavBarState();
}

class _WBottomNavBarState extends State<WBottomNavBar> {
  late final MainViewModel _viewModel = getIt<MainViewModel>();

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

  /// Redirect to sign in page
  void _redirectToSignIn() {
    _viewModel.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  /// Handle back button press
  Future<void> _onBackPressed() async {
    final canGoBack = await _viewModel.webViewController?.canGoBack() ?? false;
    final currentUrl = await _viewModel.webViewController?.getUrl();
    if (canGoBack) {
      if (currentUrl?.toString() == _viewModel.homeUrl) {
        _showExitDialog();
      } else {
        await _viewModel.webViewController?.goBack();
      }
    } else if (mounted) {
      if (currentUrl?.toString() != _viewModel.homeUrl) {
        _viewModel.webViewController?.loadUrl(
          urlRequest: URLRequest(url: WebUri(_viewModel.homeUrl)),
        );
      } else {
        _showExitDialog();
      }
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
    if (_viewModel.homeUrl.isNotEmpty) {
      await _viewModel.loadUrlWithNetworkCheck(_viewModel.homeUrl);
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
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                _showLogoutDialog();
              },
              child: Container(
                width: 64.0,
                height: 48,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 180 * pi / 180,
                  child: Icon(Icons.logout_outlined, size: 24.0),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _onHomePressed();
              },
              child: Container(
                width: 64.0,
                height: 48,
                alignment: Alignment.center,
                child: Icon(Icons.home, size: 24.0, color: Colors.blue),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationListScreen(),
                  ),
                );
              },
              child: Container(
                width: 64.0,
                height: 48,
                alignment: Alignment.center,
                child: Icon(Icons.notifications_outlined, size: 24.0),
              ),
            ),

            if (Platform.isIOS)
              InkWell(
                onTap: () {
                  _onBackPressed();
                },
                child: Container(
                  width: 64.0,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.black,
                    size: 24.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
