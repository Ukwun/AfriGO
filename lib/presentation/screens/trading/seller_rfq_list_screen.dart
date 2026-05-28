import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/trading_provider.dart';
import '../../../data/services/trade_service.dart';
import 'widgets/rfq_card_seller.dart';

/// Seller RFQ List Screen
/// View all RFQs (requests for quote) received from buyers
/// Allows sellers to submit quotes on RFQs
class SellerRFQListScreen extends ConsumerStatefulWidget {
  const SellerRFQListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerRFQListScreen> createState() =>
      _SellerRFQListScreenState();
}

class _SellerRFQListScreenState extends ConsumerState<SellerRFQListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available RFQs'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by product type...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: const [
                Tab(text: 'New (Open)'),
                Tab(text: 'I Quoted'),
                Tab(text: 'Negotiating'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRFQsList(context, ref, 'OPEN'),
                _buildRFQsList(context, ref, 'QUOTED'),
                _buildRFQsList(context, ref, 'NEGOTIATING'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build RFQs list (filtered by status)
  Widget _buildRFQsList(BuildContext context, WidgetRef ref, String status) {
    final rfqsAsync = ref.watch(rfqListProvider);

    return rfqsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (allRFQs) {
        // Filter by status and search
        final filtered = allRFQs
            .where((rfq) {
              if (status == 'OPEN') {
                return rfq.status == 'OPEN';
              } else if (status == 'QUOTED') {
                // RFQs where seller has already submitted bid
                return rfq.bids?.any((bid) => bid.status != 'REJECTED') ??
                    false;
              } else {
                return rfq.status == 'NEGOTIATING';
              }
            })
            .where(
              (rfq) => rfq.productType.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No $status RFQs',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  status == 'OPEN'
                      ? 'New buyer requests will appear here'
                      : 'Your quotes will appear here',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final rfq = filtered[index];
            final hasBid = rfq.bids?.isNotEmpty ?? false;

            return RFQCardSeller(
              rfq: rfq,
              onTap: () {
                context.push('/rfq-detail-seller/${rfq.id}');
              },
              onSubmitBid: !hasBid
                  ? () {
                      context.push('/submit-bid/${rfq.id}');
                    }
                  : null,
              onViewBid: hasBid
                  ? () {
                      context.push('/bid-detail/${rfq.id}');
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}
