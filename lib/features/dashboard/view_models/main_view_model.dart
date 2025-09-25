import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hybrid_erp_app/app_shell/app_shell.dart';
import 'package:hybrid_erp_app/data/models/user_model.dart';
import 'package:hybrid_erp_app/data/services/auth_service.dart';
import 'package:hybrid_erp_app/shared/helpers/network_helper.dart';
import 'package:hybrid_erp_app/shared/helpers/url_helper.dart';
import 'package:hybrid_erp_app/data/services/storage_service.dart';
import 'package:injectable/injectable.dart';

import '../constants/main_screen_constants.dart';

@lazySingleton
class MainViewModel with ChangeNotifier {
  bool isLoading = false;
  int _retryCount = 0;
  String? erpUrl;
  String? lastNonAuthNavigatingUrl;
  String homeUrl = '';
  UserModel? currentUser;

  InAppWebViewController? _webViewController;

  InAppWebViewController? get webViewController => _webViewController;

  set webViewController(InAppWebViewController? value) {
    _webViewController = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    currentUser = await StorageService.getUserCredentials();
    if (currentUser == null) {
      isLoading = false;
      notifyListeners();
      return;
    } else {
      erpUrl = currentUser!.erpUrl;
      homeUrl = 'https://$erpUrl/Home';
      notifyListeners();
      await signIn();
      notifyListeners();
    }
  }

  // Sign in logic
  Future<bool> signIn({String? baseUrl}) async {
    String loginPath = currentUser != null
        ? '/Account/LogInMobile'
        : '/Account/RegisterMobileLogIn';

    // Parse the ERP URL safely using UrlHelper
    final Uri? erpUri = UrlHelper.parseUrl(baseUrl ?? currentUser!.erpUrl);
    if (erpUri == null) {
      debugPrint('Invalid ERP URL: ${baseUrl ?? currentUser!.erpUrl}');
      isLoading = false;
      notifyListeners();
      return false;
    }

    Uri uri = Uri(
      scheme: erpUri.scheme,
      host: erpUri.host,
      path: loginPath,
      queryParameters: {
        'username': currentUser!.username,
        'password': currentUser!.password,
        'tokeID': await StorageService.getDeviceId() ?? '<tokenmachine>',
        'nameToke': Platform.isIOS ? 'IOS' : 'ANDROID',
      },
    );
    await Future.delayed(Duration(milliseconds: 500), () async {
      await _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(uri.toString())),
      );
    });

    _retryCount = 0;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    erpUrl = null;
    homeUrl = '';
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadUrlWithNetworkCheck(String url) async {
    // Kiểm tra kết nối mạng trước khi load URL
    final hasConnection = await NetworkHelper.instance.canReachUrl(url);
    if (!hasConnection) {
      NetworkHelper.showNoConnectionSnackBar(navigatorKey.currentContext!);
      return;
    }

    // Load URL nếu có kết nối
    await _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  /// Handle authentication redirect with retry logic
  Future<void> handleAuthRedirect(String url) async {
    final Uri? targetUri = UrlHelper.parseUrl(url);
    if (targetUri == null) {
      return;
    }

    // Lấy domain/scheme từ URL auth
    final String erpUrl = Uri(
      scheme: targetUri.scheme,
      host: targetUri.host,
    ).toString();

    // Lấy thông tin user đã lưu
    if (currentUser == null) {
      return;
    }

    // Chống vòng lặp: chỉ thử lại giới hạn số lần
    if (_retryCount >= MainScreenConstants.maxRetries) {
      return;
    }
    _retryCount++;

    try {
      // Đăng nhập nền với domain trích xuất và credentials đã lưu
      final bool loggedIn = await signIn(baseUrl: erpUrl);
      if (!loggedIn) {
        return;
      }

      // Nếu sau đăng nhập mà hệ thống redirect về Home, cần điều hướng lại trang mong muốn
      final String? pendingUrl = lastNonAuthNavigatingUrl;

      // Trường hợp có URL mong muốn trước đó và cùng domain -> load lại URL đó
      if (pendingUrl != null) {
        final Uri? pendingUri = UrlHelper.parseUrl(pendingUrl);
        if (pendingUri != null && pendingUri.host == targetUri.host) {
          await loadUrlWithNetworkCheck(pendingUri.toString());
          return;
        }
      }

      // Nếu không có pendingUrl hợp lệ, reload home
      await loadUrlWithNetworkCheck(UrlHelper.formatUrl(homeUrl));
    } catch (e) {
      debugPrint('Error during authentication redirect: $e');
    }
  }
}
