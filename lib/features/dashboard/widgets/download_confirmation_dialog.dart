import 'package:flutter/material.dart';

/// Dialog widget for confirming file download
class DownloadConfirmationDialog extends StatelessWidget {
  final String fileName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DownloadConfirmationDialog({
    super.key,
    required this.fileName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tải file'),
      content: Text('Bạn có muốn tải file "$fileName" về thiết bị không?'),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Hủy')),
        TextButton(onPressed: onConfirm, child: const Text('Tải về')),
      ],
    );
  }
}
