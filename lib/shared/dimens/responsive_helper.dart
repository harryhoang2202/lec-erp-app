import 'package:flutter/material.dart';
import 'app_dimen.dart';

/// Helper class để sử dụng responsive design một cách dễ dàng
class ResponsiveHelper {
  static AppDimen get dimen => AppDimen.current;

  /// Kiểm tra loại màn hình
  static bool get isSmallScreen => dimen.isSmallScreen;
  static bool get isMobileScreen => dimen.isMobileScreen;
  static bool get isTabletScreen => dimen.isTabletScreen;
  static bool get isUltraTabletScreen => dimen.isUltraTabletScreen;

  /// Lấy responsive padding
  static EdgeInsets get padding => dimen.responsivePadding;
  static EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: dimen.responsiveSpacing);
  static EdgeInsets get verticalPadding =>
      EdgeInsets.symmetric(vertical: dimen.responsiveSpacing);

  /// Lấy responsive spacing
  static double get spacing => dimen.responsiveSpacing;
  static double get smallSpacing => spacing * 0.5;
  static double get largeSpacing => spacing * 1.5;

  /// Lấy responsive border radius
  static double get radius => dimen.responsiveDimens(
    mobile: 12.0,
    small: 8.0,
    tablet: 16.0,
    ultraTablet: 20.0,
  );

  /// Lấy responsive font size
  static double getFontSize(double baseSize) {
    return dimen.getResponsiveFontSize(mobile: baseSize);
  }

  /// Lấy responsive icon size
  static double getIconSize(double baseSize) {
    return dimen.responsiveDimens(mobile: baseSize);
  }

  /// Lấy responsive button height
  static double getButtonHeight() {
    return dimen.responsiveDimens(
      mobile: 48.0,
      small: 44.0,
      tablet: 56.0,
      ultraTablet: 64.0,
    );
  }

  /// Lấy responsive card radius
  static double getCardRadius() {
    return dimen.responsiveDimens(
      mobile: 12.0,
      small: 8.0,
      tablet: 16.0,
      ultraTablet: 20.0,
    );
  }

  /// Lấy responsive elevation
  static double getElevation() {
    return dimen.responsiveDimens(
      mobile: 4.0,
      small: 2.0,
      tablet: 6.0,
      ultraTablet: 8.0,
    );
  }

  /// Tạo responsive SizedBox
  static Widget responsiveSizedBox({
    double? width,
    double? height,
    Widget? child,
  }) {
    return SizedBox(width: width?.resp(), height: height?.resp(), child: child);
  }

  /// Tạo responsive Container với padding
  static Widget responsiveContainer({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
  }) {
    return Container(
      padding: padding ?? ResponsiveHelper.padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }

  /// Tạo responsive Card
  static Widget responsiveCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    double? elevation,
  }) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation ?? ResponsiveHelper.getElevation(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getCardRadius()),
      ),
      child: ResponsiveHelper.responsiveContainer(
        child: child,
        padding: padding,
      ),
    );
  }

  /// Tạo responsive Text
  static Widget responsiveText(
    String text, {
    TextStyle? style,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final responsiveFontSize =
        fontSize?.respFont() ??
        (style?.fontSize?.respFont() ?? 14.0.respFont());

    return Text(
      text,
      style:
          style?.copyWith(
            fontSize: responsiveFontSize,
            fontWeight: fontWeight,
            color: color,
          ) ??
          TextStyle(
            fontSize: responsiveFontSize,
            fontWeight: fontWeight,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Tạo responsive Icon
  static Widget responsiveIcon(IconData icon, {double? size, Color? color}) {
    final responsiveSize = size?.resp() ?? 24.0.resp();

    return Icon(icon, size: responsiveSize, color: color);
  }

  /// Tạo responsive Button
  static Widget responsiveButton({
    required String text,
    required VoidCallback onPressed,
    double? height,
    EdgeInsets? padding,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final responsiveHeight = height ?? ResponsiveHelper.getButtonHeight();
    final responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing,
          vertical: ResponsiveHelper.smallSpacing,
        );

    return SizedBox(
      height: responsiveHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: responsivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getCardRadius(),
            ),
          ),
        ),
        child: ResponsiveHelper.responsiveText(text, style: textStyle),
      ),
    );
  }

  /// Tạo responsive TextField
  static Widget responsiveTextField({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      cursorColor: Colors.white,

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(14.0),
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(14.0),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: prefixIcon != null
            ? ResponsiveHelper.responsiveIcon(prefixIcon, color: Colors.white)
            : null,
        suffixIcon: suffixIcon,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing,
          vertical: ResponsiveHelper.smallSpacing,
        ),
      ),
      style: TextStyle(
        fontSize: ResponsiveHelper.getFontSize(16.0),
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Tạo responsive ListView với spacing
  static Widget responsiveListView({
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final responsiveSpacing = spacing ?? ResponsiveHelper.spacing;
    final responsivePadding = padding ?? ResponsiveHelper.padding;

    return ListView.separated(
      padding: responsivePadding,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: responsiveSpacing),
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Tạo responsive Column với spacing
  static Widget responsiveColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double? spacing,
  }) {
    final responsiveSpacing = spacing ?? ResponsiveHelper.spacing;
    final widgets = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      if (i < children.length - 1) {
        widgets.add(SizedBox(height: responsiveSpacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: widgets,
    );
  }

  /// Tạo responsive Row với spacing
  static Widget responsiveRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double? spacing,
  }) {
    final responsiveSpacing = spacing ?? ResponsiveHelper.spacing;
    final widgets = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);
      if (i < children.length - 1) {
        widgets.add(SizedBox(width: responsiveSpacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: widgets,
    );
  }
}
