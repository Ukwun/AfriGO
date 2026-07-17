import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExporterDossiersScreen extends ConsumerStatefulWidget {
  const ExporterDossiersScreen({super.key});

  @override
  ConsumerState<ExporterDossiersScreen> createState() =>
      _ExporterDossiersScreenState();
}

class _ExporterDossiersScreenState
    extends ConsumerState<ExporterDossiersScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Dossiers'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Approved', 'Pending', 'Rejected']
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f),
                            selected: _filter == f.toLowerCase(),
                            onSelected: (selected) =>
                                setState(() => _filter = f.toLowerCase()),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DOS-2026-00${index + 1}',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  Text(['Coffee', 'Cocoa', 'Spices'][index],
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[600])),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: [
                                    Colors.green,
                                    Colors.orange,
                                    Colors.green
                                  ][index]
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ['Approved', 'Pending', 'Approved'][index],
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: [
                                      Colors.green,
                                      Colors.orange,
                                      Colors.green
                                    ][index],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Rotterdam, Netherlands',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text('Documentation',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                            value: [1.0, 0.75, 1.0][index],
                                            minHeight: 6))
                                  ])),
                              const SizedBox(width: 12),
                              Text(
                                  '${(([
                                        1.0,
                                        0.75,
                                        1.0
                                      ][index]) * 100).toInt()}%',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
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
