import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Service để kiểm tra kết nối mạng và trạng thái internet
class NetworkHelper {
  static final NetworkHelper instance = NetworkHelper._internal();
  factory NetworkHelper() => instance;
  NetworkHelper._internal();

  final Connectivity _connectivity = Connectivity();

  /// Kiểm tra xem có kết nối mạng hay không
  Future<bool> hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Kiểm tra nếu không có kết nối mạng nào
      if (connectivityResult.first == ConnectivityResult.none) {
        return false;
      }

      // Kiểm tra kết nối internet thực tế bằng cách ping một server
      return await _hasInternetConnection();
    } catch (e) {
      debugPrint('NetworkService: Error checking connection: $e');
      return false;
    }
  }

  /// Kiểm tra kết nối internet thực tế bằng cách ping server
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('NetworkService: No internet connection: $e');
      return false;
    }
  }

  /// Kiểm tra kết nối với một URL cụ thể
  Future<bool> canReachUrl(String url) async {
    try {
      if (await hasConnection()) {
        final uri = Uri.parse(url);
        final result = await InternetAddress.lookup(uri.host);
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('NetworkService: Cannot reach URL $url: $e');
      return false;
    }
  }

  /// Hiển thị SnackBar thông báo không có kết nối
  static void showNoConnectionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('Không có kết nối internet'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
