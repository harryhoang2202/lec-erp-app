import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

/// Widget for displaying images with zoom and pan capabilities
class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const ImageViewer({super.key, required this.imageUrl, this.title});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildImageViewer());
  }

  Widget _buildImageViewer() {
    if (_hasError) {
      return _buildErrorView();
    }

    return PhotoView(
      imageProvider: CachedNetworkImageProvider(
        widget.imageUrl,
        errorListener: (error) {
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
          });
        },
      ),
      loadingBuilder: (context, event) {
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorView();
      },
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2.0,
      initialScale: PhotoViewComputedScale.contained,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrl),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Không thể tải hình ảnh',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
