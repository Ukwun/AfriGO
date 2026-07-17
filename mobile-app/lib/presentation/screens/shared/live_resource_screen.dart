import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/dashboard_records_provider.dart';

class LiveResourceScreen extends ConsumerWidget {
  const LiveResourceScreen({
    super.key,
    required this.resource,
    required this.title,
    required this.emptyMessage,
    this.detailRoute,
  });

  final String resource;
  final String title;
  final String emptyMessage;
  final String? detailRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(dashboardRecordsProvider(resource));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardRecordsProvider(resource));
          await ref.read(dashboardRecordsProvider(resource).future);
        },
        child: records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(children: [
            const SizedBox(height: 140),
            _Message(
              icon: Icons.cloud_off_outlined,
              title: 'Unable to refresh $title',
              message: 'Firebase could not refresh this activity.',
              action: () =>
                  ref.invalidate(dashboardRecordsProvider(resource)),
            ),
          ]),
          data: (items) => items.isEmpty
              ? ListView(children: [
                  const SizedBox(height: 140),
                  _Message(
                    icon: Icons.inbox_outlined,
                    title: 'No ${title.toLowerCase()} yet',
                    message: emptyMessage,
                  ),
                ])
              : LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1000
                      ? 3
                      : width >= 620
                          ? 2
                          : 1;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 150,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ResourceCard(
                        item: item,
                        onTap: detailRoute == null
                            ? null
                            : () => context.push(
                                  '$detailRoute/${Uri.encodeComponent(item['id'].toString())}',
                                ),
                      );
                    },
                  );
                }),
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.item, this.onTap});
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  String first(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final title = first(
      const ['title', 'productName', 'commodity', 'reference', 'trackingNumber'],
      'AfriGO record',
    );
    final status = first(const ['status', 'stage'], 'pending');
    final detail = first(
      const ['description', 'destination', 'quantity', 'amount', 'currency'],
      'No additional details',
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .96, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right),
                ]),
                const Spacer(),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Icon(icon, size: 52),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: action,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ]),
      );
}
