import 'package:flutter/material.dart';
import 'package:lec_erp_app/shared/dimens/responsive_helper.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/extentions/context_extention.dart';

class ErpUrlDisplay extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditPressed;
  final String Function(DateTime) formatLastLogin;

  const ErpUrlDisplay({
    super.key,
    required this.user,
    required this.onEditPressed,
    required this.formatLastLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.padding,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(ResponsiveHelper.radius),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
          SizedBox(width: ResponsiveHelper.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã kết nối với máy chủ ERP',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.erpUrl,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.lastLoginAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Lần đăng nhập trước:\n${formatLastLogin(user.lastLoginAt!)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEditPressed,
            icon: Icon(Icons.edit, color: Colors.blue[700], size: 20),
            tooltip: 'Change ERP URL',
          ),
        ],
      ),
    );
  }
}
