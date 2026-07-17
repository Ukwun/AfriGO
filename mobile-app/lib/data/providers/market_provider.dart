import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(apiClient: ApiClient()),
);

final marketRateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final response =
      await ref.watch(apiServiceProvider).get('/api/market/rates/cocoa');
  return {
    'min': (response['minPrice'] as num).toDouble(),
    'max': (response['maxPrice'] as num).toDouble(),
    'average': (response['averagePrice'] as num).toDouble(),
    'change': (response['priceChange'] as num).toDouble(),
    'updated': response['lastUpdated'],
  };
});

final buyerBalanceProvider = FutureProvider<double>((ref) async {
  final response =
      await ref.watch(apiServiceProvider).get('/api/wallet/balance');
  return (response['balance'] as num).toDouble();
});

final buyerTransactionHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await ref
      .watch(apiServiceProvider)
      .get('/api/wallet/transactions?limit=20');
  final transactions = response['transactions'];
  if (transactions is! List) return const [];
  return transactions
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
});

final sellerProfileProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, supplierId) async {
  final response =
      await ref.watch(apiServiceProvider).get('/api/users/$supplierId/profile');
  return Map<String, dynamic>.from(response);
});

final productDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) async {
  final response =
      await ref.watch(apiServiceProvider).get('/api/products/$productId');
  return Map<String, dynamic>.from(response);
});

class RealTimeMarketService {
  Stream<Map<String, dynamic>> getMarketUpdates() async* {
    while (true) {
      final response = await ApiClient().get('/analytics/market');
      final data = response['data'];
      if (data is Map) yield Map<String, dynamic>.from(data);
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }
}

final realTimeMarketProvider = StreamProvider<Map<String, dynamic>>(
  (ref) => RealTimeMarketService().getMarketUpdates(),
);
