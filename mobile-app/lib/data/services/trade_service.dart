import 'api_client.dart';

/// Trade Service
/// Handles all trade operations (RFQ, bids, orders)
/// Complete lifecycle from request to delivery
///
/// Features:
/// - Create RFQs (Request for Quote)
/// - Submit and manage bids
/// - Accept/negotiate bids
/// - Payment processing
/// - Contract lifecycle
/// - Order tracking
/// - Dispute resolution

class TradeService {
  final ApiClient _apiClient = ApiClient();

  /// Get all RFQs for seller (available to quote on)
  Future<List<Map<String, dynamic>>> getAvailableRFQs() async {
    try {
      print('📋 Loading available RFQs...');

      final response = await _apiClient.get('/api/trades/rfqs/available');
      final rfqs = List<Map<String, dynamic>>.from(response['rfqs']);

      print('✅ RFQs loaded: ${rfqs.length}');
      return rfqs;
    } catch (e) {
      print('❌ Error loading RFQs: $e');
      rethrow;
    }
  }

  /// Get trade details
  Future<Map<String, dynamic>> getTradeDetails(String tradeId) async {
    try {
      print('📦 Loading trade details...');

      final response = await _apiClient.get('/api/trades/$tradeId');

      print('✅ Trade details loaded');
      return response;
    } catch (e) {
      print('❌ Error loading trade: $e');
      rethrow;
    }
  }

  /// Get trade detail (alias)
  Future<Map<String, dynamic>> getTradeDetail(String tradeId) async {
    return getTradeDetails(tradeId);
  }

  /// Create RFQ (Buyer)
  Future<Map<String, dynamic>> createRFQ({
    required String productType,
    required int quantity,
    required String grade,
    required String origin,
    required String description,
  }) async {
    try {
      print('📝 Creating RFQ...');

      final response = await _apiClient.post(
        '/api/trades/rfqs/create',
        body: {
          'productType': productType,
          'quantity': quantity,
          'grade': grade,
          'origin': origin,
          'description': description,
        },
      );

      print('✅ RFQ created: ${response['rfqId']}');
      return response;
    } catch (e) {
      print('❌ Error creating RFQ: $e');
      rethrow;
    }
  }

  /// Submit bid (Seller)
  Future<Map<String, dynamic>> submitBid({
    required String rfqId,
    required double bidPrice,
    required int availableQuantity,
    required String description,
    required int deliveryDays,
  }) async {
    try {
      print('💰 Submitting bid...');

      final response = await _apiClient.post(
        '/api/trades/bids/submit',
        body: {
          'rfqId': rfqId,
          'bidPrice': bidPrice,
          'availableQuantity': availableQuantity,
          'description': description,
          'deliveryDays': deliveryDays,
        },
      );

      print('✅ Bid submitted: ${response['bidId']}');
      return response;
    } catch (e) {
      print('❌ Error submitting bid: $e');
      rethrow;
    }
  }

  /// Get seller's bids
  Future<List<Map<String, dynamic>>> getSellerBids() async {
    try {
      print('📊 Loading seller bids...');

      final response = await _apiClient.get('/api/trades/bids/seller');
      final bids = List<Map<String, dynamic>>.from(response['bids']);

      print('✅ Bids loaded: ${bids.length}');
      return bids;
    } catch (e) {
      print('❌ Error loading bids: $e');
      rethrow;
    }
  }

  /// Accept bid (Buyer accepts seller's quote)
  Future<Map<String, dynamic>> acceptBid(String bidId) async {
    try {
      print('✅ Accepting bid...');

      final response = await _apiClient.post(
        '/api/trades/bids/$bidId/accept',
        body: {},
      );

      print('✅ Bid accepted - Trade initiated');
      return response;
    } catch (e) {
      print('❌ Error accepting bid: $e');
      rethrow;
    }
  }

  /// Reject bid (Buyer rejects seller's quote)
  Future<void> rejectBid(String bidId, String reason) async {
    try {
      print('❌ Rejecting bid...');

      await _apiClient.post(
        '/api/trades/bids/$bidId/reject',
        body: {'reason': reason},
      );

      print('✅ Bid rejected');
    } catch (e) {
      print('❌ Error rejecting bid: $e');
      rethrow;
    }
  }

  /// Get buyer's trades (all active and past)
  Future<List<Map<String, dynamic>>> getBuyerTrades() async {
    try {
      print('📦 Loading buyer trades...');

      final response = await _apiClient.get('/api/trades/buyer/my-trades');
      final trades = List<Map<String, dynamic>>.from(response['trades']);

      print('✅ Trades loaded: ${trades.length}');
      return trades;
    } catch (e) {
      print('❌ Error loading trades: $e');
      rethrow;
    }
  }

  /// Get seller's trades
  Future<List<Map<String, dynamic>>> getSellerTrades() async {
    try {
      print('📦 Loading seller trades...');

      final response = await _apiClient.get('/api/trades/seller/my-trades');
      final trades = List<Map<String, dynamic>>.from(response['trades']);

      print('✅ Trades loaded: ${trades.length}');
      return trades;
    } catch (e) {
      print('❌ Error loading trades: $e');
      rethrow;
    }
  }
}
