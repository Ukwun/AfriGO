import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../widgets/motion_system.dart';

/// Buyer Home Screen - Procurement focused on sourcing
///
/// Layout:
/// - Trade Volume Dashboard (interactive KPIs)
/// - Open RFQs (active requests for quotes)
/// - Shipments (active orders tracking)
/// - Verified Supply (supplier recommendations)
/// - Analytics (market trends)
class BuyerHomeScreen extends ConsumerStatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  ConsumerState<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends ConsumerState<BuyerHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== WELCOME HEADER ==========
              FadeInTransition(
                duration: const Duration(milliseconds: 400),
                child: _buildWelcomeHeader(),
              ),
              const SizedBox(height: 28),

              // ========== PRIMARY CTA: Create RFQ ==========
              SlideInTransition(
                begin: const Offset(0, 0.3),
                duration: const Duration(milliseconds: 500),
                child: _buildCreateRFQButton(context),
              ),
              const SizedBox(height: 32),

              // ========== TRADE VOLUME DASHBOARD ==========
              _buildSectionHeader(
                icon: Icons.trending_up_outlined,
                title: 'Trade Volume',
                subtitle: 'This month',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildKPICard(
                        title: 'Total Orders',
                        value: '48',
                        change: '+12% vs last month',
                        icon: Icons.shopping_cart_outlined,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildKPICard(
                        title: 'Spend',
                        value: '\$245K',
                        change: '+8% vs last month',
                        icon: Icons.wallet_outlined,
                        color: AppColors.secondaryGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ========== OPEN RFQs ==========
              _buildSectionHeader(
                icon: Icons.request_quote_outlined,
                title: 'Open RFQs',
                subtitle: '5 awaiting responses',
                action: 'View All',
                onActionTap: () => context.push('/rfqs'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildRFQCard(
                  context,
                  title: 'Cocoa Beans - 20 Tonnes',
                  supplierResponses: '12',
                  bestPrice: '\$11,800/tonne',
                  postedAgo: '2 days ago',
                  deadline: '5 days left',
                  status: 'active',
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildRFQCard(
                  context,
                  title: 'Shea Butter Grade A - 500L',
                  supplierResponses: '8',
                  bestPrice: '\$4,200/L',
                  postedAgo: '1 week ago',
                  deadline: '2 days left',
                  status: 'expiring',
                ),
              ),
              const SizedBox(height: 24),

              // ========== SHIPMENTS TRACKING ==========
              _buildSectionHeader(
                icon: Icons.local_shipping_outlined,
                title: 'Shipments',
                subtitle: '3 in transit',
                action: 'Track All',
                onActionTap: () => context.push('/shipments'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildShipmentCard(
                  context,
                  orderID: 'ORD-2024-001',
                  supplier: 'Premium Exports Ltd',
                  item: 'Cocoa Beans, 5 Tonnes',
                  from: 'Kumasi, Ghana',
                  to: 'Lagos, Nigeria',
                  status: 'in_transit',
                  progress: 0.65,
                  eta: 'May 31, 2026',
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildShipmentCard(
                  context,
                  orderID: 'ORD-2024-002',
                  supplier: 'West Africa Exports',
                  item: 'Shea Butter, 300L',
                  from: 'Ouagadougou, Burkina Faso',
                  to: 'Port Harcourt, Nigeria',
                  status: 'cleared',
                  progress: 0.95,
                  eta: 'Today',
                ),
              ),
              const SizedBox(height: 24),

              // ========== VERIFIED SUPPLY ==========
              _buildSectionHeader(
                icon: Icons.verified_outlined,
                title: 'Verified Supply',
                subtitle: 'Recommended for you',
                action: 'Explore',
                onActionTap: () => context.push('/marketplace'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildSupplierCard(
                  context,
                  name: 'Quality Cocoa Exports',
                  location: 'Kumasi, Ghana',
                  rating: '4.8',
                  reviews: '234',
                  minOrder: '2 tonnes',
                  availability: '45 lots',
                  verified: true,
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildSupplierCard(
                  context,
                  name: 'Shea Butter Cooperative',
                  location: 'Ouagadougou, Burkina Faso',
                  rating: '4.6',
                  reviews: '189',
                  minOrder: '100L',
                  availability: '28 lots',
                  verified: true,
                ),
              ),
              const SizedBox(height: 24),

              // ========== ANALYTICS ==========
              _buildSectionHeader(
                icon: Icons.bar_chart_outlined,
                title: 'Market Analytics',
                subtitle: 'Current trends',
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildAnalyticsCard(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================
  // WIDGET BUILDERS
  // =========================================

  Widget _buildWelcomeHeader() {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Good morning! ☀️',
      >= 12 && < 17 => 'Good afternoon! 👋',
      >= 17 && < 21 => 'Good evening! 🌅',
      _ => 'Good night! 🌙',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore the best suppliers across Africa',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateRFQButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/rfqs/create');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.logisticsGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/rfqs/create');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POST A REQUEST FOR QUOTE',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get quotes from multiple suppliers',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Icon(
                  Icons.trending_up,
                  color: AppColors.successGreen,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              change,
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRFQCard(
    BuildContext context, {
    required String title,
    required String supplierResponses,
    required String bestPrice,
    required String postedAgo,
    required String deadline,
    required String status,
  }) {
    final isExpiring = status == 'expiring';
    final borderColor =
        isExpiring ? AppColors.warningOrange : AppColors.borderDefault;

    return GestureDetector(
      onTap: () => context.push('/rfqs/detail/1'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border.all(color: borderColor, width: isExpiring ? 2 : 1),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/rfqs/detail/1'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Posted $postedAgo',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isExpiring
                              ? AppColors.warningOrangeLight
                              : AppColors.accentBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          deadline,
                          style: TextStyle(
                            color: isExpiring
                                ? AppColors.warningOrange
                                : AppColors.accentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(height: 1, color: AppColors.borderDefault),
                  const SizedBox(height: 16),

                  // Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Responses',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            supplierResponses,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Best Price',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bestPrice,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.successGreen,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Viewing all supplier quotes'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentBlue,
                          ),
                          child: const Text('Compare Quotes'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push('/rfqs/edit/1');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                          ),
                          child: const Text('Select Winner'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentCard(
    BuildContext context, {
    required String orderID,
    required String supplier,
    required String item,
    required String from,
    required String to,
    required String status,
    required double progress,
    required String eta,
  }) {
    return GestureDetector(
      onTap: () => context.push('/shipments/detail/$orderID'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/shipments/detail/$orderID'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderID,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'cleared'
                              ? AppColors.successGreenLight
                              : AppColors.accentBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status == 'cleared' ? '✓ Cleared' : '📦 In Transit',
                          style: TextStyle(
                            color: status == 'cleared'
                                ? AppColors.successGreen
                                : AppColors.accentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    supplier,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),

                  // Route visualization
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              from,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'To',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              to,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Progress bar with animation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: AppColors.borderDefault,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.accentBlue,
                              ),
                              minHeight: 6,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% Complete',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'ETA: $eta',
                            style: TextStyle(
                              color: AppColors.accentBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierCard(
    BuildContext context, {
    required String name,
    required String location,
    required String rating,
    required String reviews,
    required String minOrder,
    required String availability,
    required bool verified,
  }) {
    return GestureDetector(
      onTap: () => context.push('/marketplace/supplier/1'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/marketplace/supplier/1'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (verified)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.successGreen,
                                      size: 18,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⭐ $rating',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: AppColors.borderDefault,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem('Reviews', reviews),
                      _buildDetailItem('Min Order', minOrder),
                      _buildDetailItem('Available', availability),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/rfqs/create?supplierId=1');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                      ),
                      child: const Text('View Catalog'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTrendItem('Cocoa Beans', '↑ +5.2%', AppColors.successGreen),
            const SizedBox(height: 12),
            _buildTrendItem('Shea Butter', '↓ -2.1%', AppColors.errorRed),
            const SizedBox(height: 12),
            _buildTrendItem('Palm Oil', '→ +0.3%', AppColors.warningOrange),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/analytics');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                ),
                child: const Text('View Full Analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String product, String change, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          product,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          change,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    String? action,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentBlue, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (action != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              action,
              style: TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
