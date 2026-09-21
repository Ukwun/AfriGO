import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storedToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            error.requestOptions.extra['retry'] != true) {
          final refreshedToken = await _refreshCurrentSessionToken();
          if (refreshedToken != null) {
            final requestOptions = error.requestOptions;
            requestOptions.extra['retry'] = true;
            requestOptions.headers['Authorization'] = 'Bearer $refreshedToken';
            try {
              final response = await _dio.fetch(requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static final _baseUrl = ApiConfig.apiBaseUrl;
  static const _tokenStorageKey = 'auth_token';
  static const _secureStorage = FlutterSecureStorage();

  late final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  String _endpoint(String endpoint) {
    if (endpoint == '/api') return '';
    return endpoint.startsWith('/api/') ? endpoint.substring(4) : endpoint;
  }

  Future<String?> _storedToken() async =>
      _secureStorage.read(key: _tokenStorageKey);

  Future<String?> _refreshCurrentSessionToken() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final idToken = await currentUser.getIdTokenResult(true);
      final token = idToken.token;
      if (token == null || token.isEmpty) return null;
      await setToken(token);
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) =>
      _request(() => _dio.get(_endpoint(endpoint)));

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) =>
      _request(() => _dio.post(_endpoint(endpoint),
          data: body,
          options: headers == null ? null : Options(headers: headers)));

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) =>
      _request(() => _dio.put(_endpoint(endpoint), data: body));

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    required Map<String, dynamic> body,
  }) =>
      _request(() => _dio.patch(_endpoint(endpoint), data: body));

  Future<Map<String, dynamic>> delete(String endpoint) =>
      _request(() => _dio.delete(_endpoint(endpoint)));

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() operation,
  ) async {
    try {
      Response<dynamic> response;
      try {
        response = await operation();
      } on DioException catch (error) {
        if (!_retryable(error)) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 800));
        response = await operation();
      }
      final data = response.data;
      if ((response.statusCode ?? 500) >= 400) {
        final message = data is Map ? data['message'] : null;
        throw Exception(message ?? 'Request failed (${response.statusCode})');
      }
      if (data == null) return <String, dynamic>{};
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw Exception('Invalid response from server');
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception(_networkMessage(error));
    }
  }

  bool _retryable(DioException error) =>
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;

  String _networkMessage(DioException error) => _retryable(error)
      ? 'Network connection failed. Check your connection and try again.'
      : error.message ?? 'Request failed';

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenStorageKey, value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenStorageKey);
    _dio.options.headers.remove('Authorization');
  }
}
