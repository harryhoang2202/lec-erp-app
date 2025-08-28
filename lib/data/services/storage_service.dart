import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service class for handling local storage operations
class StorageService {
  static const String _userKey = 'user_credentials';
  static const String _erpUrlKey = 'erp_url';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _lastLoginKey = 'last_login_at';
  static const String _deviceIdKey = 'device_id';

  /// Saves user credentials to local storage
  static Future<bool> saveUserCredentials(UserModel user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save individual fields for easy access
      await prefs.setString(_erpUrlKey, user.erpUrl);
      await prefs.setString(_usernameKey, user.username);
      await prefs.setString(_passwordKey, user.password);
      await prefs.setBool(_isLoggedInKey, user.isLoggedIn);

      if (user.lastLoginAt != null) {
        await prefs.setString(
          _lastLoginKey,
          user.lastLoginAt!.toIso8601String(),
        );
      }

      // Save complete user object as JSON
      final String userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);

      return true;
    } catch (e) {
      debugPrint('Error saving user credentials: $e');
      return false;
    }
  }

  /// Retrieves user credentials from local storage
  static Future<UserModel?> getUserCredentials() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap);
      }

      // Fallback: try to get individual fields
      final String? erpUrl = prefs.getString(_erpUrlKey);
      final String? username = prefs.getString(_usernameKey);
      final String? password = prefs.getString(_passwordKey);
      final bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final String? lastLoginStr = prefs.getString(_lastLoginKey);

      if (erpUrl != null && username != null && password != null) {
        return UserModel(
          erpUrl: erpUrl,
          username: username,
          password: password,
          isLoggedIn: isLoggedIn,
          lastLoginAt: lastLoginStr != null
              ? DateTime.tryParse(lastLoginStr)
              : null,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error retrieving user credentials: $e');
      return null;
    }
  }

  /// Checks if user is currently logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Gets saved device id
  static Future<String?> getDeviceId() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deviceIdKey);
    } catch (e) {
      debugPrint('Error getting device id: $e');
      return null;
    }
  }

  /// Updates login status
  static Future<bool> updateLoginStatus(bool isLoggedIn) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);

      if (isLoggedIn) {
        await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      }

      // Update the complete user object if it exists
      final UserModel? user = await getUserCredentials();
      if (user != null) {
        final UserModel updatedUser = user.copyWith(
          isLoggedIn: isLoggedIn,
          lastLoginAt: isLoggedIn ? DateTime.now() : user.lastLoginAt,
        );
        await saveUserCredentials(updatedUser);
      }

      return true;
    } catch (e) {
      debugPrint('Error updating login status: $e');
      return false;
    }
  }

  /// Clears all user data from local storage
  static Future<bool> clearUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove(_userKey);
      await prefs.remove(_erpUrlKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_passwordKey);
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_lastLoginKey);

      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }

  /// Clears user credentials from local storage
  static Future<bool> clearUserCredentials() async {
    return clearUserData();
  }

  /// Saves device id
  static Future<bool> saveDeviceId(String deviceId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceIdKey, deviceId);
      return true;
    } catch (e) {
      debugPrint('Error saving device id: $e');
      return false;
    }
  }
}
