import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExporterWarehouseScreen extends ConsumerWidget {
  const ExporterWarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Warehouse'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7)
                      ]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Capacity',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('2,500 MT',
                        style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Used',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70)),
                              Text('1,650 MT (66%)',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600))
                            ])),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Available',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70)),
                              Text('850 MT (34%)',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600))
                            ])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Storage Slots',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
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
                                      Text('Slot A${index + 1}',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700)),
                                      Text('500 MT',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey[600]))
                                    ]),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text('ACTIVE',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600)))
                              ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                  value: [0.6, 0.84, 0.5][index],
                                  minHeight: 8)),
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
