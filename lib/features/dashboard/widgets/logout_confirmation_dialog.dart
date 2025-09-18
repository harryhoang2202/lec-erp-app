import 'package:flutter/material.dart';

/// Dialog widget for confirming app exit
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Đăng xuất',
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?',
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
