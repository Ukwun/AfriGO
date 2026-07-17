import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class SupplierProfileScreen extends ConsumerStatefulWidget {
  final String supplierId;

  const SupplierProfileScreen({
    super.key,
    required this.supplierId,
  });

  @override
  ConsumerState<SupplierProfileScreen> createState() =>
      _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends ConsumerState<SupplierProfileScreen>
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
        title: const Text('Supplier Profile'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Message')),
              const PopupMenuItem(child: Text('Add to Favorites')),
              const PopupMenuItem(child: Text('Report')),
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
                // Company Header
                ScaleInTransition(
                  child: _buildCompanyHeader(),
                ),
                const SizedBox(height: 24),

                // Trust Score
                ScaleInTransition(
                  child: _buildTrustScore(),
                ),
                const SizedBox(height: 24),

                // Performance Metrics
                ScaleInTransition(
                  child: _buildSectionHeader('Performance Metrics'),
                ),
                const SizedBox(height: 12),
                ..._buildMetricsRow(),
                const SizedBox(height: 24),

                // Certifications
                ScaleInTransition(
                  child: _buildSectionHeader('Certifications & Licenses'),
                ),
                const SizedBox(height: 12),
                ..._buildCertifications(),
                const SizedBox(height: 24),

                // Recent Trades
                ScaleInTransition(
                  child: _buildSectionHeader('Recent Successful Trades'),
                ),
                const SizedBox(height: 12),
                ..._buildRecentTrades(),
                const SizedBox(height: 24),

                // Contact & Actions
                ScaleInTransition(
                  child: _buildContactActions(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withOpacity(0.1),
            AppColors.secondaryGold.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🌾 Premium Cocoa Co',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Verified',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Kumasi, Ghana',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Premium cocoa bean producer and exporter since 2010'),
        ],
      ),
    );
  }

  Widget _buildTrustScore() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trust Score',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('9.2/10',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentBlue)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.92,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reliability: 95%', style: TextStyle(fontSize: 12)),
              Text('Quality: 89%', style: TextStyle(fontSize: 12)),
              Text('Communication: 92%', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMetricsRow() {
    final metrics = [
      ('Completed\nTrades', '127'),
      ('Repeat\nCustomers', '34'),
      ('Avg Order\nValue', '\$18.5K'),
      ('Response\nTime', '< 2 hrs'),
    ];

    return [
      ScaleInTransition(
        child: Row(
          children: List.generate(metrics.length, (index) {
            final (label, value) = metrics[index];
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlue)),
                    const SizedBox(height: 4),
                    Text(label,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ];
  }

  List<Widget> _buildCertifications() {
    final certs = [
      'Organic Certified (2020)',
      'Fair Trade (2019)',
      'ISO 9001 Quality (2021)',
      'Rainforest Alliance',
    ];

    return List.generate(certs.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ScaleInTransition(
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Text(certs[index], style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildRecentTrades() {
    final trades = [
      ('Cocoa Beans - 5,000 kg', 'Completed Aug 2024'),
      ('Shea Butter - 2,000 L', 'Completed Jul 2024'),
      ('Cashew Nuts - 8,000 kg', 'Completed Jun 2024'),
    ];

    return List.generate(trades.length, (index) {
      final (product, date) = trades[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(date,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildContactActions() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAction('Message sent!'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Message',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAction('RFQ created!'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Create RFQ',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAction(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
