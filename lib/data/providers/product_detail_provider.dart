import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/lot.dart';
import '../services/marketplace_service.dart';

/// Product Detail Provider
/// Fetches detailed lot information with all backend data
final productDetailProvider = FutureProvider.family<Lot, String>((
  ref,
  productId,
) async {
  final marketplaceService = ref.watch(marketplaceServiceProvider);

  // REAL backend call to get complete product details
  // Includes:
  // - Real trust score from TrustScoringService
  // - Real fraud detection score
  // - Immutable quality test results
  // - Real seller verification status
  // - Real buyer reviews
  // - All photos and documents
  return await marketplaceService.getProductDetail(productId);
});
