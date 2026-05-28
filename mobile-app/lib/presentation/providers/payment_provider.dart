import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/payment_model.dart';
import '../../services/api_service.dart';

// ======================== HTTP SERVICE FOR PAYMENTS ========================

class PaymentService {
  final Dio httpClient;
  final String baseUrl;

  PaymentService({required this.httpClient, required this.baseUrl});

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create payment for contract
  Future<PaymentModel> createPayment(CreatePaymentRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/payments',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create payment');
    } on DioException catch (e) {
      throw Exception('Payment creation error: ${e.message}');
    }
  }

  /// Initiate payment with Flutterwave
  /// Returns payment URL for WebView redirect
  Future<String> initiatePayment(String paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/payments/$paymentId/initiate',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data']['paymentUrl'] != null) {
          return data['data']['paymentUrl'] as String;
        }
      }
      throw Exception('Failed to initiate payment');
    } on DioException catch (e) {
      throw Exception('Payment initiation error: ${e.message}');
    }
  }

  /// Get payment details
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.get(
        '$baseUrl/api/payments/$paymentId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to fetch payment');
    } on DioException catch (e) {
      throw Exception('Payment fetch error: ${e.message}');
    }
  }

  /// List payments with filters and pagination
  Future<List<PaymentModel>> listPayments({
    String? status,
    String? paymentMethod,
    String? contractId,
    String? currency,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {
        'limit': limit,
        'offset': offset,
        if (status != null) 'status': status,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (contractId != null) 'contractId': contractId,
        if (currency != null) 'currency': currency,
      };

      final response = await httpClient.get(
        '$baseUrl/api/payments',
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Payment list error: ${e.message}');
    }
  }

  /// Process refund for payment
  Future<PaymentModel> processRefund(String paymentId, String? reason) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/payments/$paymentId/refund',
        data: {'reason': reason ?? 'Refund requested by buyer'},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to process refund');
    } on DioException catch (e) {
      throw Exception('Refund error: ${e.message}');
    }
  }

  /// File payment dispute
  Future<PaymentModel> disputePayment(String paymentId, String reason) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/payments/$paymentId/dispute',
        data: {'reason': reason},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return PaymentModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to file dispute');
    } on DioException catch (e) {
      throw Exception('Dispute error: ${e.message}');
    }
  }

  /// Get payment statistics/dashboard
  Future<Map<String, dynamic>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await httpClient.get(
        '$baseUrl/api/payments/statistics',
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } on DioException catch (e) {
      throw Exception('Statistics error: ${e.message}');
    }
  }

  // ======================== ESCROW SERVICE METHODS ========================

  /// Create escrow for payment
  Future<EscrowModel> createEscrow(String paymentId, int holdingDays) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/escrow',
        data: {
          'paymentId': paymentId,
          'holdingPeriodDays': holdingDays,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return EscrowModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to create escrow');
    } on DioException catch (e) {
      throw Exception('Escrow creation error: ${e.message}');
    }
  }

  /// Get escrow details
  Future<EscrowModel> getEscrowById(String escrowId) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.get(
        '$baseUrl/api/escrow/$escrowId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return EscrowModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to fetch escrow');
    } on DioException catch (e) {
      throw Exception('Escrow fetch error: ${e.message}');
    }
  }

  /// Mark escrow condition as met
  Future<EscrowModel> releaseEscrowCondition(
    String escrowId,
    String condition,
    String? proofUrl,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/escrow/$escrowId/release/$condition',
        data: {
          'proofUrl': proofUrl,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return EscrowModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to release escrow condition');
    } on DioException catch (e) {
      throw Exception('Escrow release error: ${e.message}');
    }
  }

  /// List escrows
  Future<List<EscrowModel>> listEscrows({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final headers = await _getHeaders();
      final params = {
        'limit': limit,
        'offset': offset,
        if (status != null) 'status': status,
      };

      final response = await httpClient.get(
        '$baseUrl/api/escrow',
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => EscrowModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Escrow list error: ${e.message}');
    }
  }

  /// File escrow dispute
  Future<EscrowModel> disputeEscrow(String escrowId, String reason) async {
    try {
      final headers = await _getHeaders();
      final response = await httpClient.post(
        '$baseUrl/api/escrow/$escrowId/dispute',
        data: {'reason': reason},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return EscrowModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to file escrow dispute');
    } on DioException catch (e) {
      throw Exception('Escrow dispute error: ${e.message}');
    }
  }
}

// ======================== RIVERPOD PROVIDERS ========================

/// Payment service provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PaymentService(
    httpClient: apiService.dio,
    baseUrl: apiService.baseUrl,
  );
});

/// Create payment provider
final createPaymentProvider =
    FutureProvider.family<PaymentModel, CreatePaymentRequest>(
        (ref, request) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.createPayment(request);
});

/// Initiate payment provider (returns Flutterwave URL)
final initiatePaymentProvider =
    FutureProvider.family<String, String>((ref, paymentId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.initiatePayment(paymentId);
});

/// Get single payment provider
final getPaymentProvider =
    FutureProvider.family<PaymentModel, String>((ref, paymentId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentById(paymentId);
});

/// List payments with filters
final listPaymentsProvider = FutureProvider.family<
    List<PaymentModel>,
    ({
      String? status,
      String? paymentMethod,
      String? contractId,
      String? currency,
      int limit,
      int offset,
    })>((ref, filters) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.listPayments(
    status: filters.status,
    paymentMethod: filters.paymentMethod,
    contractId: filters.contractId,
    currency: filters.currency,
    limit: filters.limit,
    offset: filters.offset,
  );
});

/// Process refund provider
final processRefundProvider =
    FutureProvider.family<PaymentModel, (String, String?)>((ref, args) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.processRefund(args.$1, args.$2);
});

/// Dispute payment provider
final disputePaymentProvider =
    FutureProvider.family<PaymentModel, (String, String)>((ref, args) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.disputePayment(args.$1, args.$2);
});

/// Get payment statistics provider
final paymentStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentStatistics();
});

/// Escrow list provider
final escrowListProvider = FutureProvider.family<
    List<EscrowModel>,
    ({
      String? status,
      int limit,
      int offset,
    })>((ref, filters) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.listEscrows(
    status: filters.status,
    limit: filters.limit,
    offset: filters.offset,
  );
});

/// Get single escrow provider
final getEscrowProvider =
    FutureProvider.family<EscrowModel, String>((ref, escrowId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getEscrowById(escrowId);
});

/// Create escrow provider
final createEscrowProvider =
    FutureProvider.family<EscrowModel, (String, int)>((ref, args) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.createEscrow(args.$1, args.$2);
});

/// Release escrow condition provider
final releaseEscrowConditionProvider =
    FutureProvider.family<EscrowModel, (String, String, String?)>(
        (ref, args) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.releaseEscrowCondition(args.$1, args.$2, args.$3);
});

/// Dispute escrow provider
final disputeEscrowProvider =
    FutureProvider.family<EscrowModel, (String, String)>((ref, args) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.disputeEscrow(args.$1, args.$2);
});
