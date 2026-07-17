import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) => handler.next(error),
    ));
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static const _baseUrl = String.fromEnvironment(
    'AFRIGO_API_URL',
    defaultValue:
        'https://europe-west1-afrigo-62e9b.cloudfunctions.net/api/api',
  );
  late final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  String _endpoint(String endpoint) {
    if (endpoint == '/api') return '';
    return endpoint.startsWith('/api/') ? endpoint.substring(4) : endpoint;
  }

  Future<String?> _storedToken() async =>
      (await SharedPreferences.getInstance()).getString('auth_token');

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
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('auth_token');
    _dio.options.headers.remove('Authorization');
  }
}
