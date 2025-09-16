import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Widget for displaying PDF files natively
class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String? title;

  const PdfViewer({super.key, required this.pdfUrl, this.title});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String? localPath;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Download PDF to local storage
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'temp_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${tempDir.path}/$fileName';

      await dio.download(widget.pdfUrl, filePath);

      setState(() {
        localPath = filePath;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Đang tải PDF...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              'Không thể tải PDF',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Lỗi không xác định',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPdf, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (localPath == null) {
      return const Center(
        child: Text(
          'Không tìm thấy file PDF',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PDFView(
      filePath: localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      onRender: (pages) {
        setState(() {
          totalPages = pages ?? 0;
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // PDF is ready
        setState(() {
          isReady = true;
        });
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          currentPage = page ?? 0;
          totalPages = total ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          hasError = true;
          errorMessage = error.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    // Clean up temporary file
    if (localPath != null) {
      try {
        File(localPath!).deleteSync();
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    super.dispose();
  }
}
