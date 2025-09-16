import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class DocumentPreviewScreen extends StatefulWidget {
  final String url;
  const DocumentPreviewScreen({super.key, required this.url});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  late WebViewController controller;
  bool isLoading = true;
  bool isDownloading = false;
  String? downloadedFilePath;
  @override
  void initState() {
    super.initState();
    final previewUrl = widget.url;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(previewUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            if (uri.host.contains('docs.google.com') ||
                uri.host.contains('drive.google.com') ||
                request.url == widget.url) {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.prevent;
          },
        ),
      );
  }

  Future<bool> _requestStoragePermission() async {
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

  Future<void> _downloadFile() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _showSnackBar('Storage permission denied');
        return;
      }

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // For Android, use the Downloads folder
        String downloadsPath = '/storage/emulated/0/Download';
        directory = Directory(downloadsPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!directory.existsSync()) {
        _showSnackBar('Could not access storage directory');
        return;
      }

      // Extract filename from URL
      final uri = Uri.parse(widget.url);
      String fileName = uri.pathSegments.last;
      if (fileName.isEmpty || !fileName.contains('.')) {
        fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      }

      final filePath = '${directory.path}/$fileName';

      // Download the file
      final dio = Dio();
      await dio.download(widget.url, filePath);

      // Store the downloaded file path
      downloadedFilePath = filePath;
      _showSnackBar('Đã tải về file $fileName', filePath: filePath);
    } catch (e) {
      _showSnackBar('Lỗi tải về file: ${e.toString()}');
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showSnackBar('Không thể mở file: ${result.message}');
      }
    } catch (e) {
      _showSnackBar('Lỗi mở file: ${e.toString()}');
    }
  }

  void _showSnackBar(String message, {String? filePath}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          action: filePath != null
              ? SnackBarAction(
                  label: 'Mở file',
                  textColor: Colors.white,
                  onPressed: () => _openFile(filePath),
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Preview'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isDownloading ? null : _downloadFile,
            icon: isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
