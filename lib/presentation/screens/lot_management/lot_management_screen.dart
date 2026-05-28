import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/lot.dart';
import '../../../data/providers/lot_management_provider.dart';
import '../../../data/services/lot_service.dart';
import 'create_lot_screen.dart';
import 'lot_detail_screen.dart';
import 'widgets/lot_card.dart';

/// Lot Management Screen (for Sellers)
/// List of seller's created/active lots with status tracking
class LotManagementScreen extends ConsumerStatefulWidget {
  const LotManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LotManagementScreen> createState() =>
      _LotManagementScreenState();
}

class _LotManagementScreenState extends ConsumerState<LotManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('My Lots'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-lot'),
            tooltip: 'Create new lot',
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
                Tab(text: 'All'),
                Tab(text: 'Created'),
                Tab(text: 'Listed'),
                Tab(text: 'Sold'),
                Tab(text: 'Archived'),
              ],
            ),
          ),
          // Lots list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLotsList(context, ref, null), // All
                _buildLotsList(context, ref, 'CREATED'), // Created
                _buildLotsList(context, ref, 'LISTED'), // Listed
                _buildLotsList(context, ref, 'SOLD'), // Sold
                _buildLotsList(context, ref, 'ARCHIVED'), // Archived
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build lots list (filtered by status)
  Widget _buildLotsList(BuildContext context, WidgetRef ref, String? status) {
    final lotsAsync = ref.watch(sellerLotsProvider(status));

    return lotsAsync.when(
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
              onPressed: () => ref.refresh(sellerLotsProvider(status)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (lots) {
        if (lots.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No lots yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first lot to start selling',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/create-lot'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Lot'),
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
          itemCount: lots.length,
          itemBuilder: (context, index) {
            final lot = lots[index];
            return LotCard(
              lot: lot,
              onTap: () {
                context.push('/lot-detail/${lot.id}');
              },
              onEdit: () {
                // Edit lot (only if status allows)
                if (lot.status == 'CREATED' || lot.status == 'LISTED') {
                  context.push('/edit-lot/${lot.id}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot edit lot after listing or sale'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              onDelete: () {
                _showDeleteConfirmation(context, lot.id);
              },
            );
          },
        );
      },
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, String lotId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Lot?'),
          content: const Text(
            'This action cannot be undone. The lot will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // FUNCTIONAL [DELETE] button
                _deleteLot(context, lotId, ref);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Delete lot - REAL backend call
  Future<void> _deleteLot(
    BuildContext context,
    String lotId,
    WidgetRef ref,
  ) async {
    try {
      final lotService = ref.read(lotServiceProvider);
      await lotService.deleteLot(lotId);

      // Refresh list
      ref.refresh(sellerLotsProvider(null));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lot deleted successfully'),
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
}
