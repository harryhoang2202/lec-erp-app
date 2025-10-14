import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/data/models/user_model.dart';
import 'package:hybrid_erp_app/data/services/storage_service.dart';
import 'package:hybrid_erp_app/shared/helpers/url_helper.dart';

/// Service class for handling authentication API calls
class AuthService {
  static const String _registerEndpoint = '/Account/RegisterMobileLogIn';

  /// Signs in user with ERP URL, username, and password
  /// Returns true if authentication is successful, false otherwise
  static Future<bool> signIn({
    required String erpUrl,
    required String username,
    required String password,
  }) async {
    try {
      // Ensure ERP URL is properly formatted
      final String baseUrl = _formatUrl(erpUrl);
      final String registerUrl = '$baseUrl$_registerEndpoint';

      final params = {
        'username': username,
        'password': password,
        'tokeID': await StorageService.getDeviceId() ?? '',
        'nameToke': Platform.isIOS ? 'IOS' : 'ANDROID',
      };

      // Create dio
      final dio = Dio();
      Response response;

      response = await dio.get(registerUrl, queryParameters: params);

      // Make POST request to sign-in endpoint
      // check if user is already registered

      // Check if request was successful
      if (response.statusCode == 200) {
        if (response.data["data"] == "success" ||
            response.data["data"] == "success2") {
          return true;
        } else {
          return false;
        }
      } else {
        debugPrint(
          'Authentication failed with status code: ${response.statusCode}',
        );
        debugPrint('Response body: ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }

  /// Formats URL to ensure it has proper protocol and format
  static String _formatUrl(String url) {
    final String? formattedUrl = UrlHelper.formatErpUrl(url);
    if (formattedUrl == null) {
      throw FormatException('Invalid URL format: $url');
    }
    return formattedUrl;
  }

  /// Validates ERP URL format
  static bool isValidUrl(String url) {
    return UrlHelper.isValidUrl(url);
  }

  /// Validates user credentials format
  static bool validateCredentials({
    required String erpUrl,
    required String username,
    required String password,
  }) {
    return erpUrl.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty &&
        isValidUrl(erpUrl);
  }

  static Future<void> signOut() async {
    // Get current user to check remember me status
    final UserModel? currentUser = await StorageService.getUserCredentials();
    // Clear login status
    await StorageService.updateLoginStatus(false);
    // If remember me is disabled, clear all credentials and notifications
    if (currentUser != null && !currentUser.rememberMe) {
      await StorageService.clearUserCredentials();
    }
  }
}
