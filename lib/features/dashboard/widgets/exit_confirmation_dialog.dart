import 'dart:io';
import 'package:flutter/material.dart';

/// Dialog widget for confirming app exit
class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Thoát ứng dụng',
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Bạn có chắc chắn muốn thoát khỏi ứng dụng?',
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () => exit(0),
          child: const Text('Thoát', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
