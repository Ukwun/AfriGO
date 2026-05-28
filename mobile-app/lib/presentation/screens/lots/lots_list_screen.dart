import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/lots_model.dart';
import '../providers/lots_provider.dart';

class LotsListScreen extends ConsumerStatefulWidget {
  const LotsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LotsListScreen> createState() => _LotsListScreenState();
}

class _LotsListScreenState extends ConsumerState<LotsListScreen> {
  int currentPage = 1;
  String? selectedCategory;
  String? selectedCountry;
  double? minPrice;
  double? maxPrice;

  void _applyFilters() {
    setState(() {
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = {
      'page': currentPage,
      'limit': 20,
      if (selectedCategory != null) 'category': selectedCategory,
      if (selectedCountry != null) 'originCountry': selectedCountry,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
    };

    final lotsAsync = ref.watch(lotsListProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Products'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Category'),
                    onSelected: (selected) {
                      // Show category filter dialog
                      _showCategoryFilter();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Country'),
                    onSelected: (selected) {
                      // Show country filter dialog
                      _showCountryFilter();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Price'),
                    onSelected: (selected) {
                      // Show price filter dialog
                      _showPriceFilter();
                    },
                  ),
                ],
              ),
            ),
          ),
          // Lots list
          Expanded(
            child: lotsAsync.when(
              data: (result) {
                final lots = result['data'] as List<LotModel>;
                final total = result['total'] as int;

                if (lots.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No products found'),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _applyFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: lots.length,
                  itemBuilder: (context, index) {
                    final lot = lots[index];
                    return LotCard(lot: lot);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    // Implement category filter dialog
  }

  void _showCountryFilter() {
    // Implement country filter dialog
  }

  void _showPriceFilter() {
    // Implement price filter dialog
  }
}

class LotCard extends StatelessWidget {
  final LotModel lot;

  const LotCard({Key? key, required this.lot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: lot.images.isNotEmpty
            ? Image.network(
                lot.images.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image_not_supported),
        title: Text(lot.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lot.originCountry} • Grade ${lot.gradeLevel}'),
            Text(
                '\$${lot.pricePerUnit.toStringAsFixed(2)}/${lot.quantityUnit}'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${lot.quantity.toInt()} ${lot.quantityUnit}'),
            Text(
              lot.status.toUpperCase(),
              style: TextStyle(
                color: lot.status == 'active' ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/lot-detail', arguments: lot.id);
        },
      ),
    );
  }
}
