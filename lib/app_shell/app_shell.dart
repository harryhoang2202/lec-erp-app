import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/shared/dimens/app_dimen.dart';
import 'package:provider/provider.dart';
import '../features/authentication/view_models/sign_in_view_model.dart';
import 'splash_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppDimen.of(context);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SignInViewModel())],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          primaryColor: const Color(0xFF1D24AB),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
