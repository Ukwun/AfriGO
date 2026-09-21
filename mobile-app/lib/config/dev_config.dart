/// Development Configuration
/// Controls whether to use mock or real API
library;

class DevConfig {
  /// Set to true to use mock API (for testing UI without backend)
  /// Set to false to use real backend API
  static const bool USE_MOCK_API = bool.fromEnvironment(
    'AFRIGO_USE_MOCK_API',
    defaultValue: false,
  );

  /// Show debug messages in console
  static const bool DEBUG_LOGS = true;

  /// Test mode features
  static const bool SHOW_TEST_USERS = bool.fromEnvironment(
    'AFRIGO_SHOW_TEST_USERS',
    defaultValue: false,
  );
  static const bool AUTO_LOGIN_ENABLED = false;
  static const String AUTO_LOGIN_EMAIL = 'farmer@afrigo.com';
  static const String AUTO_LOGIN_PASSWORD = 'Test@123';
}
