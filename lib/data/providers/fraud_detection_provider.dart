import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/marketplace_service.dart';

/// Fraud Detection Provider
/// Calculates real-time fraud scores for transactions
final fraudDetectionProvider =
    FutureProvider.family<double, Map<String, dynamic>>((ref, params) async {
      final marketplaceService = ref.watch(marketplaceServiceProvider);

      // REAL backend call to FraudDetectionService
      // Checks 8 patterns:
      // 1. Unusual location (+20 points)
      // 2. Activity spike (+15 points)
      // 3. Large transaction (+10 points)
      // 4. Payment reversal (+25 points)
      // 5. Rapid trades (+18 points)
      // 6. Dispute abuse (+12 points)
      // 7. KYC mismatch (+22 points)
      // 8. Account takeover (+35 points)
      // Score range: 0-100
      // Thresholds: >80 BLOCK, 70-80 MANUAL REVIEW, <70 PROCEED

      return await marketplaceService.detectFraud(
        userId: params['userId'],
        amount: params['amount'],
        productId: params['productId'],
        sellerId: params['sellerId'],
      );
    });
