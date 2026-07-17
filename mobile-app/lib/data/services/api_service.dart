import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// ApiService provider for Riverpod
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(apiClient: ApiClient());
});

/// Wrapper around ApiClient for cleaner provider usage
class ApiService {
  final ApiClient apiClient;

  ApiService({required this.apiClient});

  /// Perform a GET request
  Future<Map<String, dynamic>> get(String endpoint) {
    return apiClient.get(endpoint);
  }

  /// Perform a POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return apiClient.post(endpoint, body: body ?? {});
  }

  /// Perform a PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return apiClient.put(endpoint, body: body ?? {});
  }

  /// Perform a PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return apiClient.patch(endpoint, body: body ?? {});
  }

  /// Perform a DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) {
    return apiClient.delete(endpoint);
  }
}
