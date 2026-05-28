import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/models/trade.dart';
import '../../domain/models/bid.dart';
import '../client/api_client.dart';

/// Trade Service Provider
final tradeServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TradeService(apiClient);
});

/// Trade Service
/// All backend API calls for trading/RFQ operations
class TradeService {
  final ApiClient _apiClient;

  TradeService(this._apiClient);

  /// Create RFQ (Request for Quote)
  /// FUNCTIONAL backend call
  /// 1. Fraud detection runs
  /// 2. RFQ created in database (immutable)
  /// 3. Activity log entry created
  /// 4. WebSocket broadcast (RFQ_CREATED event)
  /// 5. All matching sellers notified in real-time (<500ms)
  ///
  /// Returns: Created Trade object with ID
  /// Endpoint: POST /api/trades/rfq
  Future<Trade> createRFQ({
    required String productType,
    required double quantity,
    required double maxPrice,
    required String deliveryLocation,
    required DateTime deliveryDate,
    required String specialRequirements,
    required double fraudScore,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/trades/rfq',
        data: {
          'productType': productType,
          'quantity': quantity,
          'maxPrice': maxPrice,
          'deliveryLocation': deliveryLocation,
          'deliveryDate': deliveryDate.toIso8601String(),
          'specialRequirements': specialRequirements,
          'fraudScore': fraudScore,
          'status': 'OPEN',
        },
      );

      return Trade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create RFQ: $e');
    }
  }

  /// Get all RFQs for current buyer
  /// Returns list of trades with bids and current quotes
  /// Endpoint: GET /api/trades/rfq?buyerId={buyerId}
  Future<List<Trade>> getRFQs() async {
    try {
      final response = await _apiClient.get('/api/trades/rfq');

      final List<dynamic> data = response.data;
      return data.map((json) => Trade.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch RFQs: $e');
    }
  }

  /// Get RFQ detail with all quotes from sellers
  /// Real-time updates via WebSocket
  /// Endpoint: GET /api/trades/rfq/{rfqId}
  Future<Trade> getRFQDetail(String rfqId) async {
    try {
      final response = await _apiClient.get('/api/trades/rfq/$rfqId');
      return Trade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch RFQ: $e');
    }
  }

  /// Get all quotes/bids for an RFQ
  /// Real-time: WebSocket listens to BID_RECEIVED events
  /// Latency: <500ms for WebSocket updates
  /// Endpoint: GET /api/trades/rfq/{rfqId}/bids
  Future<List<Bid>> getBidsForRFQ(String rfqId) async {
    try {
      final response = await _apiClient.get('/api/trades/rfq/$rfqId/bids');

      final List<dynamic> data = response.data;
      return data.map((json) => Bid.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bids: $e');
    }
  }

  /// Accept bid and create trade
  /// FUNCTIONAL backend call
  /// 1. Fraud detection runs again
  /// 2. Trade status changes to ACCEPTED
  /// 3. Contract generated
  /// 4. Escrow account initiated
  /// 5. Payment order created
  /// 6. Both parties notified in real-time
  /// 7. Activity logged immutably
  ///
  /// Endpoint: POST /api/trades/bid/{bidId}/accept
  Future<Trade> acceptBid(String bidId) async {
    try {
      final response = await _apiClient.post(
        '/api/trades/bid/$bidId/accept',
        data: {'acceptedAt': DateTime.now().toIso8601String()},
      );

      return Trade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to accept bid: $e');
    }
  }

  /// Reject bid
  /// FUNCTIONAL backend call
  /// 1. Bid status changed to REJECTED
  /// 2. Activity logged
  /// 3. Seller notified
  /// 4. RFQ remains OPEN for other bids
  ///
  /// Endpoint: POST /api/trades/bid/{bidId}/reject
  Future<void> rejectBid(String bidId) async {
    try {
      await _apiClient.post(
        '/api/trades/bid/$bidId/reject',
        data: {'rejectedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to reject bid: $e');
    }
  }

  /// Submit counter-offer
  /// FUNCTIONAL backend call
  /// 1. Creates counter-offer record (immutable)
  /// 2. Logs activity
  /// 3. Sends real-time notification to seller (<500ms)
  /// 4. Updates negotiation history
  /// 5. Bid status changes to COUNTERED
  ///
  /// Endpoint: POST /api/trades/bid/{bidId}/counter
  Future<Trade> submitCounterOffer(String bidId, double newPrice) async {
    try {
      final response = await _apiClient.post(
        '/api/trades/bid/$bidId/counter',
        data: {
          'counterPrice': newPrice,
          'counterAt': DateTime.now().toIso8601String(),
        },
      );

      return Trade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to submit counter-offer: $e');
    }
  }

  /// Get active trades by status
  /// Filters trades for tab navigation
  /// Real-time: WebSocket broadcasts TRADE_STATUS_CHANGED events
  /// Endpoint: GET /api/trades?status={status}
  Future<List<Trade>> getActiveTrades(String status) async {
    try {
      final response = await _apiClient.get(
        '/api/trades',
        queryParameters: {'status': status},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Trade.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch trades: $e');
    }
  }

  /// Get trade detail (single trade view)
  /// Shows negotiation history, messages, current bid status
  /// Real-time: WebSocket for new messages and status updates
  /// Endpoint: GET /api/trades/{tradeId}
  Future<Trade> getTradeDetail(String tradeId) async {
    try {
      final response = await _apiClient.get('/api/trades/$tradeId');
      return Trade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch trade: $e');
    }
  }

  /// Send message in trade chat
  /// FUNCTIONAL backend call
  /// 1. Message created and stored
  /// 2. Both parties notified in real-time (<500ms)
  /// 3. Activity logged
  ///
  /// Endpoint: POST /api/trades/{tradeId}/messages
  Future<void> sendMessage(String tradeId, String message) async {
    try {
      await _apiClient.post(
        '/api/trades/$tradeId/messages',
        data: {'message': message, 'sentAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get all messages for a trade
  /// Real-time: WebSocket listens to MESSAGE_RECEIVED events
  /// Endpoint: GET /api/trades/{tradeId}/messages
  Future<List<Map<String, dynamic>>> getMessages(String tradeId) async {
    try {
      final response = await _apiClient.get('/api/trades/$tradeId/messages');

      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  /// Detect fraud for trade operations
  /// Runs 8-pattern fraud detection
  /// Thresholds:
  /// - >80: BLOCK (reject operation)
  /// - 70-80: REVIEW (flag for manual verification)
  /// - <70: PROCEED (allow operation)
  ///
  /// Returns: Fraud score 0-100
  /// Endpoint: POST /api/fraud-detection
  Future<double> detectFraud({
    required double amount,
    required String action,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/fraud-detection',
        data: {
          'amount': amount,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return (response.data['fraudScore'] as num).toDouble();
    } catch (e) {
      throw Exception('Fraud detection error: $e');
    }
  }

  /// Accept trade (shorthand for acceptBid when used from trading_screen)
  /// For trades in OPEN/NEGOTIATING status, accepts the best bid
  /// FUNCTIONAL backend call
  /// 1. Fraud detection runs again
  /// 2. Trade status changes to ACCEPTED
  /// 3. Contract generated
  /// 4. Escrow account initiated
  /// 5. Payment order created
  /// 6. Both parties notified in real-time
  /// 7. Activity logged immutably
  ///
  /// Endpoint: POST /api/trades/{tradeId}/accept
  Future<Trade> acceptTrade(String tradeId) async {
    try {
      final response = await _apiClient.post(
        '/api/trades/$tradeId/accept',
        data: {'acceptedAt': DateTime.now().toIso8601String()},
      );

      return Trade.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to accept trade: $e');
    }
  }

  /// Reject trade
  /// FUNCTIONAL backend call
  /// 1. Trade status changed to CANCELLED
  /// 2. Activity logged
  /// 3. Seller notified
  /// 4. All bids rejected
  ///
  /// Endpoint: POST /api/trades/{tradeId}/reject
  Future<void> rejectTrade(String tradeId) async {
    try {
      await _apiClient.post(
        '/api/trades/$tradeId/reject',
        data: {'rejectedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to reject trade: $e');
    }
  }

  /// Get all bids for a trade (same as getBidsForRFQ)
  Future<List<Bid>> getBidsForTrade(String tradeId) async {
    try {
      final response = await _apiClient.get('/api/trades/$tradeId/bids');

      final List<dynamic> data = response.data;
      return data.map((json) => Bid.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bids: $e');
    }
  }

  /// Request trade modification
  /// FUNCTIONAL backend call
  /// Buyer requests seller to adjust terms (price, delivery date, quantity)
  /// 1. Modification request created
  /// 2. Seller notified in real-time
  /// 3. Activity logged
  ///
  /// Endpoint: POST /api/trades/{tradeId}/request-modification
  Future<void> requestModification({
    required String tradeId,
    required String fieldToModify,
    required dynamic newValue,
    required String reason,
  }) async {
    try {
      await _apiClient.post(
        '/api/trades/$tradeId/request-modification',
        data: {
          'field': fieldToModify,
          'newValue': newValue,
          'reason': reason,
          'requestedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to request modification: $e');
    }
  }

  /// Get trust score impact for trade
  /// Shows how trade affects buyer's trust score
  /// Endpoint: GET /api/trades/{tradeId}/trust-impact
  Future<Map<String, dynamic>> getTrustImpact(String tradeId) async {
    try {
      final response = await _apiClient.get(
        '/api/trades/$tradeId/trust-impact',
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch trust impact: $e');
    }
  }

  /// Get activity log for trade (immutable)
  /// All operations logged append-only, cannot be modified
  /// Endpoint: GET /api/trades/{tradeId}/activity-log
  Future<List<String>> getActivityLog(String tradeId) async {
    try {
      final response = await _apiClient.get(
        '/api/trades/$tradeId/activity-log',
      );

      final List<dynamic> data = response.data;
      return data.cast<String>();
    } catch (e) {
      throw Exception('Failed to fetch activity log: $e');
    }
  }

  /// Create bid (seller submits quote on RFQ)
  /// FUNCTIONAL backend call - SELLER-SIDE
  /// 1. Fraud detection may run on seller's account
  /// 2. Bid created in database (immutable)
  /// 3. Activity log entry created
  /// 4. WebSocket broadcast (BID_RECEIVED event)
  /// 5. Buyer notified in real-time (<500ms)
  /// 6. Quote appears in buyer's trade detail screen instantly
  ///
  /// Returns: Created Bid object with ID
  /// Endpoint: POST /api/trades/rfq/{rfqId}/bid
  Future<Bid> createBid({
    required String rfqId,
    required double offeredPrice,
    required double quantity,
    required String qualityGrade,
    required int estimatedDeliveryDays,
    String? specialNotes,
    required double fraudScore,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/trades/rfq/$rfqId/bid',
        data: {
          'offeredPrice': offeredPrice,
          'quantity': quantity,
          'qualityGrade': qualityGrade,
          'estimatedDeliveryDays': estimatedDeliveryDays,
          'specialNotes': specialNotes,
          'fraudScore': fraudScore,
          'status': 'PENDING',
        },
      );

      return Bid.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create bid: $e');
    }
  }
}
