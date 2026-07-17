import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuyerShipmentsScreen extends ConsumerStatefulWidget {
  const BuyerShipmentsScreen({super.key});

  @override
  ConsumerState<BuyerShipmentsScreen> createState() =>
      _BuyerShipmentsScreenState();
}

class _BuyerShipmentsScreenState extends ConsumerState<BuyerShipmentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FadeTransition(
        opacity:
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(theme),
                const SizedBox(height: 24),
                _buildShipmentsList(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _fadeController, curve: Curves.elasticOut),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_shipping,
                        color: Colors.blue, size: 24),
                    const SizedBox(height: 8),
                    Text('In Transit',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('5',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700, color: Colors.blue)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _fadeController, curve: Curves.elasticOut),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.done_all, color: Colors.green, size: 24),
                    const SizedBox(height: 8),
                    Text('Delivered',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('23',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700, color: Colors.green)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShipmentsList(ThemeData theme) {
    final shipments = <Map<String, dynamic>>[
      {
        'id': 'SHIP-001',
        'product': 'Coffee Beans',
        'from': 'Premium Ag.',
        'progress': 0.65,
        'status': 'In Transit'
      },
      {
        'id': 'SHIP-002',
        'product': 'Cocoa',
        'from': 'Fresh Produce',
        'progress': 1.0,
        'status': 'Delivered'
      },
      {
        'id': 'SHIP-003',
        'product': 'Spices',
        'from': 'Global Farms',
        'progress': 0.35,
        'status': 'Shipped'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Shipments',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            shipments.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(shipments[index]['id'] as String,
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: shipments[index]['progress'] == 1.0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(shipments[index]['status'] as String,
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: shipments[index]['progress'] == 1.0
                                        ? Colors.green
                                        : Colors.blue,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${shipments[index]['product']} from ${shipments[index]['from']}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: shipments[index]['progress'] as double,
                            minHeight: 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
