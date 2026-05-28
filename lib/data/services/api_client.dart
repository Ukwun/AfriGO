import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'token_storage.dart';

/// API Client
/// Handles all HTTP requests to backend APIs
class ApiClient {
  late Dio dio;
  late String _currentUserId;
  final TokenStorage _tokenStorage = TokenStorage();

  ApiClient() {
    _initDio();
  }

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.afrigo.com', // Real backend URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add JWT token to all requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 - token expired
          if (error.response?.statusCode == 401) {
            // Refresh token and retry
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final response = await dio.post(
                  '/api/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );
                final newToken = response.data['token'];
                await _tokenStorage.saveToken(newToken);

                // Retry original request
                return handler.next(error.requestOptions);
              } catch (e) {
                // Refresh failed, redirect to login
                // This would be handled by app navigation
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;
  }

  String get currentUserId => _currentUserId;
}

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
