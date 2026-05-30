import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// FRAUD SCORE PROVIDER
/// Real-time fraud detection provider
/// Calculates fraud score based on: price, quantity, seller, buyer history
/// Updates immediately as user types price/quantity

final fraudScoreProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  final apiService = ref.watch(apiServiceProvider);

  final price = params['price'] as double?;
  final quantity = params['quantity'] as double?;
  final productId = params['productId'] as String;
  final sellerId = params['sellerId'] as String;

  if (price == null || quantity == null || price <= 0 || quantity <= 0) {
    // Return default low risk if inputs invalid
    return {
      'fraudScore': 0.0,
      'recommendation': 'ALLOW',
      'alerts': <String>[],
    };
  }

  try {
    // Call backend fraud detection endpoint
    final response = await apiService.post(
      '/api/fraud/check',
      body: {
        'price': price,
        'quantity': quantity,
        'productId': productId,
        'sellerId': sellerId,
      },
    );

    return {
      'fraudScore': (response['fraudScore'] as num).toDouble(),
      'recommendation': response['recommendation'] as String,
      'alerts': List<String>.from(response['alerts'] as List),
    };
  } catch (error) {
    print('❌ Fraud check error: $error');
    return {
      'fraudScore': 0.0,
      'recommendation': 'ALLOW',
      'alerts': <String>[],
    };
  }
});

/// MARKET RATE PROVIDER
/// Gets current market price for commodity

final marketRateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/market/rates');
    return {
      'min': response['min'],
      'max': response['max'],
      'average': response['average'],
    };
  } catch (error) {
    return {
      'min': 10.0,
      'max': 15.0,
      'average': 12.5,
    };
  }
});

/// BUYER BALANCE PROVIDER
/// Gets current buyer's escrow balance

final buyerBalanceProvider = FutureProvider<double>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.get('/api/user/balance');
    return (response['balance'] as num).toDouble();
  } catch (error) {
    return 0.0;
  }
});

/// API SERVICE PROVIDER
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// SUBMIT OFFER PROVIDER
final submitOfferProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, params) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final response = await apiService.post(
      '/api/trades/create',
      body: params,
    );

    return {
      'success': true,
      'tradeId': response['tradeId'],
      'message': 'Offer submitted successfully',
    };
  } catch (error) {
    return {
      'success': false,
      'error': error.toString(),
    };
  }
});
