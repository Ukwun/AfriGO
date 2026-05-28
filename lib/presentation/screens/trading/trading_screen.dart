import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/trading_provider.dart';
import '../../../data/services/trade_service.dart';
import 'widgets/trade_card.dart';
import 'widgets/trade_status_badge.dart';

/// Trading Screen
/// View active trades and RFQs with real-time status updates
class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-rfq'),
            tooltip: 'Create new RFQ',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar - filter by status
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Negotiating'),
                Tab(text: 'Accepted'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          // Trades list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTradesList(context, ref, 'OPEN'),
                _buildTradesList(context, ref, 'NEGOTIATING'),
                _buildTradesList(context, ref, 'ACCEPTED'),
                _buildTradesList(context, ref, 'COMPLETED'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build trades list (filtered by status)
  Widget _buildTradesList(BuildContext context, WidgetRef ref, String status) {
    final tradesAsync = ref.watch(activeTradesProvider(status));

    return tradesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(activeTradesProvider(status)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (trades) {
        if (trades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No trades yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  status == 'OPEN'
                      ? 'Create an RFQ to start trading'
                      : 'Your $status trades will appear here',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/create-rfq'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create RFQ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            return TradeCard(
              trade: trade,
              onTap: () {
                context.push('/trade-detail/${trade.id}');
              },
              onAccept: status == 'OPEN' || status == 'NEGOTIATING'
                  ? () => _acceptTrade(context, trade.id, ref)
                  : null,
              onReject: status == 'OPEN' || status == 'NEGOTIATING'
                  ? () => _rejectTrade(context, trade.id, ref)
                  : null,
            );
          },
        );
      },
    );
  }

  /// Accept trade - REAL backend call
  Future<void> _acceptTrade(
    BuildContext context,
    String tradeId,
    WidgetRef ref,
  ) async {
    try {
      final tradeService = ref.read(tradeServiceProvider);

      // FUNCTIONAL [ACCEPT] button - REAL backend call
      // Fraud detection runs
      // Trust scores updated
      // Contract generated
      // Payment initiated
      // Both parties notified in real-time
      await tradeService.acceptTrade(tradeId);

      // Refresh list
      ref.refresh(activeTradesProvider('OPEN'));
      ref.refresh(activeTradesProvider('ACCEPTED'));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trade accepted! Proceeding to payment.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Reject trade - REAL backend call
  Future<void> _rejectTrade(
    BuildContext context,
    String tradeId,
    WidgetRef ref,
  ) async {
    try {
      final tradeService = ref.read(tradeServiceProvider);

      // FUNCTIONAL [REJECT] button - REAL backend call
      await tradeService.rejectTrade(tradeId);

      // Refresh list
      ref.refresh(activeTradesProvider('OPEN'));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trade rejected'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
