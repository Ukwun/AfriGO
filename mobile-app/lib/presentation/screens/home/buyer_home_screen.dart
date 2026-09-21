import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../domain/models/lot_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_records_provider.dart';
import '../../providers/lots_provider.dart';
import '../../widgets/dashboard_role.dart';
import '../../widgets/role_dashboard_shell.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final lots = ref.watch(lotsProvider);
    final rfqs = ref.watch(dashboardRecordsProvider('rfqs'));
    final orders = ref.watch(dashboardRecordsProvider('orders'));
    final firstName = user?.firstName.trim();
    final profileProgress = user == null ? 0 : (user.phoneVerified ? 100 : 75);

    return RoleDashboardShell(
      role: DashboardRole.buyer,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(lotsProvider);
          ref.invalidate(dashboardRecordsProvider('rfqs'));
          ref.invalidate(dashboardRecordsProvider('orders'));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 36),
              sliver: SliverList.list(children: [
                Row(children: [
                  const _BrandMark(),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AfrigoColors.primary.withValues(alpha: .1),
                    child: Text(
                      (user?.firstName.isNotEmpty == true
                              ? user!.firstName[0]
                              : 'A')
                          .toUpperCase(),
                      style: const TextStyle(
                        color: AfrigoColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 22),
                Text(
                    'Good morning${firstName?.isNotEmpty == true ? ', $firstName' : ''}.',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AfrigoColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                    user?.fullName.isNotEmpty == true
                        ? user!.fullName
                        : 'Your buyer workspace',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                _ProfileProgress(
                    progress: profileProgress,
                    onTap: () => context.push('/profile/edit')),
                const SizedBox(height: 16),
                _HeroBanner(onTap: () => context.push('/marketplace')),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                      child: _MetricCard(
                          icon: Icons.request_quote_outlined,
                          value: _count(rfqs),
                          label: 'Enquiries',
                          onTap: () => context.push('/rfqs'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MetricCard(
                          icon: Icons.swap_horiz_rounded,
                          value: _count(orders),
                          label: 'Active trades',
                          onTap: () => context.push('/orders'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MetricCard(
                          icon: Icons.check_box_outlined,
                          value: '${_count(orders) == 0 ? 0 : 1}',
                          label: 'Tasks',
                          onTap: () => context.push('/buyer/more'))),
                ]),
                const SizedBox(height: 24),
                _SectionHeader(
                    title: 'Quick actions',
                    action: 'See all',
                    onTap: () => context.push('/buyer/more')),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.search_rounded,
                          label: 'Find suppliers',
                          onTap: () => context.push('/marketplace'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.add_rounded,
                          label: 'Create RFQ',
                          onTap: () => context.push('/rfqs/create'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.menu_book_outlined,
                          label: 'Market access',
                          onTap: () => context.push('/market-access'))),
                ]),
                const SizedBox(height: 24),
                _SectionHeader(
                    title: 'Live opportunities',
                    action: 'Explore all',
                    onTap: () => context.push('/marketplace')),
                const SizedBox(height: 10),
                lots.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const _EmptyNotice(
                      text:
                          'Live opportunities are unavailable. Pull to refresh.'),
                  data: (items) => items.isEmpty
                      ? const _EmptyNotice(
                          text:
                              'Verified suppliers will appear here as they publish inventory.')
                      : _OpportunityPreview(
                          lot: items.first,
                          onTap: () =>
                              context.push('/lots/detail/${items.first.id}')),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  String _count(AsyncValue<List<Map<String, dynamic>>> value) => value.when(
        data: (items) => '${items.length}',
        loading: () => '…',
        error: (_, __) => '0',
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 42,
            height: 42,
            child: Image.asset('assets/images/Afrigolg1.png',
                fit: BoxFit.contain)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AfriGoOS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AfrigoColors.primary, fontWeight: FontWeight.w800)),
          Text('Africa Trades Together',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AfrigoColors.primary))
        ])
      ]);
}

class _ProfileProgress extends StatelessWidget {
  const _ProfileProgress({required this.progress, required this.onTap});
  final int progress;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AfrigoColors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text('Complete your business profile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AfrigoColors.primary,
                          fontWeight: FontWeight.w800))),
              Text('$progress%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.secondaryGold,
                      fontWeight: FontWeight.w800))
            ]),
            const SizedBox(height: 12),
            LinearProgressIndicator(
                value: progress / 100,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
                color: AfrigoColors.primary),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Text(
                      'Add key information to access more buyers and opportunities.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AfrigoColors.textSecondary))),
              const Icon(Icons.chevron_right_rounded)
            ])
          ])));
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        height: 176,
        decoration: BoxDecoration(
          color: AfrigoColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=1200&q=85',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AfrigoColors.primary,
                      Color(0xD90F5B46),
                      Color(0x330F5B46),
                    ],
                    stops: [0, .58, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Trade further\nin Africa',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Connect. Comply. Grow.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Explore opportunities'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondaryGold,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.onTap});
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
          padding: const EdgeInsets.all(14),
          height: 118,
          decoration: BoxDecoration(
              color: AfrigoColors.primary.withValues(alpha: .05),
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AfrigoColors.primary),
            const Spacer(),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.bodySmall)
          ])));
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
          height: 108,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: AfrigoColors.borderLight),
              borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(
                backgroundColor: AfrigoColors.primary.withValues(alpha: .1),
                child: Icon(icon, color: AfrigoColors.primary)),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.w700))
          ])));
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800))),
        TextButton(onPressed: onTap, child: Text(action))
      ]);
}

class _OpportunityPreview extends StatelessWidget {
  const _OpportunityPreview({required this.lot, required this.onTap});
  final LotModel lot;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
          clipBehavior: Clip.antiAlias,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (lot.imageUrl != null)
              Image.network(lot.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                      height: 150,
                      child: Icon(Icons.image_not_supported_outlined)))
            else
              const SizedBox(
                  height: 150,
                  child: Center(
                      child: Icon(Icons.inventory_2_outlined, size: 48))),
            Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(lot.productName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                            '${lot.location} · ${lot.quantity.toStringAsFixed(0)} ${lot.unit}',
                            style: Theme.of(context).textTheme.bodySmall)
                      ])),
                  const Icon(Icons.chevron_right_rounded)
                ]))
          ])));
}

class _EmptyNotice extends StatelessWidget {
  const _EmptyNotice({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium)));
}
