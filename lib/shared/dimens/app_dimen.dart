import 'package:flutter/material.dart';
import 'package:lec_erp_app/shared/dimens/dimens.dart';

import '../constants/device_constants.dart';

class AppDimen {
  AppDimen._({
    required this.screenWidth,
    required this.screenHeight,
    required this.devicePixelRatio,
    required this.screenType,
    required this.safeBottomPadding,
  });

  static late AppDimen current;
  static DeviceConstants deviceConstants = const DeviceConstants();

  // Cache để tối ưu performance
  static final Map<String, double> _cache = {};

  static const maxMobileWidthForDeviceType = 550;
  final double screenWidth;
  final double screenHeight;
  final double devicePixelRatio;
  final ScreenType screenType;
  final double safeBottomPadding;

  static AppDimen of(BuildContext context, {DeviceConstants? deviceConstants}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    deviceConstants = deviceConstants ?? const DeviceConstants();

    final safePadding = MediaQuery.of(context).padding;
    final screen = AppDimen._(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      devicePixelRatio: devicePixelRatio,
      screenType: _getScreenType(screenWidth, screenHeight),
      safeBottomPadding: (safePadding.bottom + Dimens.d16),
    );

    current = screen;

    return current;
  }

  double responsiveDimens({
    required double mobile,
    double? small,
    double? tablet,
    double? ultraTablet,
  }) {
    // Tạo cache key
    final cacheKey =
        '${mobile}_${small}_${tablet}_${ultraTablet}_${screenType.name}';

    // Kiểm tra cache
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    double result;
    switch (screenType) {
      case ScreenType.small:
        result = small ?? _calculateScaledValue(mobile, ScreenType.small);
        break;
      case ScreenType.mobile:
        result = mobile;
        break;
      case ScreenType.tablet:
        result = tablet ?? _calculateScaledValue(mobile, ScreenType.tablet);
        break;
      case ScreenType.ultraTablet:
        result =
            ultraTablet ??
            _calculateScaledValue(mobile, ScreenType.ultraTablet);
        break;
    }

    // Lưu vào cache (giới hạn cache size để tránh memory leak)
    if (_cache.length < 100) {
      _cache[cacheKey] = result;
    }

    return result;
  }

  int responsiveIntValue({
    required int mobile,
    int? small,
    int? tablet,
    int? ultraTablet,
  }) {
    switch (screenType) {
      case ScreenType.small:
        return small ?? mobile;
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.ultraTablet:
        return ultraTablet ?? mobile;
    }
  }

  // Cải thiện logic phân loại màn hình
  static ScreenType _getScreenType(double screenWidth, double screenHeight) {
    // Ưu tiên xử lý màn hình nhỏ (height < 600px)
    if (screenHeight < 630) {
      return ScreenType.small;
    }

    // Sau đó xử lý theo width
    if (screenWidth <= deviceConstants.maxMobileWidth) {
      return ScreenType.mobile;
    } else if (screenWidth <= deviceConstants.maxTabletWidth) {
      return ScreenType.tablet;
    } else {
      return ScreenType.ultraTablet;
    }
  }

  // Cải thiện công thức tính toán
  double _calculateScaledValue(double baseValue, ScreenType targetType) {
    double scaleFactor = 1.0;

    switch (targetType) {
      case ScreenType.small:
        // Giảm kích thước cho màn hình nhỏ
        scaleFactor = 0.75;
        break;
      case ScreenType.tablet:
        // Tăng kích thước cho tablet
        scaleFactor = 1.25;
        break;
      case ScreenType.ultraTablet:
        // Tăng kích thước cho ultra tablet
        scaleFactor = 1.5;
        break;
      case ScreenType.mobile:
        scaleFactor = 1.0;
        break;
    }

    return baseValue * scaleFactor;
  }

  Size screenDesign() {
    switch (screenType) {
      case ScreenType.small:
        return Size(
          deviceConstants.designSmallDeviceWidth,
          deviceConstants.designSmallDeviceHeight,
        );
      case ScreenType.mobile:
        return Size(
          deviceConstants.designMobileDeviceWidth,
          deviceConstants.designMobileDeviceHeight,
        );
      case ScreenType.tablet:
      case ScreenType.ultraTablet:
        return Size(
          deviceConstants.designTabletDeviceWidth,
          deviceConstants.designTabletDeviceHeight,
        );
    }
  }

  // Thêm method để clear cache khi cần
  static void clearCache() {
    _cache.clear();
  }

  // Thêm method để kiểm tra loại màn hình
  bool get isSmallScreen => screenType == ScreenType.small;
  bool get isMobileScreen => screenType == ScreenType.mobile;
  bool get isTabletScreen => screenType == ScreenType.tablet;
  bool get isUltraTabletScreen => screenType == ScreenType.ultraTablet;

  // Thêm method để lấy responsive padding
  EdgeInsets get responsivePadding {
    switch (screenType) {
      case ScreenType.small:
        return const EdgeInsets.all(12.0);
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.ultraTablet:
        return const EdgeInsets.all(32.0);
    }
  }

  // Thêm method để lấy responsive spacing
  double get responsiveSpacing {
    switch (screenType) {
      case ScreenType.small:
        return 12.0;
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 24.0;
      case ScreenType.ultraTablet:
        return 32.0;
    }
  }

  // Thêm method để lấy responsive font size
  double getResponsiveFontSize({
    required double mobile,
    double? small,
    double? tablet,
    double? ultraTablet,
  }) {
    return responsiveDimens(
      mobile: mobile,
      small: small ?? (mobile * 0.85), // Giảm 15% cho màn hình nhỏ
      tablet: tablet ?? (mobile * 1.1), // Tăng 10% cho tablet
      ultraTablet: ultraTablet ?? (mobile * 1.2), // Tăng 20% cho ultra tablet
    );
  }
}

extension ResponsiveDoubleExtension on double {
  double resp({double? small, double? tablet, double? ultraTablet}) {
    return AppDimen.current.responsiveDimens(
      mobile: this,
      small: small,
      tablet: tablet,
      ultraTablet: ultraTablet,
    );
  }

  // Thêm extension cho font size
  double respFont({double? small, double? tablet, double? ultraTablet}) {
    return AppDimen.current.getResponsiveFontSize(
      mobile: this,
      small: small,
      tablet: tablet,
      ultraTablet: ultraTablet,
    );
  }
}

enum ScreenType { small, mobile, tablet, ultraTablet }
