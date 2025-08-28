class DeviceConstants {
  final double designSmallDeviceWidth;
  final double designSmallDeviceHeight;

  final double designMobileDeviceWidth;
  final double designMobileDeviceHeight;

  final double designTabletDeviceWidth;
  final double designTabletDeviceHeight;

  final double designDesktopDeviceWidth;
  final double designDesktopDeviceHeight;

  final double maxMobileWidth;
  final double maxTabletWidth;

  final double maxMobileWidthForDesktopType;
  final double maxTabletWidthForDesktopType;

  const DeviceConstants({
    this.designSmallDeviceWidth = 375,
    this.designSmallDeviceHeight = 667,
    this.designMobileDeviceWidth = 390,
    this.designMobileDeviceHeight = 844,
    this.designTabletDeviceWidth = 1024.0,
    this.designTabletDeviceHeight = 1366.0,
    this.designDesktopDeviceWidth = 1280.0,
    this.designDesktopDeviceHeight = 832.0,
    this.maxMobileWidth = 550,
    this.maxTabletWidth = 850,
    this.maxMobileWidthForDesktopType = 600,
    this.maxTabletWidthForDesktopType = 1000,
  });
}
