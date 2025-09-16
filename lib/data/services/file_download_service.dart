import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

/// Service for handling file downloads
class FileDownloadService {
  /// Extract filename from URL
  static String extractFileName(String url) {
    final uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;
    if (fileName.isEmpty || !fileName.contains('.')) {
      fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
    return fileName;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus == PermissionStatus.granted;
      }
      return status == PermissionStatus.granted;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  /// Download file from URL
  static Future<void> downloadFile({
    required String url,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        _showSnackBar(context, 'Storage permission denied');
        return;
      }

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        // For Android, use the Downloads folder
        String downloadsPath = '/storage/emulated/0/Download';
        directory = Directory(downloadsPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!directory.existsSync()) {
        _showSnackBar(context, 'Could not access storage directory');
        return;
      }

      final filePath = '${directory.path}/$fileName';

      // Download the file
      final dio = Dio();
      await dio.download(url, filePath);

      _showSnackBar(context, 'Đã tải về file $fileName', filePath: filePath);
    } catch (e) {
      _showSnackBar(context, 'Lỗi tải về file: ${e.toString()}');
    }
  }

  /// Open file with system default app
  static Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Could not open file: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error opening file: ${e.toString()}');
    }
  }

  /// Show snackbar with optional file opening action
  static void _showSnackBar(
    BuildContext context,
    String message, {
    String? filePath,
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: filePath != null
              ? SnackBarAction(
                  label: 'Mở file',
                  textColor: Colors.white,
                  onPressed: () => openFile(filePath),
                )
              : null,
        ),
      );
    }
  }
}
