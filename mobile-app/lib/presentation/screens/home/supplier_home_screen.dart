import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../providers/live_market_activity_provider.dart';
import '../../widgets/experience_shortcuts_strip.dart';
import '../../widgets/live_role_exchange_panel.dart';
import '../../widgets/motion_system.dart';

/// Supplier Home Screen - Commodity sellers focused on lot management
///
/// Layout:
/// - Welcome greeting with dynamic time-based message
/// - CTA: List new lot (prominent, large button)
/// - Your Active Lots (interactive cards with status indicators)
/// - Quality Score (animated progress indicator)
/// - Recent Payments (transaction history)
/// - Quick Actions (fast access buttons)
class SupplierHomeScreen extends ConsumerStatefulWidget {
  const SupplierHomeScreen({super.key});

  @override
  ConsumerState<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends ConsumerState<SupplierHomeScreen>
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

              // ========== PRIMARY CTA: List New Lot ==========
              SlideInTransition(
                begin: const Offset(0, 0.3),
                duration: const Duration(milliseconds: 500),
                child: _buildListNewLotButton(context),
              ),
              const SizedBox(height: 20),

              // ========== LIVE ROLE INTERACTION ==========
              FadeInTransition(
                duration: const Duration(milliseconds: 450),
                child:
                    const LiveRoleExchangePanel(role: LiveActorRole.supplier),
              ),
              const SizedBox(height: 12),
              const FadeInTransition(
                duration: Duration(milliseconds: 420),
                child: ExperienceShortcutsStrip(roleLabel: 'Supplier'),
              ),
              const SizedBox(height: 32),

              // ========== SECTION: Your Active Lots ==========
              _buildSectionHeader(
                icon: Icons.inventory_2_outlined,
                title: 'Your Active Lots',
                subtitle: '12 live • 3 expiring soon',
                action: 'View All',
                onActionTap: () => context.push('/lots'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildActiveLotCard(
                  context,
                  title: 'Premium Cocoa Beans',
                  location: 'Kumasi, Ghana',
                  quantity: '5,000 kg',
                  price: '\$12,500',
                  quality: '94%',
                  daysLeft: '8 days',
                  status: 'active',
                  offers: '23',
                  image: '🍫',
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildActiveLotCard(
                  context,
                  title: 'Shea Butter (Grade A)',
                  location: 'Ouagadougou, Burkina Faso',
                  quantity: '2,000 L',
                  price: '\$8,400',
                  quality: '89%',
                  daysLeft: '3 days',
                  status: 'expiring',
                  offers: '15',
                  image: '🌰',
                ),
              ),
              const SizedBox(height: 24),

              // ========== QUALITY SCORE ==========
              _buildSectionHeader(
                icon: Icons.grade_outlined,
                title: 'Quality Score',
                subtitle: 'This month',
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildQualityScoreCard(context),
              ),
              const SizedBox(height: 24),

              // ========== RECENT PAYMENTS ==========
              _buildSectionHeader(
                icon: Icons.payment_outlined,
                title: 'Recent Payments',
                subtitle: 'Last 30 days',
                action: 'View History',
                onActionTap: () => context.push('/payments'),
              ),
              const SizedBox(height: 12),
              _buildPaymentItem(
                context,
                buyer: 'Global Traders Ltd',
                lot: 'Premium Cocoa Beans',
                amount: '+\$3,125',
                date: '2 days ago',
                status: 'completed',
              ),
              const SizedBox(height: 8),
              _buildPaymentItem(
                context,
                buyer: 'West African Export Co',
                lot: 'Shea Butter',
                amount: '+\$2,100',
                date: '5 days ago',
                status: 'completed',
              ),
              const SizedBox(height: 24),

              // ========== QUICK ACTIONS ==========
              _buildSectionHeader(
                icon: Icons.bolt_outlined,
                title: 'Quick Actions',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Contracts',
                        onTap: () => context.push('/contracts'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.local_shipping_outlined,
                        label: 'Shipments',
                        onTap: () => context.push('/shipments'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.notifications_active_outlined,
                        label: 'Messages',
                        onTap: () => context.push('/messages'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildQuickActionButton(
                        context,
                        icon: Icons.settings_outlined,
                        label: 'Analytics',
                        onTap: () => context.push('/analytics'),
                      ),
                    ),
                  ),
                ],
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
          'Ready to grow your business today?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildListNewLotButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Haptic feedback
        HapticFeedback.mediumImpact();
        context.push('/lots/create');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
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
              context.push('/lots/create');
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
                        'LIST A NEW LOT',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reach 500+ qualified buyers',
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

  Widget _buildActiveLotCard(
    BuildContext context, {
    required String title,
    required String location,
    required String quantity,
    required String price,
    required String quality,
    required String daysLeft,
    required String status,
    required String offers,
    required String image,
  }) {
    final isExpiring = status == 'expiring';
    final borderColor =
        isExpiring ? AppColors.warningOrange : AppColors.borderDefault;
    final badgeColor =
        isExpiring ? AppColors.warningOrangeLight : AppColors.accentBlueLight;
    final badgeTextColor =
        isExpiring ? AppColors.warningOrange : AppColors.accentBlue;

    return GestureDetector(
      onTap: () => context.push('/lots/detail/1'),
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
            onTap: () => context.push('/lots/detail/1'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with image and status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
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
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          daysLeft,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.borderDefault,
                  ),
                  const SizedBox(height: 16),

                  // Details grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem('Quantity', quantity),
                      ),
                      Expanded(
                        child: _buildDetailItem('Price', price),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem('Quality', quality),
                      ),
                      Expanded(
                        child: _buildDetailItem('Offers', offers),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Offer details opened')),
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View Offers'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push('/lots/edit/1');
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Manage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                          ),
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

  Widget _buildQualityScoreCard(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Quality Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '92/100',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.successGreen,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 0.92),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.borderDefault,
                        valueColor: AlwaysStoppedAnimation(
                          value > 0.8
                              ? AppColors.successGreen
                              : AppColors.warningOrange,
                        ),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '📈 Trending up 8% this month',
                            style: TextStyle(
                              color: AppColors.successGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Excellent!',
                            style: TextStyle(
                              color: AppColors.successGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(
    BuildContext context, {
    required String buyer,
    required String lot,
    required String amount,
    required String date,
    required String status,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment from $buyer - Details opened')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.successGreenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyer,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lot,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenLighter,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            Icon(icon, color: AppColors.primaryGreen, size: 22),
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
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
