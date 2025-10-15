import 'package:flutter/material.dart';
import 'package:lec_erp_app/features/dashboard/pages/main_screen.dart';
import 'package:lec_erp_app/resources/generated/assets.gen.dart';
import 'package:lec_erp_app/shared/dimens/responsive_helper.dart';
import 'package:provider/provider.dart';
import '../view_models/sign_in_view_model.dart';
import '../widgets/index.dart';
import '../utils/date_formatter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late SignInViewModel _viewModel;
  bool _isEditingErpUrl = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SignInViewModel();
    _viewModel.initialize();
  }

  void _toggleErpUrlEdit() {
    setState(() {
      _isEditingErpUrl = !_isEditingErpUrl;
    });

    // When starting to edit, ensure the ERP URL field has the current value
    if (_isEditingErpUrl && _viewModel.currentUser != null) {
      _viewModel.erpUrlController.text = _viewModel.currentUser!.erpUrl;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.background.provider(),
              fit: BoxFit.cover,
              opacity: 0.8,
              colorFilter: ColorFilter.mode(Colors.black26, BlendMode.multiply),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Consumer<SignInViewModel>(
                  builder: (context, viewModel, child) {
                    return Container(
                      margin: ResponsiveHelper.horizontalPadding,
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            // App Header
                            const AppHeader(),

                            // Main Form Card
                            Padding(
                              padding: ResponsiveHelper.padding,
                              child: Column(
                                spacing: ResponsiveHelper.spacing,
                                children: [
                                  // ERP URL Section
                                  if (viewModel.currentUser != null &&
                                      !_isEditingErpUrl) ...[
                                    ErpUrlDisplay(
                                      user: viewModel.currentUser!,
                                      onEditPressed: _toggleErpUrlEdit,
                                      formatLastLogin:
                                          DateFormatter.formatLastLogin,
                                    ),
                                  ] else ...[
                                    ErpUrlField(viewModel: viewModel),
                                  ],

                                  // Username Field
                                  UsernameField(viewModel: viewModel),

                                  // Password Field
                                  PasswordField(
                                    viewModel: viewModel,
                                    onFieldSubmitted: _handleSignIn,
                                  ),
                                ],
                              ),
                            ),

                            // Sign In Button
                            SignInButton(
                              isLoading: viewModel.isLoading,
                              onPressed: _handleSignIn,
                            ),
                            SizedBox(height: ResponsiveHelper.spacing),
                            // Help Text
                            const HelpText(
                              text:
                                  'Nhập đường dẫn máy chủ ERP và thông tin đăng nhập của bạn để truy cập hệ thống.',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_viewModel.isLoading) return;

    final bool success = await _viewModel.signIn();
    if (success && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }
}
