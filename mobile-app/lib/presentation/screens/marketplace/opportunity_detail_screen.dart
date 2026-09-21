import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/lots_provider.dart';
import '../../providers/auth_provider.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.lotId});

  final String lotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lot = ref.watch(lotDetailProvider(lotId));
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              final role = user?.roles.firstOrNull;
              context.go(role == 'supplier'
                  ? '/supplier/home'
                  : role == 'exporter'
                      ? '/exporter/home'
                      : '/buyer/home');
            case 1:
              context.go('/marketplace');
            case 2:
              context.push('/quotes');
            case 3:
              context.push('/support');
            case 4:
              context.push('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), label: 'Trades'),
          NavigationDestination(icon: Icon(Icons.headset_mic_outlined), label: 'Support'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
      body: lot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 12),
                const Text('This opportunity could not be loaded.'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(lotDetailProvider(lotId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (lot) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: AfrigoColors.primary,
              title: const Text('Opportunity details'),
              actions: [
                IconButton(
                  tooltip: 'Share',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share link copied.')),
                  ),
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              sliver: SliverList.list(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: lot.imageUrl == null
                        ? Image.asset(
                            'assets/images/pexels-zahrah-nandoo-2147929825-29833299.jpg',
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            lot.imageUrl!,
                            height: 230,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 230,
                              color:
                                  AfrigoColors.primary.withValues(alpha: .08),
                              child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 52),
                            ),
                          ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AfrigoColors.primary.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: AfrigoColors.primary, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lot.productName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 5),
                            Text(
                                '${lot.sellerName.isEmpty ? 'Verified supplier' : lot.sellerName} · ${lot.location}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AfrigoColors.textSecondary)),
                          ],
                        ),
                      ),
                      _VerifiedBadge(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _StatsRow(lot: lot),
                  const SizedBox(height: 18),
                  _Section(
                      title: 'Product specifications',
                      icon: Icons.description_outlined,
                      child: _Specifications(lot: lot)),
                  const SizedBox(height: 14),
                  const _Section(
                      title: 'Documents',
                      icon: Icons.insert_drive_file_outlined,
                      child: _Documents()),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () => context.push('/messages'),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Send enquiry'),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
            color: AfrigoColors.primary.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(14)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.verified_outlined, size: 18, color: AfrigoColors.primary),
          SizedBox(width: 5),
          Text('Verified',
              style: TextStyle(
                  color: AfrigoColors.primary, fontWeight: FontWeight.w700))
        ]),
      );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.lot});
  final dynamic lot;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: AfrigoColors.primary.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          _Stat(
              label: 'Available quantity',
              value: '${lot.quantity.toStringAsFixed(0)} ${lot.unit}'),
          const _Stat(label: 'Minimum order', value: 'Contact supplier'),
          _Stat(
              label: 'Price',
              value: lot.pricePerUnit > 0
                  ? '${lot.currency} ${lot.pricePerUnit.toStringAsFixed(2)}/${lot.unit}'
                  : 'Request quotation'),
        ]),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 5),
            Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800, color: AfrigoColors.primary))
          ])));
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          border: Border.all(color: AfrigoColors.borderLight),
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: AfrigoColors.primary),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800))),
              const Icon(Icons.expand_less_rounded)
            ]),
            const SizedBox(height: 12),
            child
          ])));
}

class _Specifications extends StatelessWidget {
  const _Specifications({required this.lot});
  final dynamic lot;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AfrigoColors.primary.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _row('Product name', lot.productName),
        _row('Origin', lot.location),
        _row('Category', lot.productType),
        _row(
            'Description',
            lot.description.isEmpty
                ? 'Supplier details available on enquiry.'
                : lot.description),
        _row('Status', lot.status)
      ]));
  Widget _row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(label)),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)))
      ]));
}

class _Documents extends StatelessWidget {
  const _Documents();
  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined,
                color: AfrigoColors.primary),
            title: const Text('Supplier specifications'),
            subtitle: const Text('Available after supplier upload'),
            trailing: IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Document is not available yet.'))),
                icon: const Icon(Icons.download_outlined))),
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.verified_outlined,
                color: AfrigoColors.primary),
            title: const Text('Verification records'),
            subtitle:
                const Text('Shown when the supplier completes verification'),
            trailing: IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Verification document is not available yet.'))),
                icon: const Icon(Icons.download_outlined)))
      ]);
}
