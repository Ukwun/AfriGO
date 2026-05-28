import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/constants.dart';
import '../api_client.dart';

/// Payment Service Provider
final paymentServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient: apiClient);
});

/// Payment Service
/// Handles all payment and escrow operations
class PaymentService {
  final ApiClient apiClient;

  PaymentService({required this.apiClient});

  /// Initiate payment (escrow)
  /// Buyer pays -> Money held in escrow -> Seller notified
  /// Fraud detection already runs in UI before this call
  Future<Map<String, dynamic>> initiatePayment({
    required String tradeId,
    required double amount,
    required double fraudScore,
    String paymentMethod = 'CARD', // CARD, MOBILE_MONEY, BANK_TRANSFER
  }) async {
    try {
      final response = await apiClient.post(
        '/api/payments/initiate',
        data: {
          'tradeId': tradeId,
          'amount': amount,
          'fraudScore': fraudScore,
          'fraudStatus': fraudScore > 80
              ? 'BLOCKED'
              : fraudScore > 70
              ? 'REVIEW'
              : 'PASSED',
          'paymentMethod': paymentMethod,
          'paymentType': 'ESCROW',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return {
        'paymentOrderId': response['paymentOrderId'],
        'status': response['status'],
        'escrowAccountId': response['escrowAccountId'],
      };
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String paymentOrderId) async {
    try {
      final response = await apiClient.get(
        '/api/payments/$paymentOrderId/status',
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  /// Confirm Flutterwave payment
  /// Called after Flutterwave returns to app with payment confirmation
  Future<void> confirmFlutterwavePayment({
    required String paymentOrderId,
    required String flutterwaveReference,
  }) async {
    try {
      await apiClient.post(
        '/api/payments/$paymentOrderId/confirm-flutterwave',
        data: {
          'flutterwaveReference': flutterwaveReference,
          'confirmationTime': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  /// Release escrow payment to seller
  /// Called by buyer after confirming product delivery and quality
  Future<void> releaseEscrowPayment({
    required String tradeId,
    required String paymentOrderId,
  }) async {
    try {
      await apiClient.post(
        '/api/payments/$paymentOrderId/release-escrow',
        data: {
          'tradeId': tradeId,
          'releaseTime': DateTime.now().toIso8601String(),
          'reason': 'DELIVERY_CONFIRMED',
        },
      );
    } catch (e) {
      throw Exception('Failed to release escrow: $e');
    }
  }

  /// Request refund
  /// Buyer can request refund if product doesn't match
  Future<void> requestRefund({
    required String paymentOrderId,
    required String reason,
    required String description,
  }) async {
    try {
      await apiClient.post(
        '/api/payments/$paymentOrderId/request-refund',
        data: {
          'reason': reason, // QUALITY_MISMATCH, DAMAGED, NOT_RECEIVED, OTHER
          'description': description,
          'requestTime': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to request refund: $e');
    }
  }

  /// Get escrow account details
  Future<Map<String, dynamic>> getEscrowAccount(String escrowAccountId) async {
    try {
      final response = await apiClient.get('/api/escrow/$escrowAccountId');
      return response;
    } catch (e) {
      throw Exception('Failed to get escrow details: $e');
    }
  }

  /// Get payment history for trade
  Future<List<Map<String, dynamic>>> getPaymentHistory(String tradeId) async {
    try {
      final response = await apiClient.get('/api/trades/$tradeId/payments');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  /// Settlement confirmation (after delivery proof)
  /// Mark payment as settled and ready to release to seller
  Future<void> confirmSettlement({
    required String paymentOrderId,
    required String deliveryProofId,
    required String deliveryNotes,
  }) async {
    try {
      await apiClient.post(
        '/api/payments/$paymentOrderId/confirm-settlement',
        data: {
          'paymentOrderId': paymentOrderId,
          'deliveryProofId': deliveryProofId,
          'deliveryNotes': deliveryNotes,
          'settlementTime': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to confirm settlement: $e');
    }
  }
}
