/// User model class for ERP authentication
class UserModel {
  final String erpUrl;
  final String username;
  final String password;
  final bool isLoggedIn;
  final DateTime? lastLoginAt;
  final bool rememberMe;

  const UserModel({
    required this.erpUrl,
    required this.username,
    required this.password,
    this.isLoggedIn = false,
    this.lastLoginAt,
    this.rememberMe = false,
  });

  /// Creates a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      erpUrl: json['erp_url'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      isLoggedIn: json['is_logged_in'] as bool? ?? false,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
      rememberMe: json['remember_me'] as bool? ?? false,
    );
  }

  /// Converts UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'erp_url': erpUrl,
      'username': username,
      'password': password,
      'is_logged_in': isLoggedIn,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'remember_me': rememberMe,
    };
  }

  /// Creates a copy of this UserModel with updated fields
  UserModel copyWith({
    String? erpUrl,
    String? username,
    String? password,
    bool? isLoggedIn,
    DateTime? lastLoginAt,
    bool? rememberMe,
  }) {
    return UserModel(
      erpUrl: erpUrl ?? this.erpUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  /// Returns display name for the user
  String get displayName => username.isNotEmpty ? username : 'User';

  /// Validates if all required fields are filled
  bool get isValid =>
      erpUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(erpUrl: $erpUrl, username: $username, isLoggedIn: $isLoggedIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.erpUrl == erpUrl &&
        other.username == username &&
        other.password == password &&
        other.isLoggedIn == isLoggedIn &&
        other.rememberMe == rememberMe;
  }

  @override
  int get hashCode {
    return Object.hash(erpUrl, username, password, isLoggedIn, rememberMe);
  }
}
