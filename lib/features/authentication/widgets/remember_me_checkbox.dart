import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/shared/extentions/context_extention.dart';

/// Widget for the "Remember Me" checkbox in the sign-in form
class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RememberMeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          checkColor: context.primaryColor,
          fillColor: !value
              ? WidgetStateProperty.all(Colors.white70)
              : WidgetStateProperty.all(Colors.white),
        ),
        Text(
          'Ghi nhớ đăng nhập',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: value ? Colors.white : Colors.white70,
          ),
        ),
      ],
    );
  }
}
