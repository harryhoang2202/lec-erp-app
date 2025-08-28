import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _selectedCategory;
  bool? _selectedReadStatus;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (refresh) {
        _currentPage = 1;
        _notifications.clear();
        _hasMoreData = true;
      }

      final newNotifications = await NotificationService.instance
          .getNotifications(
            page: _currentPage,
            pageSize: _pageSize,
            isRead: _selectedReadStatus,
            category: _selectedCategory,
          );

      setState(() {
        if (refresh) {
          _notifications.clear();
        }
        _notifications.addAll(newNotifications);
        _hasMoreData = newNotifications.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi khi tải danh sách thông báo: $e');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final newNotifications = await NotificationService.instance
          .getNotifications(
            page: _currentPage,
            pageSize: _pageSize,
            isRead: _selectedReadStatus,
            category: _selectedCategory,
          );

      setState(() {
        _notifications.addAll(newNotifications);
        _hasMoreData = newNotifications.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentPage--; // Revert page number on error
      });
      _showErrorSnackBar('Đã có lỗi xảy ra: $e');
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await NotificationService.instance.markAsRead(notification.id);
      setState(() {
        notification.isRead = true;
      });
    } catch (e) {
      _showErrorSnackBar('Đã có lỗi xảy ra: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.instance.markAllAsRead();
      setState(() {
        for (final notification in _notifications) {
          notification.isRead = true;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Đã có lỗi xảy ra: $e');
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await NotificationService.instance.deleteNotification(notification.id);
      setState(() {
        _notifications.remove(notification);
      });
    } catch (e) {
      _showErrorSnackBar('Đã có lỗi xảy ra: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _notifications.isEmpty && !_isLoading
            ? const Center(child: Text('Không có thông báo nào'))
            : ListView.separated(
                controller: _scrollController,
                itemCount: _notifications.length + (_hasMoreData ? 1 : 0),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    return _buildLoadingIndicator();
                  }

                  final notification = _notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.messageId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead ? Colors.grey : Colors.blue,
          child: Icon(
            notification.isRead
                ? Icons.notifications_none
                : Icons.notifications,
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (notification.category != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      notification.category!,
                      style: TextStyle(fontSize: 10, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _markAsRead(notification),
              ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification);
          }
          // Handle navigation based on notification data
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification data
    final data = notification.data;

    // Example navigation logic
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      // Navigate to specific screen based on notification data
      debugPrint('Navigate to screen: $screen');
    }

    // You can add more navigation logic here based on your app's requirements
  }
}
