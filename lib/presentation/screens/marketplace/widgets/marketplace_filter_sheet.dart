import 'package:flutter/material.dart';

/// Marketplace Filter Sheet
/// Advanced filters: product type, quality grade, location, price range, seller rating
class MarketplaceFilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const MarketplaceFilterSheet({Key? key, required this.onApply})
    : super(key: key);

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  String? _selectedProductType;
  String? _selectedQualityGrade;
  RangeValues _priceRange = const RangeValues(0, 10);
  String? _selectedLocation;
  double _minSellerRating = 0;

  final List<String> _productTypes = [
    'Cocoa',
    'Coffee',
    'Cashew',
    'Shea Butter',
    'Sesame',
    'Maize',
    'Cassava',
    'Beans',
    'Peas',
    'Rice',
  ];

  final List<String> _qualityGrades = [
    'Grade A',
    'Grade B',
    'Grade C',
    'Premium',
    'Standard',
  ];

  final List<String> _locations = [
    'Uganda',
    'Ghana',
    'Kenya',
    'Nigeria',
    'Tanzania',
    'Ivory Coast',
    'Rwanda',
    'Malawi',
    'Zambia',
    'Ethiopia',
    'Regional',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Type Filter
            const Text(
              'Product Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _productTypes.map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _selectedProductType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedProductType = selected ? type : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Quality Grade Filter
            const Text(
              'Quality Grade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _qualityGrades.map((grade) {
                return FilterChip(
                  label: Text(grade),
                  selected: _selectedQualityGrade == grade,
                  onSelected: (selected) {
                    setState(() {
                      _selectedQualityGrade = selected ? grade : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Price Range Filter
            const Text(
              'Price Range (\$ per kg)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 10,
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
              divisions: 100,
              labels: RangeLabels(
                '\$${_priceRange.start.toStringAsFixed(2)}',
                '\$${_priceRange.end.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(height: 24),

            // Location Filter
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _locations.map((location) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(location),
                      selected: _selectedLocation == location,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLocation = selected ? location : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Seller Rating Filter
            const Text(
              'Minimum Seller Rating',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _minSellerRating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: '${_minSellerRating.toStringAsFixed(1)}★',
                    onChanged: (value) {
                      setState(() {
                        _minSellerRating = value;
                      });
                    },
                  ),
                ),
                Text(
                  '${_minSellerRating.toStringAsFixed(1)}★',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedProductType = null;
                        _selectedQualityGrade = null;
                        _priceRange = const RangeValues(0, 10);
                        _selectedLocation = null;
                        _minSellerRating = 0;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply({
                        'productType': _selectedProductType,
                        'qualityGrade': _selectedQualityGrade,
                        'minPrice': _priceRange.start,
                        'maxPrice': _priceRange.end,
                        'location': _selectedLocation,
                        'minSellerRating': _minSellerRating,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
