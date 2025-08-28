# Authentication Feature Documentation

## 🔐 Overview

The Authentication feature is a core component of the Hybrid ERP App that provides secure, multi-ERP system access with native mobile experience. It implements a sophisticated authentication system that supports multiple ERP servers, credential management, and seamless user experience.

## 🏗️ Architecture

### Design Pattern
- **MVVM (Model-View-ViewModel)** pattern
- **Provider** for state management
- **Clean Architecture** principles

### Component Structure
```
lib/features/authentication/
├── pages/
│   └── sign_in_page.dart          # Main authentication UI
├── view_models/
│   └── sign_in_view_model.dart    # Business logic and state management
├── widgets/                       # Reusable UI components
│   ├── app_header.dart
│   ├── erp_url_display.dart
│   ├── erp_url_editor.dart
│   ├── erp_url_field.dart
│   ├── username_field.dart
│   ├── password_field.dart
│   ├── remember_me_checkbox.dart
│   ├── sign_in_button.dart
│   ├── error_message.dart
│   ├── help_text.dart
│   └── index.dart
└── utils/
    └── date_formatter.dart        # Date formatting utilities
```

## 🔧 Core Components

### 1. SignInPage (Main UI)
**File**: `lib/features/authentication/pages/sign_in_page.dart`

**Responsibilities**:
- Main authentication interface
- Form management and validation
- Navigation to dashboard upon success
- ERP URL editing functionality

**Key Features**:
- **Responsive Design**: Adapts to different screen sizes
- **Gradient Background**: Professional visual appeal
- **Form Validation**: Real-time input validation
- **Error Handling**: User-friendly error messages
- **Loading States**: Visual feedback during authentication

### 2. SignInViewModel (Business Logic)
**File**: `lib/features/authentication/view_models/sign_in_view_model.dart`

**Responsibilities**:
- Form state management
- Authentication logic
- Credential validation
- Auto-login functionality
- Error handling

**Key Methods**:
```dart
// Core authentication
Future<bool> signIn()
Future<bool> attemptAutoLogin()
Future<void> initialize()

// Form management
bool _validateForm()
void setRememberMe(bool value)
void clearError()

// Validation
String? validateErpUrl(String? value)
String? validateUsername(String? value)
String? validatePassword(String? value)
```

### 3. UserModel (Data Model)
**File**: `lib/data/models/user_model.dart`

**Properties**:
- `erpUrl`: ERP server URL
- `username`: User credentials
- `password`: Encrypted password
- `isLoggedIn`: Authentication status
- `lastLoginAt`: Timestamp of last login
- `rememberMe`: Auto-login preference

**Key Features**:
- **JSON Serialization**: Easy data persistence
- **Immutable Design**: Thread-safe operations
- **Validation**: Built-in data validation
- **Copy Operations**: Immutable updates

## 🔄 User Flows

### 1. First-Time Login Flow
```
1. User opens app
2. App shows sign-in form
3. User enters ERP URL, username, password
4. User optionally enables "Remember Me"
5. App validates credentials
6. App authenticates with ERP server
7. On success: Navigate to dashboard
8. On failure: Show error message
```

### 2. Auto-Login Flow
```
1. User opens app
2. App checks for saved credentials
3. If "Remember Me" enabled:
   - Auto-fill form fields
   - Attempt automatic authentication
4. If successful: Navigate to dashboard
5. If failed: Show sign-in form
```

### 3. ERP URL Management Flow
```
1. User clicks "Edit" on ERP URL display
2. App shows URL editor
3. User enters new ERP URL
4. App validates URL format
5. On valid URL: Save and update display
6. On invalid URL: Show validation error
```

## 🛡️ Security Features

### 1. Credential Storage
- **Encrypted Storage**: Passwords stored securely
- **SharedPreferences**: Platform-native storage
- **Device-Specific**: Credentials tied to device ID

### 2. URL Validation
- **Protocol Validation**: Ensures HTTPS/HTTP
- **Format Validation**: Proper URL structure
- **Authority Validation**: Valid domain/host

### 3. Session Management
- **Device Registration**: Unique device identification
- **Token Management**: Secure session tokens
- **Auto-Logout**: Session timeout handling

## 🎨 UI Components

### 1. AppHeader
- **Brand Identity**: App logo and title
- **Visual Hierarchy**: Clear information structure

### 2. ErpUrlDisplay
- **Status Indicator**: Visual connection status
- **Quick Edit**: One-tap URL modification
- **Last Login**: User activity information

