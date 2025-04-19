class Constants {
  // API
  static const String apiBaseUrl = 'https://api.onesociety.com/api';

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // OneSSO (Keycloak) Configuration
  static const String keycloakBaseUrl = 'https://sso.oneapp.in';
  static const String keycloakRealm = 'oneapp';
  static const String keycloakClientId = 'member-staff-app';

  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String duesReportRoute = '/all-dues-report';
  static const String featureRequestRoute = '/feature-request';

  // Assets
  static const String logoPath = 'assets/images/logo.png';

  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedErrorMessage = 'You are not authorized to access this resource.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String logoutSuccessMessage = 'Logout successful!';
  static const String exportSuccessMessage = 'Report exported successfully!';
}
