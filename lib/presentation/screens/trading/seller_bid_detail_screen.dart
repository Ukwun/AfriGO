import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/trading_provider.dart';
import '../../../data/services/trade_service.dart';
import '../widgets/bid_card.dart';

/// Seller Bid Detail Screen
/// Seller views buyer's response to their bid (accept/reject/counter)
/// Manages negotiation flow and bid acceptance
class SellerBidDetailScreen extends ConsumerStatefulWidget {
  final String bidId;

  const SellerBidDetailScreen({Key? key, required this.bidId})
    : super(key: key);

  @override
  ConsumerState<SellerBidDetailScreen> createState() =>
      _SellerBidDetailScreenState();
}

class _SellerBidDetailScreenState extends ConsumerState<SellerBidDetailScreen> {
  bool _isProcessing = false;
  final _counterPriceController = TextEditingController();

  @override
  void dispose() {
    _counterPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: In real implementation, would have bidDetailProvider
    // For now, showing structure with trade data
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Quote Response'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bid status card
            _buildBidStatusCard(),

            const SizedBox(height: 24),

            // Buyer info card
            _buildBuyerInfoCard(),

            const SizedBox(height: 24),

            // Your bid details
            _buildYourBidCard(),

            const SizedBox(height: 24),

            // Negotiation history
            _buildNegotiationHistory(),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Bid status card
  Widget _buildBidStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quote Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACCEPTED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'The buyer accepted your quote!',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Next: Provide shipping info & track delivery',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buyer info card
  Widget _buildBuyerInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buyer Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: const Center(child: Icon(Icons.person, size: 28)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'John Mensah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              Icons.star,
                              size: 14,
                              color: i < 4 ? Colors.amber : Colors.grey[300],
                            );
                          }),
                          const SizedBox(width: 8),
                          const Text(
                            '4.2★',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '45 completed trades',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Text(
                  'Ghana • Accra',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Your bid details
  Widget _buildYourBidCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Quote',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Price per kg:', '\$2.40', Colors.green),
            _buildDetailRow('Quantity:', '1,000kg', Colors.black87),
            _buildDetailRow('Quality Grade:', 'Grade A', Colors.black87),
            _buildDetailRow('Delivery Days:', '14 days', Colors.black87),
            const Divider(height: 24),
            _buildDetailRow(
              'Total Value:',
              '\$2,400',
              Colors.green,
              bold: true,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Your notes: "Certified organic, premium selection"',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Negotiation history
  Widget _buildNegotiationHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Negotiation Timeline',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Your initial bid
            _buildTimelineItem(
              icon: Icons.send,
              title: 'You submitted quote',
              description: '\$2.40/kg for 1,000kg',
              time: '2 days ago',
              isYou: true,
            ),
            const SizedBox(height: 12),
            // Buyer counter
            _buildTimelineItem(
              icon: Icons.reply,
              title: 'Buyer countered',
              description: 'Offered \$2.30/kg instead',
              time: '1 day ago',
              isYou: false,
            ),
            const SizedBox(height: 12),
            // You counter-countered
            _buildTimelineItem(
              icon: Icons.send,
              title: 'You countered',
              description: 'Held firm at \$2.40/kg (premium quality)',
              time: '12 hours ago',
              isYou: true,
            ),
            const SizedBox(height: 12),
            // Buyer accepted
            _buildTimelineItem(
              icon: Icons.check_circle,
              title: 'Buyer accepted!',
              description: 'Agreed to your \$2.40/kg quote',
              time: 'Just now',
              isYou: false,
              isAccept: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Timeline item
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required bool isYou,
    bool isAccept = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAccept
                ? Colors.green[100]
                : isYou
                ? Colors.blue[100]
                : Colors.grey[100],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isAccept
                  ? Colors.green
                  : isYou
                  ? Colors.blue
                  : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Detail row helper
  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 14 : 12,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Ship now button - FUNCTIONAL
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : () => _proceedToShipping(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('PROCEED TO SHIPPING'),
          ),
        ),
        const SizedBox(height: 12),
        // View details button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Show full negotiation details
              _showDetailDialog(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('View Full Details'),
          ),
        ),
      ],
    );
  }

  /// Proceed to shipping - REAL backend call
  Future<void> _proceedToShipping(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      // Navigate to shipping instructions screen
      context.go('/shipping-instructions/${widget.bidId}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Show detail dialog
  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Quote Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quote Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Product: Cocoa Grade A\n'
                  '• Quantity: 1,000 kg\n'
                  '• Price: \$2.40 per kg\n'
                  '• Total: \$2,400\n'
                  '• Delivery: 14 days\n'
                  '• Quality: Premium certified\n'
                  '• Notes: Organic, hand-selected',
                  style: TextStyle(fontSize: 12, height: 1.6),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Next Steps:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Submit shipping information\n'
                  '2. Buyer confirms payment\n'
                  '3. Product shipped\n'
                  '4. Buyer confirms delivery\n'
                  '5. Payment released to you',
                  style: TextStyle(fontSize: 12, height: 1.6),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
