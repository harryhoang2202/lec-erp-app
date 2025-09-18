import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/features/dashboard/constants/main_screen_constants.dart';

class WBottomNavBar extends StatelessWidget {
  final Function(int)? onPressed;
  final int activeIndex;

  const WBottomNavBar({super.key, this.onPressed, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        spacing: 16.0,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              onPressed?.call(MainScreenConstants.logoutTabIndex);
            },
            child: Container(
              width: 64.0,
              height: 48,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: 180 * pi / 180,
                child: Icon(Icons.logout_outlined, size: 24.0),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              onPressed?.call(MainScreenConstants.homeTabIndex);
            },
            child: Container(
              width: 64.0,
              height: 48,
              alignment: Alignment.center,
              child: Icon(
                activeIndex == MainScreenConstants.homeTabIndex
                    ? Icons.home
                    : Icons.home_outlined,
                size: 24.0,
                color: activeIndex == MainScreenConstants.homeTabIndex
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              onPressed?.call(MainScreenConstants.notificationTabIndex);
            },
            child: Container(
              width: 64.0,
              height: 48,
              alignment: Alignment.center,
              child: Icon(Icons.notifications_outlined, size: 24.0),
            ),
          ),

          if (Platform.isIOS)
            InkWell(
              onTap: () {
                onPressed?.call(MainScreenConstants.backTabIndex);
              },
              child: Container(
                width: 64.0,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.black,
                  size: 24.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
