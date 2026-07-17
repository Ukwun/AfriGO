import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/colors.dart';
import '../providers/dashboard_records_provider.dart';
import 'dashboard_role.dart';
import 'motion_system.dart';
import 'role_dashboard_shell.dart';

class DashboardFeed {
  const DashboardFeed(
      {required this.resource, required this.title, required this.route});
  final String resource;
  final String title;
  final String route;
}

class ProductionDashboard extends ConsumerWidget {
  const ProductionDashboard({
    super.key,
    required this.role,
    required this.headline,
    required this.description,
    required this.actionLabel,
    required this.actionRoute,
    required this.feeds,
  });

  final DashboardRole role;
  final String headline;
  final String description;
  final String actionLabel;
  final String actionRoute;
  final List<DashboardFeed> feeds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleDashboardShell(
      role: role,
      child: RefreshIndicator(
        onRefresh: () async {
          for (final feed in feeds) {
            ref.invalidate(dashboardRecordsProvider(feed.resource));
          }
          await Future.wait(feeds.map((feed) =>
              ref.read(dashboardRecordsProvider(feed.resource).future)));
        },
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList.list(children: [
              FadeInTransition(
                  child: Text(headline,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800))),
              const SizedBox(height: 6),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.push(actionRoute),
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
              const SizedBox(height: 28),
              ...feeds.map((feed) => _FeedSection(feed: feed)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FeedSection extends ConsumerWidget {
  const _FeedSection({required this.feed});
  final DashboardFeed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardRecordsProvider(feed.resource));
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(feed.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700))),
          TextButton(
              onPressed: () => context.push(feed.route),
              child: const Text('View all')),
        ]),
        const SizedBox(height: 10),
        state.when(
          loading: () => const Card(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()))),
          error: (error, _) => Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    const Icon(Icons.cloud_off_outlined,
                        color: AppColors.error),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Text(
                            'Could not load live data. Check your connection and try again.')),
                    IconButton(
                        onPressed: () => ref.invalidate(
                            dashboardRecordsProvider(feed.resource)),
                        icon: const Icon(Icons.refresh_rounded)),
                  ]))),
          data: (records) => records.isEmpty
              ? Card(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(children: [
                        const Icon(Icons.inbox_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(
                                'No ${feed.title.toLowerCase()} yet. New activity will appear here automatically.')),
                      ])))
              : LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 560
                          ? 2
                          : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length > 6 ? 6 : records.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 142,
                    ),
                    itemBuilder: (context, index) =>
                        _RecordCard(feed: feed, record: records[index]),
                  );
                }),
        ),
      ]),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.feed, required this.record});
  final DashboardFeed feed;
  final Map<String, dynamic> record;

  String _first(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = record[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final id = _first(const ['id', '_id'], '');
    final title = _first(const [
      'title',
      'name',
      'commodity',
      'product',
      'reference',
      'trackingNumber'
    ], feed.title);
    final status = _first(const ['status', 'stage'], 'active');
    final detail = _first(
        const ['description', 'quantity', 'destination', 'location', 'amount'],
        'Tap to view details');
    final destination = switch (feed.resource) {
      'rfqs' ||
      'lots' ||
      'contracts' ||
      'shipments' =>
        '${feed.route}/detail/${Uri.encodeComponent(id)}',
      _ => feed.route,
    };
    return ScaleInTransition(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: id.isEmpty ? null : () => context.push(destination),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700))),
                const Icon(Icons.chevron_right_rounded),
              ]),
              const Spacer(),
              Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(status.toUpperCase(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}
