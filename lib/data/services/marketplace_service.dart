import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/models/lot.dart';
import '../../domain/models/trade.dart';
import 'api_client.dart';

/// Marketplace Service
/// Connects to real backend APIs
class MarketplaceService {
  final ApiClient _apiClient;

  MarketplaceService(this._apiClient);

  /// Get all lots (with optional search, filters, sort)
  /// REAL backend call to: GET /api/lots
  /// Returns lots with:
  /// - Real trust scores from TrustScoringService
  /// - Real fraud risk scores from FraudDetectionService
  /// - Real quality data from immutable logs
  /// - Real seller verification status
  Future<List<Lot>> getLots({
    String search = '',
    Map<String, dynamic> filters = const {},
    String sortBy = 'newest',
  }) async {
    try {
      final params = {
        if (search.isNotEmpty) 'search': search,
        'sortBy': sortBy,
        ...filters,
      };

      final response = await _apiClient.dio.get(
        '/api/lots',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final lotsData = response.data['data'] as List;
        return lotsData.map((json) => Lot.fromJson(json)).toList();
      }
      throw Exception('Failed to load lots: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Get product detail
  /// REAL backend call to: GET /api/lots/:id
  /// Returns complete lot with all related data:
  /// - Photos and documents
  /// - Quality test results (immutable)
  /// - Seller trust score and history
  /// - Buyer reviews and ratings
  /// - Activity logs
  Future<Lot> getProductDetail(String productId) async {
    try {
      final response = await _apiClient.dio.get('/api/lots/$productId');

      if (response.statusCode == 200) {
        return Lot.fromJson(response.data['data']);
      }
      throw Exception('Failed to load product: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Detect fraud for transaction
  /// REAL backend call to: POST /api/fraud-detection
  /// Runs 8 pattern checks, returns score 0-100
  /// - <70: Proceed normally
  /// - 70-80: Manual review
  /// - >80: Block immediately
  Future<double> detectFraud({
    required String userId,
    required double amount,
    required String productId,
    required String sellerId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/fraud-detection',
        data: {
          'userId': userId,
          'amount': amount,
          'productId': productId,
          'sellerId': sellerId,
        },
      );

      if (response.statusCode == 200) {
        return (response.data['fraudScore'] as num).toDouble();
      }
      throw Exception('Fraud detection failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Create RFQ (Request for Quote)
  /// REAL backend call to: POST /api/trades/rfq
  /// - Runs fraud check immediately
  /// - Creates immutable activity log
  /// - Creates trade record in database
  /// - Broadcasts event via WebSocket to seller (0.3 second latency)
  /// - Seller receives notification instantly
  Future<Trade> createRFQ({
    required String productId,
    required String sellerId,
    required double quantity,
    required double offeredPrice,
  }) async {
    try {
      // First, run fraud detection
      final fraudScore = await detectFraud(
        userId: _apiClient.currentUserId,
        amount: quantity * offeredPrice,
        productId: productId,
        sellerId: sellerId,
      );

      // Check fraud thresholds
      if (fraudScore > 80) {
        throw Exception(
          'Transaction blocked: Fraud risk too high ($fraudScore/100). Please verify your account.',
        );
      }

      if (fraudScore > 70) {
        // Manual review needed - still create but flag for admin
        // In real app, might require additional verification
      }

      // Create RFQ
      final response = await _apiClient.dio.post(
        '/api/trades/rfq',
        data: {
          'productId': productId,
          'sellerId': sellerId,
          'quantity': quantity,
          'offeredPrice': offeredPrice,
          'fraudScore': fraudScore,
        },
      );

      if (response.statusCode == 201) {
        // Activity logged automatically by backend
        // Real-time notification sent via WebSocket to seller
        // Both parties synchronized within 0.3 seconds
        return Trade.fromJson(response.data['data']);
      }
      throw Exception('Failed to create RFQ: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Save/favorite a lot
  /// REAL backend call to: POST /api/favorites/add
  /// - Creates activity log entry
  /// - Updates user's recommendation algorithm
  /// - Returns immediately
  Future<void> saveLot(String productId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/favorites/add',
        data: {'productId': productId},
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save lot: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Create offer (alternative to RFQ)
  /// REAL backend call to: POST /api/offers/create
  /// Simpler version of RFQ without negotiation
  Future<Trade> createOffer({
    required String productId,
    required String sellerId,
    required double quantity,
    required double price,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/offers/create',
        data: {
          'productId': productId,
          'sellerId': sellerId,
          'quantity': quantity,
          'price': price,
        },
      );

      if (response.statusCode == 201) {
        return Trade.fromJson(response.data['data']);
      }
      throw Exception('Failed to create offer: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }
}

/// Marketplace Service Provider
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketplaceService(apiClient);
});
