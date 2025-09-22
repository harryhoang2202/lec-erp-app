import 'package:flutter/material.dart';
import 'app_shell/app_shell.dart';
import 'config/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.getInstance().config();
  runApp(const AppShell());
}
