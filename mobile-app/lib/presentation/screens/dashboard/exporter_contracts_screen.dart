import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExporterContractsScreen extends ConsumerWidget {
  const ExporterContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contracts = <Map<String, dynamic>>[
      {
        'id': 'CTR-001',
        'buyer': 'Buyer Corp',
        'product': 'Coffee',
        'value': '\$12,500',
        'progress': 0.75,
        'status': 'Active'
      },
      {
        'id': 'CTR-002',
        'buyer': 'Import LLC',
        'product': 'Cocoa',
        'value': '\$8,200',
        'progress': 0.45,
        'status': 'Active'
      },
      {
        'id': 'CTR-003',
        'buyer': 'Trade Inc',
        'product': 'Spices',
        'value': '\$15,800',
        'progress': 1.0,
        'status': 'Completed'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Contracts'), elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(contracts[index]['id'] as String,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(contracts[index]['status'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    '${contracts[index]['buyer']} • ${contracts[index]['product']}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                                value: contracts[index]['progress'] as double,
                                minHeight: 6))),
                    const SizedBox(width: 8),
                    Text(contracts[index]['value'] as String,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
