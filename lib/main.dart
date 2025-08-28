import 'package:flutter/material.dart';
import 'app_shell/app_shell.dart';
import 'resources/objectbox/objectbox.g.dart';
import 'shared/helpers/notification_helper.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox store
  final store = await openStore();

  // Initialize NotificationService
  NotificationService.initialize(store);

  // Initialize Firebase notifications
  await NotificationHelper.initialize();

  runApp(const AppShell());
}
