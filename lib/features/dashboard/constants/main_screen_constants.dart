/// Constants used in the main screen
class MainScreenConstants {
  // Retry configuration
  static const int maxRetries = 3;

  // File extensions that can be previewed directly in app
  static const List<String> previewFileExtensions = [
    '.pdf',
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.tiff',
    '.ico',
  ];

  // Image file extensions (for native image viewer)
  static const List<String> imageFileExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.tiff',
    '.ico',
  ];

  // PDF file extensions (for native PDF viewer)
  static const List<String> pdfFileExtensions = ['.pdf'];

  // File extensions that should be downloaded (documents)
  static const List<String> downloadFileExtensions = [
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.ppt',
    '.pptx',
    '.txt',
    '.rtf',
    '.odt',
    '.ods',
    '.odp',
    '.zip',
    '.rar',
    '.7z',
    '.tar',
    '.gz',
  ];

  // Authentication redirect paths
  static const List<String> authRedirectPaths = [
    'Account/LogOff',
    'Account/LogOn',
  ];

  // Navigation bar configuration
  static const int homeTabIndex = 0;
  static const int notificationTabIndex = 1;
  static const int backTabIndex = 2;

  // Colors
  static const int selectedItemColor = 0xFF2196F3; // Colors.blue
  static const int unselectedItemColor = 0xFF9E9E9E; // Colors.grey
  static const int exitButtonColor = 0xFFF44336; // Colors.red

  // Icon sizes
  static const double defaultIconSize = 32.0;
  static const double smallIconSize = 28.0;
}
