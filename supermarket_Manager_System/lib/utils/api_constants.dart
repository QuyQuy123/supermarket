class ApiConstants {
  // Android emulator -> 10.0.2.2, physical/web -> localhost.
  static const String baseUrl = 'http://localhost:8080';
  static const String loginPath = '/api/auth/login';
  static const String forgotPasswordPath = '/api/auth/forgot-password';
  static const String verifyOtpPath = '/api/auth/verify-otp';
  static const String resetPasswordPath = '/api/auth/reset-password';
  static const String usersPath = '/api/users';
  static const String userRolesPath = '/api/users/roles';
  static const String ordersPath = '/api/orders';
  static const String customersPath = '/api/customers';
  static const String dashboardPath = '/api/orders/dashboard';
  static const String dashboardTransactionsPath = '/api/orders/today-transactions';
  static const String revenueReportPath = '/api/reports/revenue';
  static const String discountsPath = '/api/discounts';
}

