import 'dart:io';

import 'package:flutter/material.dart';

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
                      onPressed?.call(0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      margin: EdgeInsets.only(left: activeIndex == 0 ? 0 : 16),
                      alignment: activeIndex == 0
                          ? Alignment.center
                          : Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: activeIndex == 0
                            ? Colors.black.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Icon(Icons.home, size: 32.0),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onPressed?.call(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      margin: EdgeInsets.only(right: activeIndex == 1 ? 0 : 16),
                      alignment: activeIndex == 1
                          ? Alignment.center
                          : Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: activeIndex == 1
                            ? Colors.black.withValues(alpha: 0.1)
                            : Colors.transparent,
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
                onPressed?.call(2);
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
