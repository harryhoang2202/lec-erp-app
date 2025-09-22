import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hybrid_erp_app/app_shell/app_shell.dart';
import 'package:hybrid_erp_app/data/models/user_model.dart';
import 'package:hybrid_erp_app/data/services/network_service.dart';
import 'package:hybrid_erp_app/features/authentication/pages/sign_in_page.dart';
import 'package:hybrid_erp_app/shared/helpers/notification_helper.dart';
import 'package:hybrid_erp_app/shared/helpers/url_helper.dart';
import 'package:hybrid_erp_app/data/services/storage_service.dart';
import 'package:hybrid_erp_app/data/services/notification_service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MainViewModel with ChangeNotifier {
  String? _fcmToken;
  bool _isLoading = false;
  String? _currentUrl;
  String? _erpUrl;
  String? get fcmToken => _fcmToken;
  bool get isLoading => _isLoading;
  String? get currentUrl => _currentUrl;
  String? get erpUrl => _erpUrl;
  String _homeUrl = '';
  String get homeUrl => _homeUrl;
  set homeUrl(String homeUrl) {
    _homeUrl = homeUrl;
    notifyListeners();
  }

  InAppWebViewController? _webViewController;
  set webViewController(InAppWebViewController? webViewController) {
    _webViewController = webViewController;
    notifyListeners();
  }

  InAppWebViewController? get webViewController => _webViewController;
  set currentUrl(String? url) {
    _currentUrl = url;
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    UserModel? user = await StorageService.getUserCredentials();
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    } else {
      try {
        _erpUrl = user.erpUrl;
        final token = await NotificationHelper.getToken();
        _fcmToken = token;
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
      final UserModel? savedUser = await StorageService.getUserCredentials();
      String loginPath = savedUser != null
          ? '/Account/LogInMobile'
          : '/Account/RegisterMobileLogIn';

      // Parse the ERP URL safely using UrlHelper
      final Uri? erpUri = UrlHelper.parseUrl(user.erpUrl);
      if (erpUri == null) {
        debugPrint('Invalid ERP URL: ${user.erpUrl}');
        _isLoading = false;
        notifyListeners();
        return;
      }

      Uri uri = Uri(
        scheme: erpUri.scheme,
        host: erpUri.host,
        path: loginPath,
        queryParameters: {
          'username': user.username,
          'password': user.password,
          'tokeID': await StorageService.getDeviceId() ?? '<tokenmachine>',
          'nameToke': Platform.isIOS ? 'IOS' : 'ANDROID',
        },
      );
      _currentUrl = uri.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    // Get current user to check remember me status
    final UserModel? currentUser = await StorageService.getUserCredentials();

    // Clear login status
    await StorageService.updateLoginStatus(false);

    // If remember me is disabled, clear all credentials and notifications
    if (currentUser != null && !currentUser.rememberMe) {
      await StorageService.clearUserCredentials();
      // Cleanup notifications for this user
      try {
        await NotificationService.instance.deleteAllNotificationsForUser(
          username: currentUser.username,
        );
        debugPrint(
          'Cleaned up notifications for user: ${currentUser.username}',
        );
      } catch (e) {
        debugPrint('Error cleaning up notifications: $e');
      }
    }

    _currentUrl = null;
    notifyListeners();
  }

  Future<void> loadUrlWithNetworkCheck(String url) async {
    // Kiểm tra kết nối mạng trước khi load URL
    final hasConnection = await NetworkService().hasConnection();
    if (!hasConnection) {
      NetworkService.showNoConnectionSnackBar(navigatorKey.currentContext!);
      redirectToSignIn();
      return;
    }

    // Kiểm tra xem có thể reach được URL không
    final canReachUrl = await NetworkService().canReachUrl(url);
    if (!canReachUrl) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối đến: $url'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Load URL nếu có kết nối
    await _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  void redirectToSignIn() {
    signOut();
    Navigator.of(navigatorKey.currentContext!).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }
}
