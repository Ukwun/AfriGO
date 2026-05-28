import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/lot.dart';
import '../../../data/providers/marketplace_provider.dart';
import '../../../data/providers/websocket_provider.dart';
import '../../../data/services/marketplace_service.dart';
import 'widgets/product_card.dart';
import 'widgets/marketplace_filter_sheet.dart';
import 'product_detail_screen.dart';

/// Marketplace & Search Screen
/// Connects to real backend APIs with live data
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedView = 'list'; // 'list' or 'map'
  bool _showFilters = false;

  // Filter state
  String? _selectedProductType;
  String? _selectedQualityGrade;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedLocation;
  double? _minSellerRating;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Connect to WebSocket for real-time updates
    Future.microtask(() {
      ref.read(websocketServiceProvider).connect();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterSheet,
            tooltip: 'Advanced filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // View toggle & sort
          _buildViewToggle(),

          // Tab bar for product categories
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'All Products'),
                Tab(text: 'Following'),
                Tab(text: 'Saved'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedView == 'list' ? _buildListView() : _buildMapView(),
          ),
        ],
      ),
    );
  }

  /// Search bar with real-time search
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // Real-time search - queries live database
          ref.read(marketplaceProvider.notifier).searchProducts(value);
        },
        decoration: InputDecoration(
          hintText: 'Search products, sellers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(marketplaceProvider.notifier).clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  /// View toggle (list/map) and sorting
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.list,
                  color: _selectedView == 'list' ? Colors.green : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedView = 'list'),
                tooltip: 'List view',
              ),
              IconButton(
                icon: Icon(
                  Icons.map,
                  color: _selectedView == 'map' ? Colors.green : Colors.grey,
                ),
                onPressed: () => setState(() => _selectedView = 'map'),
                tooltip: 'Map view (real geolocation data)',
              ),
            ],
          ),
          // Sort dropdown
          DropdownButton<String>(
            hint: const Text('Sort'),
            items: [
              const DropdownMenuItem(
                value: 'best_price',
                child: Text('Best Price'),
              ),
              const DropdownMenuItem(
                value: 'best_seller',
                child: Text('Best Seller Rating'),
              ),
              const DropdownMenuItem(
                value: 'fastest',
                child: Text('Fastest Delivery'),
              ),
              const DropdownMenuItem(
                value: 'highest_quality',
                child: Text('Highest Quality'),
              ),
              const DropdownMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(marketplaceProvider.notifier).sortProducts(value);
              }
            },
          ),
        ],
      ),
    );
  }

  /// List view showing product cards
  Widget _buildListView() {
    return Consumer(
      builder: (context, ref, child) {
        final lotsAsync = ref.watch(marketplaceProvider);

        return lotsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(marketplaceProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (lots) {
            if (lots.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No products found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try adjusting your filters or search',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lots.length,
              itemBuilder: (context, index) {
                final lot = lots[index];
                return ProductCard(
                  lot: lot,
                  onTap: () {
                    context.push('/marketplace/product/${lot.id}');
                  },
                  onMakeOffer: () {
                    _showMakeOfferDialog(context, lot);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Map view showing products by geolocation (real geolocation data)
  Widget _buildMapView() {
    return Consumer(
      builder: (context, ref, child) {
        final lotsAsync = ref.watch(marketplaceProvider);

        return lotsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Map error: $error')),
          data: (lots) {
            final markers = lots
                .where((lot) => lot.latitude != null && lot.longitude != null)
                .map(
                  (lot) => Marker(
                    markerId: MarkerId(lot.id),
                    position: LatLng(lot.latitude!, lot.longitude!),
                    infoWindow: InfoWindow(
                      title: lot.productName,
                      snippet:
                          '${lot.quantity}kg @ \$${lot.price}/kg - Trust: ${lot.sellerTrustScore?.toStringAsFixed(1)}★',
                    ),
                    onTap: () {
                      context.push('/marketplace/product/${lot.id}');
                    },
                  ),
                )
                .toSet();

            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 20), // Africa center
                zoom: 4,
              ),
              markers: markers,
              compassEnabled: true,
              zoomControlsEnabled: true,
            );
          },
        );
      },
    );
  }

  /// Show filter sheet (Advanced filters)
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return MarketplaceFilterSheet(
          onApply: (filters) {
            setState(() {
              _selectedProductType = filters['productType'];
              _selectedQualityGrade = filters['qualityGrade'];
              _minPrice = filters['minPrice'];
              _maxPrice = filters['maxPrice'];
              _selectedLocation = filters['location'];
              _minSellerRating = filters['minSellerRating'];
            });
            ref.read(marketplaceProvider.notifier).applyFilters(filters);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  /// Make offer dialog
  void _showMakeOfferDialog(BuildContext context, Lot lot) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController(text: lot.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Make an Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product: ${lot.productName}'),
              Text('Seller: ${lot.sellerName} (${lot.sellerTrustScore}★)'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per kg (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // FUNCTIONAL [MAKE OFFER] button
                // Runs real fraud check, creates trade, broadcasts to seller in real-time
                _submitOffer(
                  context,
                  lot,
                  double.parse(quantityController.text),
                  double.parse(priceController.text),
                );
              },
              child: const Text('Submit Offer'),
            ),
          ],
        );
      },
    );
  }

  /// Submit offer - REAL backend call
  Future<void> _submitOffer(
    BuildContext context,
    Lot lot,
    double quantity,
    double price,
  ) async {
    try {
      final marketplaceService = ref.read(marketplaceServiceProvider);

      // Call real backend API
      // This triggers:
      // 1. Fraud detection (8 patterns checked)
      // 2. Activity logging (immutable)
      // 3. Trade creation
      // 4. Real-time WebSocket broadcast to seller
      final trade = await marketplaceService.createRFQ(
        productId: lot.id,
        sellerId: lot.sellerId,
        quantity: quantity,
        offeredPrice: price,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Offer submitted! Seller will respond within 2 hours',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to trade details
        context.push('/trades/${trade.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
