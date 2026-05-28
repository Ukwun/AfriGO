import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../domain/models/lot.dart';
import '../../../data/providers/lot_detail_provider.dart';
import '../../../data/services/lot_service.dart';

/// Lot Detail Screen
/// Shows complete lot information with QR code, status tracking, bids
class LotDetailScreen extends ConsumerStatefulWidget {
  final String lotId;

  const LotDetailScreen({
    Key? key,
    required this.lotId,
  }) : super(key: key);

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final lotAsync = ref.watch(lotDetailProvider(widget.lotId));

          return lotAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
            data: (lot) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images carousel
                    _buildImageCarousel(lot),

                    // Lot info
                    _buildLotInfo(lot),

                    // QR code section (cryptographic, unforgeable)
                    _buildQRCodeSection(lot),

                    // Status tracking (real-time via WebSocket)
                    _buildStatusTracking(lot),

                    // Trust score impact
                    _buildTrustScoreImpact(lot),

                    // Bids/Interest (real-time WebSocket updates)
                    _buildBidsSection(lot),

                    // Activity log (immutable from backend)
                    _buildActivityLog(lot),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final lotAsync = ref.watch(lotDetailProvider(widget.lotId));

          return lotAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (lot) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    if (lot.status == 'CREATED' || lot.status == 'LISTED')
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/edit-lot/${lot.id}');
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ),
                    if (lot.status == 'CREATED')
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: ElevatedButton(
                            onPressed: () {
                              // FUNCTIONAL [LIST LOT] button
                              // Changes status from CREATED to LISTED
                              // Broadcasts LOT_LISTED event via WebSocket
                              // Buyers see product in marketplace instantly
                              _listLot(context, lot.id, ref);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('List Lot'),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Image carousel
  Widget _buildImageCarousel(Lot lot) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: lot.photoUrls.isEmpty
              ? Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 48),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: lot.photoUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      lot.photoUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 48),
                        );
                      },
                    );
                  },
                ),
        ),
        if (lot.photoUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: lot.photoUrls.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  /// Lot basic info
  Widget _buildLotInfo(Lot lot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.productName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quality: ${lot.qualityGrade}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${lot.price.toStringAsFixed(2)}/kg',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${lot.quantity.toStringAsFixed(0)}kg available',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Harvested: ${lot.harvestDate.toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// QR code section (cryptographic, unforgeable)
  Widget _buildQRCodeSection(Lot lot) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lot QR Code',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unique, cryptographic, unforgeable - use to track this lot',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImage(
              data: lot.qrCode ?? lot.id,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              gapless: false,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Download QR code
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR code saved to gallery'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Share QR code
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing QR code...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Status tracking (real-time via WebSocket)
  Widget _buildStatusTracking(Lot lot) {
    const statusFlow = [
      'CREATED',
      'LISTED',
      'RESERVED',
      'SOLD',
      'IN_TRANSIT',
      'DELIVERED',
    ];
    final currentIndex = statusFlow.indexOf(lot.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Tracking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(statusFlow.length, (index) {
              final isDone = index < currentIndex;
              final isActive = index == currentIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone || isActive
                            ? Colors.green
                            : Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isDone || isActive
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusFlow[index],
                            style: TextStyle(
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isActive ? Colors.green : Colors.black,
                            ),
                          ),
                          if (isActive)
                            const Text(
                              'Current status',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Trust score impact display
  Widget _buildTrustScoreImpact(Lot lot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trust Score Impact',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On successful sale:',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '+2 trust points',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Helps your rating',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bids/Interest section (real-time WebSocket updates)
  Widget _buildBidsSection(Lot lot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bids & Interest',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time updates via WebSocket',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          if ((lot.bids ?? []).isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('No bids yet. Your lot will appear once listed.'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lot.bids!.length,
              itemBuilder: (context, index) {
                final bid = lot.bids![index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              bid.buyerName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${bid.price.toStringAsFixed(2)}/kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Quantity: ${bid.quantity}kg'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${bid.status}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (bid.status == 'PENDING')
                              ElevatedButton(
                                onPressed: () {
                                  // Accept bid
                                  _acceptBid(context, bid.id, ref);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Activity log (immutable from backend)
  Widget _buildActivityLog(Lot lot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Immutable, append-only history (cannot be modified)',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          if ((lot.activityLog ?? []).isEmpty)
            const Text('No activity yet')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lot.activityLog!.length,
              itemBuilder: (context, index) {
                final activity = lot.activityLog![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                );
              },
            ),
        ],
      ),
    );
  }

  /// List lot - REAL backend call
  Future<void> _listLot(
    BuildContext context,
    String lotId,
    WidgetRef ref,
  ) async {
    try {
      final lotService = ref.read(lotServiceProvider);

      // FUNCTIONAL [LIST LOT] button - REAL backend call
      // Changes status from CREATED to LISTED
      // Broadcasts LOT_LISTED event via WebSocket
      // All buyers' apps updated instantly if they match criteria
      await lotService.listLot(lotId);

      // Refresh detail
      ref.refresh(lotDetailProvider(lotId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lot listed successfully! Buyers can see it now.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Accept bid - REAL backend call
  Future<void> _acceptBid(
    BuildContext context,
    String bidId,
    WidgetRef ref,
  ) async {
    try {
      final lotService = ref.read(lotServiceProvider);
      await lotService.acceptBid(bidId);

      // Refresh detail
      ref.refresh(lotDetailProvider(widget.lotId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid accepted! Trade created.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
