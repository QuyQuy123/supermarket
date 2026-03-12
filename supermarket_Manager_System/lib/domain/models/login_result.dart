class LoginResult {
  const LoginResult({
    required this.success,
    required this.message,
    required this.role,
    required this.redirectTo,
    required this.fullName,
    required this.username,
  });

  final bool success;
  final String message;
  final String role;
  final String redirectTo;
  final String fullName;
  final String username;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Login failed',
      role: json['role'] as String? ?? '',
      redirectTo: json['redirectTo'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );
  }
}
