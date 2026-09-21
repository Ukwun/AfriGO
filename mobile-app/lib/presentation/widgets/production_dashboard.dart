import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/colors.dart';
import '../providers/auth_provider.dart';
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
    final user = ref.watch(currentUserProvider);
    return RoleDashboardShell(
      role: role,
      child: RefreshIndicator(
        onRefresh: () async {
          for (final feed in feeds) {
            ref.invalidate(dashboardRecordsProvider(feed.resource));
          }
          // A single unavailable collection must not leave the refresh
          // indicator spinning forever or prevent the other live sections
          // from updating.
          await Future.wait(feeds.map((feed) async {
            try {
              await ref.read(dashboardRecordsProvider(feed.resource).future);
            } catch (_) {
              // Each section provides its own helpful recovery state below.
            }
          }));
        },
        child: CustomScrollView(slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList.list(children: [
              FadeInTransition(
                  child: Text(
                      user == null || user.firstName.trim().isEmpty
                          ? headline
                          : 'Welcome back, ${user.firstName}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800))),
              const SizedBox(height: 6),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              _LiveAccountNotice(role: role),
              const SizedBox(height: 12),
              _MarketplaceGateway(role: role),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(actionRoute),
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
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

class _LiveAccountNotice extends StatelessWidget {
  const _LiveAccountNotice({required this.role});
  final DashboardRole role;

  @override
  Widget build(BuildContext context) {
    final message = switch (role) {
      DashboardRole.buyer =>
        'Your requests, offers, contracts and delivery updates appear here as your trading partners act.',
      DashboardRole.supplier =>
        'Your lots, offers, contracts and payout updates appear here as they are confirmed.',
      DashboardRole.exporter =>
        'Your export requests, dossiers and shipment milestones appear here as they are confirmed.',
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(Icons.sync_rounded,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(message, style: Theme.of(context).textTheme.bodySmall)),
        ]),
      ),
    );
  }
}

class _MarketplaceGateway extends StatelessWidget {
  const _MarketplaceGateway({required this.role});

  final DashboardRole role;

  @override
  Widget build(BuildContext context) {
    final supportingText = switch (role) {
      DashboardRole.buyer => 'Browse live inventory and contact suppliers',
      DashboardRole.supplier => 'See active products and current market supply',
      DashboardRole.exporter =>
        'Find export-ready inventory from verified participants',
    };
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('marketplace-gateway-${role.name}'),
        onTap: () => context.push('/marketplace'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore marketplace',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      supportingText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
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
          loading: () => const _LiveLoadingCard(),
          error: (error, _) => _LiveDataUnavailable(
            title: feed.title,
            onRetry: () =>
                ref.invalidate(dashboardRecordsProvider(feed.resource)),
            onContinue: () => context.push(feed.route),
          ),
          data: (records) => records.isEmpty
              ? _LiveEmptyCard(feed: feed)
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

class _LiveLoadingCard extends StatelessWidget {
  const _LiveLoadingCard();

  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(children: [
            SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(width: 14),
            Expanded(child: Text('Checking your latest activity…')),
          ]),
        ),
      );
}

class _LiveEmptyCard extends StatelessWidget {
  const _LiveEmptyCard({required this.feed});
  final DashboardFeed feed;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.inbox_outlined),
            const SizedBox(height: 12),
            Text('No ${feed.title.toLowerCase()} yet',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            const Text(
                'When there is activity on your AfriGO account, it will appear here automatically.'),
            const SizedBox(height: 12),
            TextButton(
                onPressed: () => context.push(feed.route),
                child: Text('View ${feed.title.toLowerCase()}')),
          ]),
        ),
      );
}

class _LiveDataUnavailable extends StatelessWidget {
  const _LiveDataUnavailable({
    required this.title,
    required this.onRetry,
    required this.onContinue,
  });
  final String title;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.error),
            const SizedBox(height: 12),
            Text('$title are temporarily unavailable',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            const Text(
                'We could not reach your live AfriGO records. Your account is still safe; check your connection and try again.'),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again')),
              TextButton(
                  onPressed: onContinue, child: const Text('Open this page')),
            ]),
          ]),
        ),
      );
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
