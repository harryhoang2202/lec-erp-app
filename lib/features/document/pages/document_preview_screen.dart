import 'package:flutter/material.dart';
import 'package:lec_erp_app/data/services/file_download_service.dart';
import 'package:lec_erp_app/features/document/widgets/image_viewer.dart';
import 'package:lec_erp_app/features/document/widgets/pdf_viewer.dart';
import 'package:lec_erp_app/shared/constants/url_constants.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String url;
  const DocumentPreviewScreen({super.key, required this.url});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_extractFileName(widget.url)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              _downloadFile();
            },
            icon: Icon(Icons.download),
          ),
        ],
      ),
      body: _buildPreviewContent(),
    );
  }

  /// Build the appropriate preview content based on file type
  Widget _buildPreviewContent() {
    if (_isImageFile(widget.url)) {
      return ImageViewer(imageUrl: widget.url);
    } else if (_isPdfFile(widget.url)) {
      return PdfViewer(pdfUrl: widget.url);
    } else {
      // Fallback for unsupported file types
      return _buildUnsupportedFileView();
    }
  }

  /// Check if the URL points to an image file
  bool _isImageFile(String url) {
    return UrlConstants.imageFileExtensions.any(
      (extension) => url.toLowerCase().endsWith(extension),
    );
  }

  /// Check if the URL points to a PDF file
  bool _isPdfFile(String url) {
    return UrlConstants.pdfFileExtensions.any(
      (extension) => url.toLowerCase().endsWith(extension),
    );
  }

  /// Extract filename from URL
  String _extractFileName(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    return 'Document';
  }

  /// Build view for unsupported file types
  Widget _buildUnsupportedFileView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Loại file này không thể xem trực tiếp',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Vui lòng tải file về để xem',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Handle file download using the shared service
  Future<void> _downloadFile() async {
    final fileName = FileDownloadService.extractFileName(widget.url);
    await FileDownloadService.downloadFile(
      url: widget.url,
      fileName: fileName,
      context: context,
    );
  }
}
