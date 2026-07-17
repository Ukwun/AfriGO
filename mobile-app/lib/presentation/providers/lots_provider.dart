// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_client.dart';
import '../../domain/models/lot_model.dart';

final lotsProvider = FutureProvider<List<LotModel>>((ref) async {
  final apiClient = ApiClient();
  try {
    final response = await apiClient.get('/lots?scope=marketplace');
    final List<dynamic> lotsData = response['data'] ?? [];
    return lotsData
        .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('❌ Error fetching lots: $e');
    rethrow;
  }
});

final lotByCategoryProvider =
    FutureProvider.family<List<LotModel>, String>((ref, category) async {
  final apiClient = ApiClient();
  try {
    final response = await apiClient.get(
      '/lots?scope=marketplace&category=${Uri.encodeQueryComponent(category)}',
    );
    final List<dynamic> lotsData = response['data'] ?? [];
    return lotsData
        .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
        .where(
          (lot) => lot.productType.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  } catch (e) {
    print('❌ Error fetching lots by category: $e');
    rethrow;
  }
});

final lotDetailProvider =
    FutureProvider.family<LotModel, String>((ref, lotId) async {
  final apiClient = ApiClient();
  try {
    final response = await apiClient.get('/lots/$lotId');
    return LotModel.fromJson(response);
  } catch (e) {
    print('❌ Error fetching lot: $e');
    rethrow;
  }
});
