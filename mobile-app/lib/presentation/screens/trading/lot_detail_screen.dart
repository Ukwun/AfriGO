import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class LotDetailScreen extends ConsumerStatefulWidget {
  final String lotId;

  const LotDetailScreen({
    super.key,
    required this.lotId,
  });

  @override
  ConsumerState<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends ConsumerState<LotDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lot ${widget.lotId}'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Edit Lot')),
              const PopupMenuItem(child: Text('View QR Code')),
              const PopupMenuItem(child: Text('Download Certificate')),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Overview
                ScaleInTransition(
                  child: _buildProductOverview(),
                ),
                const SizedBox(height: 24),

                // Lot Specifications
                ScaleInTransition(
                  child: _buildSectionHeader('Lot Specifications'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildSpecCard('Premium Cocoa Beans', 'Grade A',
                      '5,000 kg', 'Kumasi, Ghana'),
                ),
                const SizedBox(height: 24),

                // Quality Score
                ScaleInTransition(
                  child: _buildSectionHeader('Quality Score'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildQualityIndicator(),
                ),
                const SizedBox(height: 24),

                // Bids Received
                ScaleInTransition(
                  child: _buildSectionHeader('Bids Received (23)'),
                ),
                const SizedBox(height: 12),
                ..._buildBidsList(),
                const SizedBox(height: 24),

                // Shipping Readiness
                ScaleInTransition(
                  child: _buildSectionHeader('Shipping Readiness'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildShippingChecklist(),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                ScaleInTransition(
                  child: _buildActionButtons(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryGold.withOpacity(0.1),
            AppColors.accentBlue.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🍫 Premium Cocoa Beans',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Active',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLotInfo('Price', '\$12,500'),
              _buildLotInfo('Quantity', '5,000 kg'),
              _buildLotInfo('Grade', 'A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLotInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSpecCard(
      String name, String grade, String quantity, String location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSpecItem('Grade', grade),
              _buildSpecItem('Quantity', quantity),
              _buildSpecItem('📍 Location', location),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQualityIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Quality Score',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('94%',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.94,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQualityMetric('Moisture', '12%', true),
              _buildQualityMetric('Fermentation', '85%', true),
              _buildQualityMetric('Defects', '2%', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetric(String label, String value, bool isGood) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isGood ? Colors.green : Colors.orange)),
      ],
    );
  }

  List<Widget> _buildBidsList() {
    final bids = [
      ('Global Traders Ltd', '\$11,800/tonne', '2 days ago'),
      ('African Import Co', '\$11,900/tonne', '1 day ago'),
      ('EU Chocolate Makers', '\$12,100/tonne', '18 hours ago'),
    ];

    return List.generate(bids.length, (index) {
      final (buyer, price, time) = bids[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ScaleInTransition(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyer,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(price,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryGold,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShippingChecklist() {
    final items = [
      ('Quality Inspection', true),
      ('Certifications Ready', true),
      ('Packaging Completed', true),
      ('Documentation', false),
      ('Insurance', false),
    ];

    return Column(
      children: List.generate(items.length, (index) {
        final (label, completed) = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completed ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
              'Edit', false, () => context.push('/lots/edit/${widget.lotId}')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton('View QR', true, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('📱 QR Code: AFG-LOT-${widget.lotId}')),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildButton(String label, bool isPrimary, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.accentBlue : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: !isPrimary ? Border.all(color: Colors.grey[300]!) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
