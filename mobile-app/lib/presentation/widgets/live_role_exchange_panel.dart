import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/colors.dart';
import '../providers/live_market_activity_provider.dart';

class LiveRoleExchangePanel extends ConsumerWidget {
  const LiveRoleExchangePanel({
    super.key,
    required this.role,
  });

  final LiveActorRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveMarketActivityProvider);
    final notifier = ref.read(liveMarketActivityProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildStatsRow(state),
            const SizedBox(height: 12),
            _buildActionRow(context, notifier),
            const SizedBox(height: 12),
            _buildEvents(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.successGreen,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Live Role Exchange',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGreenLighter,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            'Realtime',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(LiveMarketActivityState state) {
    final stats = state.stats;
    final tiles = switch (role) {
      LiveActorRole.buyer => [
          ('Open RFQs', stats.openRfqs),
          ('Active Quotes', stats.activeQuotes),
          ('Delivered', stats.deliveredToday),
        ],
      LiveActorRole.supplier => [
          ('Ready Lots', stats.readyLots),
          ('Active Quotes', stats.activeQuotes),
          ('Paid Today', stats.deliveredToday),
        ],
      LiveActorRole.exporter => [
          ('Booked', stats.bookedShipments),
          ('In Customs', stats.inCustoms),
          ('Delivered', stats.deliveredToday),
        ],
    };

    return Row(
      children: tiles
          .map(
            (tile) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child:
                              ScaleTransition(scale: animation, child: child),
                        );
                      },
                      child: Text(
                        '${tile.$2}',
                        key: ValueKey('${tile.$1}-${tile.$2}'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    LiveMarketActivityNotifier notifier,
  ) {
    final List<(String, IconData, void Function())> actions = switch (role) {
      LiveActorRole.buyer => [
          (
            'Post RFQ',
            Icons.request_quote_outlined,
            () {
              notifier.buyerPostRfq();
              context.push('/rfqs/create');
            }
          ),
          (
            'Release Payment',
            Icons.price_check_outlined,
            () {
              notifier.buyerReleasePayment();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Escrow payment released.')),
              );
            }
          ),
        ],
      LiveActorRole.supplier => [
          (
            'Submit Quote',
            Icons.sell_outlined,
            () {
              notifier.supplierSubmitQuote();
              context.push('/rfqs');
            }
          ),
          (
            'Lot Ready',
            Icons.inventory_2_outlined,
            () {
              notifier.supplierMarkLotReady();
              context.push('/lots');
            }
          ),
        ],
      LiveActorRole.exporter => [
          (
            'Book Shipment',
            Icons.local_shipping_outlined,
            () {
              notifier.exporterBookShipment();
              context.push('/tracking');
            }
          ),
          (
            'Clear Customs',
            Icons.verified_user_outlined,
            () {
              notifier.exporterClearCustoms();
              context.push('/dossiers');
            }
          ),
        ],
    };

    return Row(
      children: actions
          .map(
            (action) => Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: action == actions.first ? 8 : 0),
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    action.$3();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(action.$2, size: 16),
                  label: Text(
                    action.$1,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEvents(LiveMarketActivityState state) {
    final items = state.events.take(3).toList(growable: false);
    return Column(
      children: items
          .map(
            (event) => AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _iconForType(event.type),
                    size: 16,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _timeAgo(event.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  IconData _iconForType(LiveEventType type) {
    switch (type) {
      case LiveEventType.rfqPosted:
        return Icons.request_quote_outlined;
      case LiveEventType.quoteSubmitted:
        return Icons.price_change_outlined;
      case LiveEventType.lotReady:
        return Icons.inventory_2_outlined;
      case LiveEventType.shipmentBooked:
        return Icons.local_shipping_outlined;
      case LiveEventType.customsCleared:
        return Icons.fact_check_outlined;
      case LiveEventType.paymentReleased:
        return Icons.payments_outlined;
    }
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }
}
