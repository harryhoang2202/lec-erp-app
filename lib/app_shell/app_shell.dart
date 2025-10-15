import 'package:flutter/material.dart';
import 'package:lec_erp_app/shared/dimens/app_dimen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../features/authentication/view_models/sign_in_view_model.dart';
import 'splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // Request permissions
  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.storage.request();
    await Permission.location.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  Widget build(BuildContext context) {
    AppDimen.of(context);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SignInViewModel())],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
