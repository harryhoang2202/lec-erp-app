import 'package:flutter/material.dart';
import 'package:lec_erp_app/features/dashboard/pages/main_screen.dart';
import 'package:lec_erp_app/features/notifications/view_models/notification_view_model.dart';
import 'package:provider/provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/storage_service.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final ScrollController _scrollController = ScrollController();
  late NotificationViewModel _viewModel;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationViewModel();
    _viewModel.getNotifications();
    _scrollController.addListener(_onScroll);
    _checkLoginStatus();
  }

  _checkLoginStatus() {
    StorageService.isUserLoggedIn().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_viewModel.isLoading && _viewModel.hasMoreData) {
        _viewModel.loadMoreNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotificationViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape: const Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
          title: const Text('Thông báo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _viewModel.notifications.isNotEmpty
                  ? _viewModel.markAllAsRead
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _viewModel.notifications.isNotEmpty
                  ? () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),

                          title: const Text('Xóa tất cả thông báo'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa tất cả thông báo?',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _viewModel.deleteAllNotificationsForUser();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
        body: Consumer<NotificationViewModel>(
          builder: (context, viewModel, child) {
            if (!_isLoggedIn) {
              return const Center(
                child: Text('Vui lòng đăng nhập để xem thông báo'),
              );
            }
            if (viewModel.notifications.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text('Không có thông báo nào')),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => viewModel.getNotifications(),
                    child: const Text('Tải lại'),
                  ),
                ],
              );
            }
            return RefreshIndicator(
              onRefresh: () => viewModel.getNotifications(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount:
                    viewModel.notifications.length +
                    (viewModel.hasMoreData ? 1 : 0),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == viewModel.notifications.length) {
                    return _buildLoadingIndicator();
                  }

                  final notification = viewModel.notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
            );
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
        _viewModel.deleteNotification(notification);
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notification.isRead) ...[
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _viewModel.markAsRead(notification),
              ),
            ],
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            _viewModel.markAsRead(notification);
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
    if (notification.openUrl == true) {
      if (notification.url != null && notification.url!.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(initialUrl: notification.url),
          ),
        );
      }
    }
  }
}
