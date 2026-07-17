import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/lots_provider.dart';
import '../../../domain/models/lot_model.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Cocoa',
    'Coffee',
    'Cashews',
    'Rubber'
  ];

  @override
  Widget build(BuildContext context) {
    final lotsAsync = _selectedCategory == 'All'
        ? ref.watch(lotsProvider)
        : ref.watch(lotByCategoryProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AfriGo Marketplace'),
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(lotsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? Colors.green : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Lots list
          Expanded(
            child: lotsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Failed to load products'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(lotsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (lots) => lots.isEmpty
                  ? const Center(child: Text('No products found'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(lotsProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: lots.length,
                        itemBuilder: (context, index) {
                          return LotCard(lot: lots[index]);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class LotCard extends StatefulWidget {
  final LotModel lot;

  const LotCard({required this.lot, super.key});

  @override
  State<LotCard> createState() => _LotCardState();
}

class _LotCardState extends State<LotCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          context.push('/lot/${widget.lot.id}');
        },
        onTapCancel: () => _controller.reverse(),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (widget.lot.imageUrl != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    widget.lot.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(
                            child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                      child: Icon(Icons.image_not_supported, size: 48)),
                ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lot.productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From: ${widget.lot.sellerName}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text(
                              '${widget.lot.sellerRating.toStringAsFixed(1)}★',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.lot.pricePerUnit.toStringAsFixed(2)}/${widget.lot.unit}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.lot.quantity.toStringAsFixed(0)} ${widget.lot.unit}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.push('/lot/${widget.lot.id}');
                            },
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: const Text('View Details'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/bid/${widget.lot.id}');
                            },
                            icon: const Icon(Icons.sell, size: 16),
                            label: const Text('Make Offer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
