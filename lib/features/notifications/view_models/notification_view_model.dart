import 'package:flutter/material.dart';
import 'package:lec_erp_app/data/models/notification_model.dart';
import 'package:lec_erp_app/data/services/notification_service.dart';
import 'package:lec_erp_app/data/services/storage_service.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  int pageSize = 20;
  List<NotificationModel> get notifications => _notifications;

  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getNotifications() async {
    try {
      _currentPage = 1;
      isLoading = true;
      final user = await StorageService.getUserCredentials();
      if (user != null && user.isLoggedIn) {
        final notifications = await NotificationService.instance
            .getNotifications(
              username: user.username,
              page: _currentPage,
              pageSize: pageSize,
            );
        _notifications = notifications;
        isLoading = false;
        _hasMoreData = notifications.length == pageSize;
        _currentPage++;
      } else {
        debugPrint('User not logged in');
        isLoading = false;
      }
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      isLoading = false;
      _hasMoreData = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    try {
      isLoading = true;
      final user = await StorageService.getUserCredentials();
      if (user != null && user.isLoggedIn) {
        final notifications = await NotificationService.instance
            .getNotifications(
              username: user.username,
              page: _currentPage,
              pageSize: pageSize,
            );

        _notifications.addAll(notifications);
        isLoading = false;
        _hasMoreData = notifications.length == pageSize;
        _currentPage++;
      } else {
        debugPrint('User not logged in');
        isLoading = false;
      }
    } catch (e) {
      debugPrint('Error loading more notifications: $e');
      isLoading = false;
      _hasMoreData = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    try {
      await NotificationService.instance.markAsRead(notification.id);
      notification.isRead = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = await StorageService.getUserCredentials();
      if (user != null && user.isLoggedIn) {
        await NotificationService.instance.markAllAsRead(
          username: user.username,
        );
        for (final notification in notifications) {
          notification.isRead = true;
        }
        notifyListeners();
      } else {
        debugPrint('User not logged in');
        isLoading = false;
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      isLoading = false;
    }
  }

  void deleteNotification(NotificationModel notification) async {
    try {
      await NotificationService.instance.deleteNotification(notification.id);
      notifications.remove(notification);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  void deleteAllNotificationsForUser() async {
    try {
      final user = await StorageService.getUserCredentials();
      if (user != null && user.isLoggedIn) {
        await NotificationService.instance.deleteAllNotificationsForUser(
          username: user.username,
        );
        _notifications.clear();
        _currentPage = 1;
        _hasMoreData = true;
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting all notifications for user: $e');
    }
  }
}
