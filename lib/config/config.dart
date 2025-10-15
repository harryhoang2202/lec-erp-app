import 'dart:io';

import 'package:lec_erp_app/data/services/notification_service.dart';
import 'package:lec_erp_app/resources/objectbox/objectbox.g.dart';
import 'package:lec_erp_app/shared/helpers/notification_helper.dart';

import '../di/di.dart' as di;

class Config {
  Config._();

  static final Config _instance = Config._();

  factory Config.getInstance() => _instance;

  Future<void> config() async {
    di.configureDependencies();

    HttpOverrides.global = MyHttpOverrides();

    // Initialize ObjectBox store
    final store = await openStore();

    // Initialize NotificationService
    NotificationService.initialize(store);

    // Initialize Firebase Messaging
    await NotificationHelper.initialize();

    await Future.delayed(const Duration(milliseconds: 200));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
