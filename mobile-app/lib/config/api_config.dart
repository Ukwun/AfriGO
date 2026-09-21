class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'AFRIGO_API_URL',
    defaultValue: 'https://europe-west1-afrigo-62e9b.cloudfunctions.net',
  );

  static String get apiBaseUrl => '$baseUrl/api';
}
