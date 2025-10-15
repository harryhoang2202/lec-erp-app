import 'package:flutter/material.dart';
import 'package:lec_erp_app/shared/dimens/responsive_helper.dart';
import 'package:lec_erp_app/shared/extentions/context_extention.dart';
import '../view_models/sign_in_view_model.dart';

class ErpUrlEditor extends StatelessWidget {
  final SignInViewModel viewModel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ErpUrlEditor({
    super.key,
    required this.viewModel,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveHelper.responsiveTextField(
          controller: viewModel.erpUrlController,
          labelText: 'ERP URL',
          hintText: 'your-erp-server.com',
          prefixIcon: Icons.public,
          validator: viewModel.validateErpUrl,
          onChanged: (_) => viewModel.clearError(),
          onFieldSubmitted: (_) => viewModel.clearError(),
        ),

        SizedBox(height: ResponsiveHelper.spacing),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                ),
                onPressed: onSave,
                child: Text(
                  'Lưu',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
