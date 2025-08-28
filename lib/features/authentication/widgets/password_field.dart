import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/shared/dimens/responsive_helper.dart';
import '../view_models/sign_in_view_model.dart';
import 'error_message.dart';

class PasswordField extends StatefulWidget {
  final SignInViewModel viewModel;
  final VoidCallback? onFieldSubmitted;

  const PasswordField({
    super.key,
    required this.viewModel,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveHelper.responsiveTextField(
          controller: widget.viewModel.passwordController,
          hintText: 'Nhập mật khẩu của bạn',
          labelText: 'Mật khẩu',
          prefixIcon: Icons.lock,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          onChanged: (_) => widget.viewModel.clearError(),
          onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
          validator: widget.viewModel.validatePassword,
        ),

        // Error Message
        if (widget.viewModel.errorMessage != null)
          ErrorMessage(message: widget.viewModel.errorMessage!),
      ],
    );
  }
}
