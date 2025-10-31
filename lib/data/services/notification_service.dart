import 'package:lec_erp_app/shared/extentions/collection_extention.dart';
import 'package:objectbox/objectbox.dart';
import '../models/notification_model.dart';

class NotificationService {
  static NotificationService? _instance;
  static Box<NotificationModel>? _notificationBox;

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  static void initialize(Store store) {
    _notificationBox = store.box<NotificationModel>();
  }

  // Lưu notification mới
  Future<void> saveNotification(NotificationModel notification) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }
    if (notification.title.isNullOrEmpty || notification.body.isNullOrEmpty) {
      return;
    }

    try {
      // Kiểm tra xem notification đã tồn tại chưa (theo messageId và username)
      final allNotifications = _notificationBox!.getAll();
      final existing = allNotifications
          .where(
            (n) =>
                n.messageId == notification.messageId &&
                n.username == notification.username,
          )
          .firstOrNull;

      if (existing == null) {
        _notificationBox!.put(notification);
      }
    } catch (e) {
      throw Exception('Lỗi khi lưu notification: $e');
    }
  }

  // Lấy danh sách notification với phân trang
  Future<List<NotificationModel>> getNotifications({
    required String username,
    int page = 1,
    int pageSize = 20,
    bool? isRead,
    String? category,
  }) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      List<NotificationModel> allNotifications = _notificationBox!.getAll();

      // Lọc theo username trước
      allNotifications = allNotifications
          .where((n) => n.username == username)
          .toList();

      // Lọc theo trạng thái đọc
      if (isRead != null) {
        allNotifications = allNotifications
            .where((n) => n.isRead == isRead)
            .toList();
      }

      // Lọc theo category
      if (category != null) {
        allNotifications = allNotifications
            .where((n) => n.category == category)
            .toList();
      }

      // Sắp xếp theo thời gian tạo (mới nhất trước)
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Phân trang
      final offset = (page - 1) * pageSize;
      final end = (offset + pageSize < allNotifications.length)
          ? offset + pageSize
          : allNotifications.length;

      if (offset >= allNotifications.length) {
        return [];
      }

      return allNotifications.sublist(offset, end);
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách notification: $e');
    }
  }

  // Đánh dấu notification đã đọc
  Future<void> markAsRead(int notificationId) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      final notification = _notificationBox!.get(notificationId);
      if (notification != null) {
        notification.isRead = true;
        _notificationBox!.put(notification);
      }
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu notification đã đọc: $e');
    }
  }

  // Đánh dấu tất cả notification đã đọc
  Future<void> markAllAsRead({required String username}) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      final allNotifications = _notificationBox!.getAll();
      final unreadNotifications = allNotifications
          .where((n) => !n.isRead && n.username == username)
          .toList();

      for (final notification in unreadNotifications) {
        notification.isRead = true;
      }

      _notificationBox!.putMany(unreadNotifications);
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu tất cả notification đã đọc: $e');
    }
  }

  // Xóa notification
  Future<void> deleteNotification(int notificationId) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      _notificationBox!.remove(notificationId);
    } catch (e) {
      throw Exception('Lỗi khi xóa notification: $e');
    }
  }

  // Xóa tất cả notification
  Future<void> deleteAllNotifications() async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      _notificationBox!.removeAll();
    } catch (e) {
      throw Exception('Lỗi khi xóa tất cả notification: $e');
    }
  }

  // Xóa tất cả notification của một user
  Future<void> deleteAllNotificationsForUser({required String username}) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      final allNotifications = _notificationBox!.getAll();
      final userNotifications = allNotifications
          .where((n) => n.username == username)
          .toList();

      for (final notification in userNotifications) {
        _notificationBox!.remove(notification.id);
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa notification của user: $e');
    }
  }

  // Đếm số notification chưa đọc
  Future<int> getUnreadCount({required String username}) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      final allNotifications = _notificationBox!.getAll();
      return allNotifications
          .where((n) => !n.isRead && n.username == username)
          .length;
    } catch (e) {
      throw Exception('Lỗi khi đếm notification chưa đọc: $e');
    }
  }

  // Đếm tổng số notification
  Future<int> getTotalCount() async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      return _notificationBox!.count();
    } catch (e) {
      throw Exception('Lỗi khi đếm tổng số notification: $e');
    }
  }

  // Đếm tổng số notification của một user
  Future<int> getTotalCountForUser({required String username}) async {
    if (_notificationBox == null) {
      throw Exception('NotificationService chưa được khởi tạo');
    }

    try {
      final allNotifications = _notificationBox!.getAll();
      return allNotifications.where((n) => n.username == username).length;
    } catch (e) {
      throw Exception('Lỗi khi đếm tổng số notification của user: $e');
    }
  }
}
