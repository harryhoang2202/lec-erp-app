import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/shared/dimens/responsive_helper.dart';
import '../view_models/sign_in_view_model.dart';

class ErpUrlField extends StatelessWidget {
  final SignInViewModel viewModel;

  const ErpUrlField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveTextField(
      controller: viewModel.erpUrlController,
      labelText: 'ERP URL',
      hintText: 'your-erp-server.com',
      prefixIcon: Icons.public,
      validator: viewModel.validateErpUrl,
      onChanged: (_) => viewModel.clearError(),
      onFieldSubmitted: (_) => viewModel.clearError(),
    );
  }
}
