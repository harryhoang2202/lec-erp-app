import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';

/// View model for handling sign-in logic and state management
class SignInViewModel extends ChangeNotifier {
  // Form controllers
  final TextEditingController erpUrlController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _rememberMe = true;
  bool _isPasswordVisible = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isFormValid => _validateForm();

  /// Initializes the view model and loads saved credentials
  Future<void> initialize() async {
    try {
      await _loadSavedCredentials();
    } catch (e) {
      debugPrint('Error initializing sign-in view model: $e');
    }
  }

  /// Attempts to auto-login if remember me is enabled and credentials exist
  Future<bool> attemptAutoLogin() async {
    try {
      final UserModel? savedUser = await StorageService.getUserCredentials();
      if (savedUser != null && savedUser.rememberMe && savedUser.isValid) {
        // Auto-fill the form
        erpUrlController.text = savedUser.erpUrl;
        usernameController.text = savedUser.username;
        passwordController.text = savedUser.password;
        _rememberMe = savedUser.rememberMe;
        _currentUser = savedUser;
        notifyListeners();

        // Attempt to sign in automatically
        return await signIn();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Loads saved credentials from local storage
  Future<void> _loadSavedCredentials() async {
    try {
      final UserModel? savedUser = await StorageService.getUserCredentials();
      if (savedUser != null) {
        erpUrlController.text = savedUser.erpUrl;
        usernameController.text = savedUser.username;
        // Note: We don't auto-fill password for security reasons
        _currentUser = savedUser;
        _rememberMe = savedUser.rememberMe;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  /// Validates the form
  bool _validateForm() {
    return erpUrlController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  /// Sets loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Toggles password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Sets remember me value
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Validates ERP URL format
  String? validateErpUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập đường dẫn ERP';
    }

    if (!AuthService.isValidUrl(value)) {
      return 'Dường dẫn ERP không hợp lệ';
    }

    return null;
  }

  /// Validates username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }

    return null;
  }

  /// Validates password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 4) {
      return 'Mật khẩu phải có ít nhất 4 ký tự';
    }

    return null;
  }

  /// Signs in user with provided credentials
  Future<bool> signIn() async {
    // Clear previous errors
    clearError();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _setLoading(true);

    try {
      final String erpUrl = erpUrlController.text.trim();
      final String username = usernameController.text.trim();
      final String password = passwordController.text;

      // Validate credentials format
      if (!AuthService.validateCredentials(
        erpUrl: erpUrl,
        username: username,
        password: password,
      )) {
        _setError('Thông tin đăng nhập không hợp lệ');
        return false;
      }
      final bool isLoggedIn = await AuthService.signIn(
        erpUrl: erpUrl,
        username: username,
        password: password,
      );
      if (!isLoggedIn) {
        _setError('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.');
        return false;
      }

      // Create user model
      final UserModel user = UserModel(
        erpUrl: erpUrl,
        username: username,
        password: password,
        isLoggedIn: true,
        lastLoginAt: DateTime.now(),
        rememberMe: _rememberMe,
      );

      // Save credentials to local storage only if remember me is enabled
      bool saved = true;
      if (_rememberMe) {
        saved = await StorageService.saveUserCredentials(user);
      } else {
        // Clear saved credentials if remember me is disabled
        await StorageService.clearUserCredentials();
      }

      if (saved) {
        _currentUser = user;
        return true;
      } else {
        _setError('Lưu thông tin đăng nhập thất bại');
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates ERP URL and clears current user
  Future<void> updateErpUrl(String newUrl) async {
    erpUrlController.text = newUrl;
    // Update the current user with the new URL if it exists
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(erpUrl: newUrl);
      // Save the updated user data to storage
      await StorageService.saveUserCredentials(_currentUser!);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    erpUrlController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
