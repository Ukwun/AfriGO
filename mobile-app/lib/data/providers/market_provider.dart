import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// MARKET & BALANCE PROVIDERS
/// Real-time market data and wallet information

/// Get current market rate for a commodity
final marketRateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/market/rates/cocoa');
    return {
      'min': (response['minPrice'] as num).toDouble(),
      'max': (response['maxPrice'] as num).toDouble(),
      'average': (response['averagePrice'] as num).toDouble(),
      'change': (response['priceChange'] as num).toDouble(),
      'updated': response['lastUpdated'] ?? DateTime.now().toString(),
    };
  } catch (error) {
    print('❌ Error loading market rates: $error');
    // Fallback values
    return {
      'min': 10.0,
      'max': 15.0,
      'average': 12.5,
      'change': 0.5,
      'updated': DateTime.now().toString(),
    };
  }
});

/// Get buyer's current wallet balance
final buyerBalanceProvider = FutureProvider<double>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/wallet/balance');
    return (response['balance'] as num).toDouble();
  } catch (error) {
    print('❌ Error loading balance: $error');
    return 0.0;
  }
});

/// Get buyer's transaction history for fraud scoring
final buyerTransactionHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/wallet/transactions?limit=20');
    final transactions = (response['transactions'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return transactions;
  } catch (error) {
    return [];
  }
});

/// Get seller's profile for offer screen
final sellerProfileProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, sellerId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/users/$sellerId/profile');
    return {
      'id': response['id'],
      'name': response['fullName'],
      'rating': (response['averageRating'] as num).toDouble(),
      'completedTrades': response['completedTrades'],
      'trustScore': response['trustScore'],
      'responseTime': response['responseTime'],
      'acceptanceRate': response['acceptanceRate'],
    };
  } catch (error) {
    return {
      'id': sellerId,
      'name': 'Seller',
      'rating': 0.0,
      'completedTrades': 0,
      'trustScore': 0,
      'responseTime': 'Unknown',
      'acceptanceRate': 0.0,
    };
  }
});

/// Get product details for offer
final productDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, productId) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/products/$productId');
    return {
      'id': response['id'],
      'name': response['name'],
      'description': response['description'],
      'commodity': response['commodity'],
      'askingPrice': (response['askingPrice'] as num).toDouble(),
      'availableQuantity': (response['availableQuantity'] as num).toDouble(),
      'grade': response['grade'],
      'location': response['location'],
      'sellerId': response['sellerId'],
    };
  } catch (error) {
    return {};
  }
});

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Stream for real-time market updates
class RealTimeMarketService {
  // Would connect to WebSocket for real-time price updates
  // For now, returns periodic updates
  Stream<Map<String, dynamic>> getMarketUpdates() async* {
    while (true) {
      yield {
        'price': 12.5,
        'change': 0.15,
        'timestamp': DateTime.now(),
      };
      await Future.delayed(Duration(seconds: 30)); // Update every 30 seconds
    }
  }
}

/// Real-time market provider
final realTimeMarketProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = RealTimeMarketService();
  return service.getMarketUpdates();
});
