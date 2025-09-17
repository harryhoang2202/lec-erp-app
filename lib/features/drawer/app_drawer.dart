import 'package:flutter/material.dart';

import '../notifications/notification_list_screen.dart';

class AppDrawer extends StatefulWidget {
  final Function() onLogout;
  const AppDrawer({super.key, required this.onLogout});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 64),
          Expanded(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text('Trang chủ'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text('Thông báo'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          ListTile(
            title: Text('Đăng xuất'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              widget.onLogout();
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
