# Hybrid ERP App 📱

A Flutter-based mobile application that provides seamless access to Enterprise Resource Planning (ERP) systems through a native mobile interface. The app combines the power of web-based ERP systems with native mobile functionality, offering users a familiar mobile experience while maintaining full ERP system capabilities.

## 🚀 Features

### 🔐 Authentication System
- **Multi-ERP Support**: Connect to different ERP systems via URL
- **Credential Management**: Secure storage of login credentials
- **Remember Me**: Optional auto-login functionality
- **Form Validation**: Comprehensive input validation
- **Auto-login**: Automatic authentication for saved credentials

### 🌐 WebView Integration
- **Seamless ERP Access**: Direct access to web-based ERP systems
- **Native Navigation**: Mobile-optimized navigation controls
- **Session Management**: Maintains ERP session state
- **File Downloads**: Native file handling and preview
- **Network Monitoring**: Real-time network connectivity monitoring
- **Smart Retry**: Automatic retry when connection is restored

### 🔔 Push Notifications
- **Firebase Integration**: Cloud-based push notification system
- **Local Notifications**: Device-level notification handling
- **Background Processing**: Notifications when app is closed
- **Notification History**: View and manage notifications

### 💾 Data Management
- **Local Database**: ObjectBox for offline data storage
- **Caching**: Intelligent data caching for performance
- **Sync Capabilities**: Data synchronization with ERP systems
- **Document Preview**: PDF and image viewing capabilities

## 🏗️ Architecture

### Technology Stack
- **Framework**: Flutter (Dart SDK ^3.8.1)
- **State Management**: Provider pattern
- **Dependency Injection**: GetIt for service locator
- **Local Database**: ObjectBox (NoSQL database)
- **Backend Integration**: WebView + HTTP API calls
- **Push Notifications**: Firebase Cloud Messaging
- **Local Storage**: SharedPreferences
- **HTTP Client**: Dio
- **Network Monitoring**: Connectivity Plus with real-time monitoring

### Project Structure
```
lib/
├── app_shell/           # Main app shell and splash screen
├── data/               # Data layer (models, services)
│   ├── models/         # Data models
│   └── services/       # Business logic services
├── features/           # Feature-based modules
│   ├── authentication/ # User authentication
│   ├── dashboard/      # Main dashboard and WebView
│   ├── document/       # Document preview and handling
│   ├── drawer/         # Navigation drawer
│   └── notifications/  # Push notifications
├── shared/             # Shared utilities and constants
│   ├── constants/      # App constants
│   ├── dimens/         # UI dimensions
│   ├── extensions/     # Dart extensions
│   └── helpers/        # Utility functions
├── di/                 # Dependency injection setup
└── main.dart          # App entry point
```

## 📱 Platform Support

### Android
- **Minimum SDK**: Configured for modern Android devices
- **Firebase Services**: Integrated for notifications and analytics
- **Native Features**: Device-specific optimizations
- **APK Build**: Automated release build script

### iOS
- **Swift Integration**: Native iOS capabilities
- **Firebase Support**: Full Firebase ecosystem integration
- **App Store Ready**: Configured for App Store deployment

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK ^3.8.1
- Dart SDK
- Android Studio / Xcode
- Firebase project setup

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hybrid_erp_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`

5. **Run the app**
   ```bash
   flutter run
   ```

### Build Release APK
```bash
# Use the provided build script
./build_release.sh

# Or manually
flutter build apk --release
```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Cloud Messaging
3. Download configuration files
4. Place them in the appropriate platform directories

### ObjectBox Setup
The app uses ObjectBox for local database storage. The database is automatically initialized when the app starts.

### WebView Configuration
The app supports various WebView configurations for different ERP systems. Configuration can be found in `lib/features/dashboard/config/webview_config.dart`.

### Network Monitoring
The app includes comprehensive network monitoring features:
- **Real-time Connectivity**: Monitors network status continuously
- **Smart Retry**: Automatically retries failed requests when connection is restored
- **User Feedback**: Clear notifications for network issues
- **URL Validation**: Checks if specific URLs are reachable before loading

## 🔐 Security Features

- **Secure Storage**: Encrypted local credential storage
- **URL Validation**: Strict ERP URL format validation
- **Session Security**: Secure session management
- **Device Identification**: Unique device ID tracking
- **Certificate Pinning**: Enhanced security for API calls
- **Network Security**: Real-time network monitoring and validation

## 📊 Key Dependencies

```yaml
# Core Flutter
flutter: sdk: flutter
cupertino_icons: ^1.0.8

# WebView and State Management
flutter_inappwebview: ^6.1.5
provider: ^6.1.2

# Network and Storage
dio: ^5.8.0+1
shared_preferences: ^2.2.2
connectivity_plus: ^7.0.0

# Firebase Services
firebase_core: ^3.6.0
firebase_messaging: ^15.1.3
flutter_local_notifications: ^18.0.1

# Local Database
objectbox: ^4.3.1
objectbox_flutter_libs: any

# File Handling
path_provider: ^2.1.4
permission_handler: ^11.3.1
open_file: ^3.3.2
pdf: ^3.10.7
flutter_pdfview: ^1.3.2

# Dependency Injection
get_it: ^8.0.0
```

## 🚀 Usage

### First Time Setup
1. Launch the app
2. Enter your ERP system URL
3. Provide your username and password
4. Optionally enable "Remember Me" for auto-login
5. Tap "Sign In" to authenticate

### Daily Usage
- The app will automatically log you in if credentials are saved
- Navigate through your ERP system using the native interface
- Receive push notifications for important updates
- Download and preview documents directly in the app
- Real-time network monitoring ensures smooth browsing experience
- Automatic retry when network connection is restored

## 🔄 Development

### Architecture Improvements
- **Dependency Injection**: Using GetIt for better service management
- **Separation of Concerns**: Clear separation between UI and business logic
- **Network Service**: Centralized network monitoring and connectivity management
- **Error Handling**: Comprehensive error handling with user-friendly messages

### Code Generation
```bash
# Generate ObjectBox code
flutter packages pub run build_runner build

# Generate asset code
flutter packages pub run flutter_gen_runner
```


### Linting
```bash
# Check code quality
flutter analyze
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Review the code comments for implementation details

---

**Built with ❤️ using Flutter**
