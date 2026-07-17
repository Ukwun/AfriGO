import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExporterTrackingScreen extends ConsumerWidget {
  const ExporterTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Tracking'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.flight_takeoff,
                                        color: Colors.blue, size: 24),
                                    const SizedBox(height: 8),
                                    Text('In Transit',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: Colors.grey[600])),
                                    Text('5',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.blue))
                                  ])))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.done_all,
                                        color: Colors.green, size: 24),
                                    const SizedBox(height: 8),
                                    Text('Delivered',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: Colors.grey[600])),
                                    Text('23',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green))
                                  ])))),
                ],
              ),
              const SizedBox(height: 24),
              Text('Active Shipments',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left),
              const SizedBox(height: 12),
              Column(
                children: List.generate(
                  3,
                  (index) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('EXP-SHIP-00${index + 1}',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700)),
                                      Text(
                                          [
                                            'Rotterdam',
                                            'Hamburg',
                                            'Singapore'
                                          ][index],
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey[600]))
                                    ]),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: index == 2
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                        index == 2 ? 'DELIVERED' : 'IN TRANSIT',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                color: index == 2
                                                    ? Colors.green
                                                    : Colors.blue,
                                                fontWeight: FontWeight.w600)))
                              ]),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Product',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600])),
                                Text(['Coffee', 'Cocoa', 'Spices'][index],
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500))
                              ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                  value: [0.65, 0.45, 1.0][index],
                                  minHeight: 6)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
