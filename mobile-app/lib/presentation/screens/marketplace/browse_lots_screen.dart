import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/lot_model.dart';
import '../../../services/api_service.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/motion_system.dart';

// Lots provider
final lotsProvider = FutureProvider.autoDispose<List<LotModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getLots();
});

// Search state
final searchQueryProvider = StateProvider<String>((ref) => '');
final sortByProvider = StateProvider<String>((ref) => 'newest');
final minPriceProvider = StateProvider<double>((ref) => 0);
final maxPriceProvider = StateProvider<double>((ref) => 10000);

class BrowseLotsScreen extends ConsumerWidget {
  const BrowseLotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(lotsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortBy = ref.watch(sortByProvider);
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);

    // Filter and sort lots
    final filteredLots = lotsAsync.when(
      data: (lots) {
        var filtered = lots;

        // Filter by search
        if (searchQuery.isNotEmpty) {
          filtered = filtered
              .where((lot) =>
                  lot.productName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  lot.description
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();
        }

        // Filter by price
        filtered = filtered
            .where((lot) =>
                lot.pricePerUnit >= minPrice && lot.pricePerUnit <= maxPrice)
            .toList();

        // Sort
        if (sortBy == 'priceLow') {
          filtered.sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
        } else if (sortBy == 'priceHigh') {
          filtered.sort((a, b) => b.pricePerUnit.compareTo(a.pricePerUnit));
        } else if (sortBy == 'ratings') {
          filtered.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        } else {
          // newest (default)
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        return filtered;
      },
      error: (err, stack) => [],
      loading: () => [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Lots'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Section
            _buildSearchAndFilterSection(context, ref, sortBy),

            // Lots Grid
            Expanded(
              child: lotsAsync.when(
                data: (lots) {
                  if (filteredLots.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No lots found',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredLots.length,
                    itemBuilder: (context, index) {
                      final lot = filteredLots[index];
                      return ScaleInTransition(
                        duration: const Duration(milliseconds: 250),
                        beginScale: 0.85,
                        child: _buildLotCard(context, lot),
                      );
                    },
                  );
                },
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $err'),
                    ],
                  ),
                ),
                loading: () => PageSkeletonLoader(
                  elements: [
                    SkeletonElement(type: SkeletonType.card, height: 180),
                    SkeletonElement(type: SkeletonType.card, height: 180),
                    SkeletonElement(type: SkeletonType.card, height: 180),
                    SkeletonElement(type: SkeletonType.card, height: 180),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(
      BuildContext context, WidgetRef ref, String sortBy) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Search lots...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),

          // Filter and Sort Buttons
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: DropdownButton<String>(
                  value: sortBy,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(
                        value: 'priceLow', child: Text('Price: Low to High')),
                    DropdownMenuItem(
                        value: 'priceHigh', child: Text('Price: High to Low')),
                    DropdownMenuItem(
                        value: 'ratings', child: Text('Top Rated')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(sortByProvider.notifier).state = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Filter button - Updated with AnimatedOutlinedButton
              AnimatedOutlinedButton(
                label: 'Filter',
                onPressed: () {
                  _showFilterBottomSheet(context, ref);
                },
                borderColor: AppTheme.primaryGreen,
                textColor: AppTheme.primaryGreen,
                width: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, LotModel lot) {
    return ModernCard(
      borderRadius: 16,
      isFloating: true,
      onTap: () {
        context.push('/lots/${lot.id}');
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with overlay
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[200],
                  image: lot.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(lot.images[0]),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: lot.images.isEmpty
                    ? const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 32),
                      )
                    : null,
              ),
              // Rating Badge Overlay
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${lot.averageRating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product name
                  Text(
                    lot.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Sora',
                    ),
                  ),

                  // Price and availability
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${lot.pricePerUnit.toStringAsFixed(2)} per ${lot.quantityUnit}',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lot.quantity} ${lot.quantityUnit} available',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixText: '\$',
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0;
                      ref.read(minPriceProvider.notifier).state = price;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixText: '\$',
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 10000;
                      ref.read(maxPriceProvider.notifier).state = price;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
