import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lots_provider.dart';
import '../../../models/lots_model.dart';

class MarketplaceSearchScreen extends ConsumerStatefulWidget {
  const MarketplaceSearchScreen({super.key});

  @override
  ConsumerState<MarketplaceSearchScreen> createState() =>
      _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState
    extends ConsumerState<MarketplaceSearchScreen> {
  late TextEditingController searchController;
  String selectedCategory = '';
  String selectedCountry = '';
  String selectedGrade = '';
  double minPrice = 0;
  double maxPrice = 500;
  bool showAdvancedFilters = false;

  final List<String> categories = [
    'Cocoa',
    'Coffee',
    'Cashew',
    'Grains',
    'Vegetables',
    'Spices',
    'Oils',
  ];

  final List<String> countries = [
    'Ghana',
    'Ivory Coast',
    'Kenya',
    'Uganda',
    'Cameroon',
    'Nigeria',
    'Ethiopia',
  ];

  final List<String> grades = ['A', 'B', 'C'];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFilterParams() {
    return {
      'search': searchController.text,
      'category': selectedCategory.isEmpty ? null : selectedCategory,
      'country': selectedCountry.isEmpty ? null : selectedCountry,
      'grade': selectedGrade.isEmpty ? null : selectedGrade,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'page': 1,
      'limit': 20,
    };
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      selectedCategory = '';
      selectedCountry = '';
      selectedGrade = '';
      minPrice = 0;
      maxPrice = 500;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search products, batch number, origin...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => searchController.clear());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Filter Toggle & Active Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(
                      () => showAdvancedFilters = !showAdvancedFilters),
                  child: Row(
                    children: [
                      Icon(
                        showAdvancedFilters
                            ? Icons.filter_list
                            : Icons.filter_list_off,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Filters',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (selectedCategory.isNotEmpty ||
                    selectedCountry.isNotEmpty ||
                    selectedGrade.isNotEmpty ||
                    minPrice > 0 ||
                    maxPrice < 500)
                  GestureDetector(
                    onTap: _clearFilters,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Advanced Filters Panel
          if (showAdvancedFilters)
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(
                              () => selectedCategory = selected ? cat : '');
                        },
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Country Filter
                  const Text(
                    'Origin Country',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: countries.map((country) {
                      final isSelected = selectedCountry == country;
                      return FilterChip(
                        label: Text(country),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(
                              () => selectedCountry = selected ? country : '');
                        },
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Grade Filter
                  const Text(
                    'Grade Level',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: grades.map((grade) {
                      final isSelected = selectedGrade == grade;
                      return FilterChip(
                        label: Text('Grade $grade'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => selectedGrade = selected ? grade : '');
                        },
                        backgroundColor:
                            isSelected ? Colors.blue : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Price Range Slider
                  const Text(
                    'Price Range: ₵${minPrice.toStringAsFixed(0)} - ₵${maxPrice.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(minPrice, maxPrice),
                    min: 0,
                    max: 500,
                    labels: RangeLabels(
                      minPrice.round().toString(),
                      maxPrice.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        minPrice = values.start;
                        maxPrice = values.end;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Active Filters Display
          if (selectedCategory.isNotEmpty ||
              selectedCountry.isNotEmpty ||
              selectedGrade.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (selectedCategory.isNotEmpty)
                    Chip(
                      label: Text('Category: $selectedCategory'),
                      onDeleted: () => setState(() => selectedCategory = ''),
                    ),
                  if (selectedCountry.isNotEmpty)
                    Chip(
                      label: Text('Country: $selectedCountry'),
                      onDeleted: () => setState(() => selectedCountry = ''),
                    ),
                  if (selectedGrade.isNotEmpty)
                    Chip(
                      label: Text('Grade: $selectedGrade'),
                      onDeleted: () => setState(() => selectedGrade = ''),
                    ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final filterParams = _buildFilterParams();

                return FutureBuilder<List<LotModel>>(
                  future: ref.read(lotsServiceProvider).listLots(filterParams),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text('Error loading products'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final lots = snapshot.data ?? [];

                    if (lots.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No products found'),
                            const SizedBox(height: 8),
                            const Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _clearFilters,
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
                        return _SearchResultCard(
                          lot: lot,
                          onTap: () => context.pushNamed('lot-detail',
                              arguments: lot.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final LotModel lot;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.lot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image Placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lot.productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Grade ${lot.gradeLevel}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot.originCountry,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₵${lot.pricePerUnit.toStringAsFixed(2)}/kg',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          '${lot.quantity.toStringAsFixed(0)} kg available',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // More button
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
