import 'package:riverpod/riverpod.dart';
import '../../domain/models/trade.dart';
import '../../domain/models/bid.dart';
import '../services/trade_service.dart';

/// Riverpod Providers for Trading Module
/// Real-time state management with WebSocket synchronization

/// Active trades provider (filtered by status)
/// Real-time updates via WebSocket TRADE_STATUS_CHANGED events
final activeTradesProvider = FutureProvider.family<List<Trade>, String>((
  ref,
  status,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getActiveTrades(status);
});

/// RFQ list provider (all RFQs for current buyer)
/// Real-time updates via WebSocket RFQ_CREATED and BID_RECEIVED events
final rfqListProvider = FutureProvider<List<Trade>>((ref) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getRFQs();
});

/// RFQ detail provider (single RFQ with all bids)
/// Real-time updates via WebSocket for new bids
final rfqDetailProvider = FutureProvider.family<Trade, String>((
  ref,
  rfqId,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getRFQDetail(rfqId);
});

/// Bids for RFQ provider
/// Real-time updates via WebSocket BID_RECEIVED events
/// Latency: <500ms typical
final bidsForRFQProvider = FutureProvider.family<List<Bid>, String>((
  ref,
  rfqId,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getBidsForRFQ(rfqId);
});

/// Trade detail provider (single active trade)
/// Real-time updates via WebSocket for messages and status changes
final tradeDetailProvider = FutureProvider.family<Trade, String>((
  ref,
  tradeId,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getTradeDetail(tradeId);
});

/// Messages for trade provider
/// Real-time updates via WebSocket MESSAGE_RECEIVED events
final tradeMessagesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      tradeId,
    ) async {
      final tradeService = ref.watch(tradeServiceProvider);
      return tradeService.getMessages(tradeId);
    });

/// Activity log for trade provider (immutable)
final tradeActivityLogProvider = FutureProvider.family<List<String>, String>((
  ref,
  tradeId,
) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getActivityLog(tradeId);
});

/// Trust impact provider
/// Shows how trade affects buyer's trust score
final tradeTrustImpactProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tradeId) async {
      final tradeService = ref.watch(tradeServiceProvider);
      return tradeService.getTrustImpact(tradeId);
    });

/// Fraud score provider
/// Used for display and validation
final tradeFraudScoreProvider = FutureProvider.family<double, String>((
  ref,
  tradeId,
) async {
  final trade = await ref.watch(tradeDetailProvider(tradeId).future);
  return trade.fraudScore ?? 0.0;
});

/// Open trades count (for badge)
final openTradesCountProvider = FutureProvider<int>((ref) async {
  final trades = await ref.watch(activeTradesProvider('OPEN').future);
  return trades.length;
});

/// Negotiating trades count (for badge)
final negotiatingTradesCountProvider = FutureProvider<int>((ref) async {
  final trades = await ref.watch(activeTradesProvider('NEGOTIATING').future);
  return trades.length;
});

/// Accepted trades count (for badge)
final acceptedTradesCountProvider = FutureProvider<int>((ref) async {
  final trades = await ref.watch(activeTradesProvider('ACCEPTED').future);
  return trades.length;
});

/// Completed trades count (for badge)
final completedTradesCountProvider = FutureProvider<int>((ref) async {
  final trades = await ref.watch(activeTradesProvider('COMPLETED').future);
  return trades.length;
});

/// All tabs data provider
/// Combines all status tabs into one query
final allTradesTabsProvider = FutureProvider<Map<String, List<Trade>>>((
  ref,
) async {
  final tradeService = ref.watch(tradeServiceProvider);

  final results = await Future.wait([
    tradeService.getActiveTrades('OPEN'),
    tradeService.getActiveTrades('NEGOTIATING'),
    tradeService.getActiveTrades('ACCEPTED'),
    tradeService.getActiveTrades('COMPLETED'),
  ]);

  return {
    'OPEN': results[0],
    'NEGOTIATING': results[1],
    'ACCEPTED': results[2],
    'COMPLETED': results[3],
  };
});

/// Fraud detection provider
/// Detects fraud risk for specific trade operation
final fraudDetectionProvider =
    FutureProvider.family<double, Map<String, dynamic>>((ref, params) async {
      final tradeService = ref.watch(tradeServiceProvider);
      return tradeService.detectFraud(
        amount: params['amount'] as double,
        action: params['action'] as String,
      );
    });

/// Search RFQs provider
/// Allows filtering by product type or other criteria
final searchRFQsProvider = FutureProvider.family<List<Trade>, String>((
  ref,
  query,
) async {
  final allRFQs = await ref.watch(rfqListProvider.future);

  if (query.isEmpty) return allRFQs;

  return allRFQs.where((trade) {
    return trade.productType.toLowerCase().contains(query.toLowerCase());
  }).toList();
});
