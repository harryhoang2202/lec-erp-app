import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hybrid_erp_app/features/dashboard/constants/main_screen_constants.dart';

class WBottomNavBar extends StatelessWidget {
  final Function(int)? onPressed;
  final int activeIndex;
  const WBottomNavBar({super.key, this.onPressed, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 24),
        ],
      ),
      child: Row(
        spacing: 16.0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 48.0,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(48.0),
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onPressed?.call(MainScreenConstants.menuTabIndex);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      margin: EdgeInsets.only(left: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Icon(Icons.menu, size: 32.0),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onPressed?.call(MainScreenConstants.homeTabIndex);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),

                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Icon(Icons.home, size: 32.0),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onPressed?.call(MainScreenConstants.notificationTabIndex);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      margin: EdgeInsets.only(right: 16),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Icon(Icons.notifications, size: 32.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!Platform.isAndroid)
            InkWell(
              onTap: () {
                onPressed?.call(MainScreenConstants.backTabIndex);
              },
              child: Container(
                height: 48.0,
                width: 48.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
