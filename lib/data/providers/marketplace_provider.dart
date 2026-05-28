import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/lot.dart';
import '../services/marketplace_service.dart';

/// Marketplace Provider
/// Manages real-time lot data, search, filters, sorting
class MarketplaceNotifier extends StateNotifier<AsyncValue<List<Lot>>> {
  final MarketplaceService _marketplaceService;
  String _currentSearch = '';
  Map<String, dynamic> _currentFilters = {};
  String _currentSort = 'newest';

  MarketplaceNotifier(this._marketplaceService)
    : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      state = const AsyncValue.loading();

      // Real backend call to get all lots
      // Connects to GET /api/lots with optional filters
      final lots = await _marketplaceService.getLots(
        search: _currentSearch,
        filters: _currentFilters,
        sortBy: _currentSort,
      );

      // Each lot contains REAL data:
      // - Real trust scores from TrustScoringService
      // - Real fraud risk scores from FraudDetectionService
      // - Real quality tests from immutable logs
      // - Real seller KYC status
      // - Real photos stored in cloud
      state = AsyncValue.data(lots);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Real-time search (queries live as user types)
  Future<void> searchProducts(String query) async {
    _currentSearch = query;
    await _loadProducts();
  }

  /// Clear search
  void clearSearch() {
    _currentSearch = '';
    _loadProducts();
  }

  /// Apply advanced filters
  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _currentFilters = filters;
    await _loadProducts();
  }

  /// Sort products
  Future<void> sortProducts(String sortBy) async {
    _currentSort = sortBy;
    await _loadProducts();
  }
}

/// Marketplace provider - real-time lots with search/filter/sort
final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, AsyncValue<List<Lot>>>((ref) {
      final service = ref.watch(marketplaceServiceProvider);
      return MarketplaceNotifier(service);
    });
