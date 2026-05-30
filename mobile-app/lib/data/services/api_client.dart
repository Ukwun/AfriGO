import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  String? _token;

  // Cloud backend deployed to Render
  // Updated: May 28, 2026
  static const String _baseUrl = 'https://afrigo-backend-1v22.onrender.com/api';
  static const Duration _connectTimeout = Duration(seconds: 20);
  static const Duration _receiveTimeout = Duration(seconds: 45);
  static const Duration _sendTimeout = Duration(seconds: 30);

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _token = await _getStoredToken();
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          print('🌐 ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ${error.message} (${error.type})');
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _requestWithRetry(
        () => _dio.get(endpoint),
      );

      // Check if response indicates an error (4xx status code)
      if (response.statusCode != null && response.statusCode! >= 400) {
        final data = response.data as Map<String, dynamic>?;
        final errorMsg = data?['message'] ?? 'Request failed';
        throw Exception(errorMsg);
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final errorData = e.response?.data as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? e.message ?? 'Request failed');
      }
      throw Exception(_friendlyNetworkError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _requestWithRetry(
        () => _dio.post(endpoint, data: body),
      );

      // Check if response indicates an error (4xx status code)
      if (response.statusCode != null && response.statusCode! >= 400) {
        final data = response.data as Map<String, dynamic>?;
        final errorMsg = data?['message'] ?? 'Request failed';
        throw Exception(errorMsg);
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final errorData = e.response?.data as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? e.message ?? 'Request failed');
      }
      throw Exception(_friendlyNetworkError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _requestWithRetry(
        () => _dio.put(endpoint, data: body),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final errorData = e.response?.data as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? e.message ?? 'Request failed');
      }
      throw Exception(_friendlyNetworkError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      await _requestWithRetry(
        () => _dio.delete(endpoint),
      );
    } on DioException catch (e) {
      throw Exception(_friendlyNetworkError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> _requestWithRetry(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      final shouldRetry = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout;

      if (!shouldRetry) {
        rethrow;
      }

      // Render can cold-start or mobile DNS can briefly fail; retry once.
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return request();
    }
  }

  String _friendlyNetworkError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return 'Network connection failed. Please check internet access and try again.';
      default:
        return e.message ?? 'Request failed';
    }
  }

  void setToken(String token) {
    _token = token;
    _saveToken(token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> logout() async {
    await _clearToken();
    _dio.options.headers.remove('Authorization');
  }
}
