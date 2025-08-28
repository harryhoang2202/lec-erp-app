import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/shared/dimens/responsive_helper.dart';
import '../view_models/sign_in_view_model.dart';

class UsernameField extends StatelessWidget {
  final SignInViewModel viewModel;

  const UsernameField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveTextField(
      controller: viewModel.usernameController,
      labelText: 'Tên đăng nhập',
      hintText: 'Nhập tên tài khoản của bạn',
      prefixIcon: Icons.person,
      validator: viewModel.validateUsername,
      onChanged: (_) => viewModel.clearError(),
      onFieldSubmitted: (_) => viewModel.clearError(),
    );
  }
}
