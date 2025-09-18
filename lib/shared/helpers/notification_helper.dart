import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hybrid_erp_app/data/services/storage_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Request permission for iOS
      if (Platform.isIOS) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Configure Firebase messaging
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Get FCM token
      String? token = (await _firebaseMessaging.getToken());
      if (token != null) {
        debugPrint('FCM Token: $token');
        // You can send this token to your server
        await _saveTokenToStorage(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _saveTokenToStorage(newToken);
      });
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  static Future<void> _saveTokenToStorage(String token) async {
    // Save token to shared preferences or send to your server
    // This is where you'd typically send the token to your backend
    debugPrint('Saving FCM token: $token');
    StorageService.saveDeviceId(token);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');

    // Lưu notification vào local database
    await _saveNotificationToDatabase(message);

    // Show local notification
    await _showLocalNotification(message);
  }

  static void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('App opened from background message: ${message.messageId}');
    // Handle navigation or other actions when app is opened from notification
  }

  static Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    try {
      // Lấy username hiện tại đang login
      final currentUsername = await _getCurrentUsername();
      if (currentUsername == null) {
        debugPrint('No user logged in, skipping notification save');
        return;
      }

      final notification = NotificationModel.fromRemoteMessage(
        message,
        username: currentUsername,
      );
      await NotificationService.instance.saveNotification(notification);
      debugPrint(
        'Notification saved to database: ${notification.messageId} for user: $currentUsername',
      );
    } catch (e) {
      debugPrint('Error saving notification to database: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: json.encode(message.data),
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      debugPrint('Notification tapped with data: $data');
      // Handle notification tap - navigate to specific screen, etc.
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Lấy username hiện tại đang login
  static Future<String?> _getCurrentUsername() async {
    try {
      final user = await StorageService.getUserCredentials();
      if (user != null && user.isLoggedIn) {
        return user.username;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current username: $e');
      return null;
    }
  }
}

// Helper function for background handler to get current username
Future<String?> _getCurrentUsernameForBackground() async {
  try {
    final user = await StorageService.getUserCredentials();
    if (user != null && user.isLoggedIn) {
      return user.username;
    }
    return null;
  } catch (e) {
    debugPrint('Error getting current username in background: $e');
    return null;
  }
}

// This function must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');

  // Lưu notification vào database khi app ở background
  try {
    // Lấy username hiện tại đang login
    final currentUsername = await _getCurrentUsernameForBackground();
    if (currentUsername == null) {
      debugPrint('No user logged in, skipping background notification save');
      return;
    }

    final notification = NotificationModel.fromRemoteMessage(
      message,
      username: currentUsername,
    );
    await NotificationService.instance.saveNotification(notification);
    debugPrint(
      'Background notification saved to database: ${notification.messageId} for user: $currentUsername',
    );
  } catch (e) {
    debugPrint('Error saving background notification to database: $e');
  }
}