### 3. Form Fields
- **Real-time Validation**: Instant feedback
- **Accessibility**: Screen reader support
- **Error States**: Clear error indication

### 4. SignInButton
- **Loading States**: Visual feedback
- **Disabled States**: Prevent multiple submissions
- **Success Feedback**: Confirmation animations

## 🔌 API Integration

### Authentication Endpoints
```dart
// Registration endpoint
static const String _registerEndpoint = '/Account/RegisterMobileLogIn';

// Login endpoint
static const String _authEndpoint = '/Account/LogInMobile';
```

### Request Parameters
```dart
{
  'username': username,
  'password': password,
  'tokeID': deviceId,
  'nameToke': platform (IOS/ANDROID)
}
```

### Response Handling
- **200 Status**: Successful authentication
- **Redirect Check**: Access denied detection
- **Error Handling**: Network and server errors

## 💾 Data Persistence

### StorageService
**File**: `lib/data/services/storage_service.dart`

**Key Operations**:
```dart
// Save user credentials
Future<bool> saveUserCredentials(UserModel user)

// Retrieve user credentials
Future<UserModel?> getUserCredentials()

// Check login status
Future<bool> isUserLoggedIn()

// Clear user data
Future<bool> clearUserData()

// Device ID management
Future<String?> getDeviceId()
Future<bool> saveDeviceId(String deviceId)
```

### Storage Keys
- `user_credentials`: Complete user object
- `erp_url`: ERP server URL
- `username`: User username
- `password`: Encrypted password
- `is_logged_in`: Authentication status
- `last_login_at`: Last login timestamp
- `device_id`: Unique device identifier

## 🔍 Validation Rules

### ERP URL Validation
- **Required**: Cannot be empty
- **Format**: Must be valid URL
- **Protocol**: Auto-adds HTTPS if missing
- **Trailing Slash**: Automatically removed

### Username Validation
- **Required**: Cannot be empty
- **Minimum Length**: 3 characters
- **Format**: Alphanumeric and special characters allowed

### Password Validation
- **Required**: Cannot be empty
- **Minimum Length**: 4 characters
- **Security**: No complexity requirements (handled by ERP)

## 🚀 Performance Optimizations

### 1. Lazy Loading
- **Form Initialization**: Load only when needed
- **Credential Loading**: Async credential retrieval

### 2. State Management
- **Provider Pattern**: Efficient state updates
- **Selective Rebuilds**: Only affected widgets rebuild

### 3. Memory Management
- **Controller Disposal**: Proper resource cleanup
- **Widget Lifecycle**: Efficient component management

## 🧪 Testing Considerations

### Unit Tests
- **ViewModel Logic**: Business logic testing
- **Validation Rules**: Input validation testing
- **Service Methods**: API integration testing

### Widget Tests
- **Form Interactions**: User input testing
- **Error States**: Error handling testing
- **Loading States**: UI state testing

### Integration Tests
- **Authentication Flow**: End-to-end testing
- **Data Persistence**: Storage operations testing
- **Navigation**: Screen transitions testing

## 🔧 Configuration

### Environment Variables
- **API Endpoints**: Configurable authentication URLs
- **Timeout Settings**: Network request timeouts
- **Validation Rules**: Customizable validation parameters

### Platform-Specific
- **iOS**: Native iOS authentication integration
- **Android**: Android-specific security features
- **Device ID**: Platform-specific device identification

## 📱 Accessibility

### Screen Reader Support
- **Semantic Labels**: Proper accessibility labels
- **Focus Management**: Logical tab order
- **Error Announcements**: Screen reader error feedback

### Visual Accessibility
- **Color Contrast**: WCAG compliant color schemes
- **Text Scaling**: Support for large text
- **Touch Targets**: Adequate touch target sizes

## 🔮 Future Enhancements

### Planned Features
- **Biometric Authentication**: Fingerprint/Face ID support
- **Multi-Factor Authentication**: 2FA integration
- **SSO Integration**: Single Sign-On support
- **Offline Authentication**: Offline credential validation

### Technical Improvements
- **JWT Tokens**: Modern token-based authentication
- **OAuth 2.0**: Standard authentication protocol
- **Certificate Pinning**: Enhanced security
- **Rate Limiting**: API abuse prevention

---

*This authentication system provides a robust, secure, and user-friendly foundation for ERP system access, with comprehensive error handling, validation, and state management.*
