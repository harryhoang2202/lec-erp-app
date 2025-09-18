/// Constants used in the main screen
class MainScreenConstants {
  // Retry configuration
  static const int maxRetries = 3;

  // Authentication redirect paths
  static const List<String> authRedirectPaths = [
    'Account/LogOff',
    'Account/LogOn',
  ];
  // Navigation bar configuration
  static const int logoutTabIndex = 0;
  static const int homeTabIndex = 1;
  static const int notificationTabIndex = 2;
  static const int backTabIndex = 3;
}
