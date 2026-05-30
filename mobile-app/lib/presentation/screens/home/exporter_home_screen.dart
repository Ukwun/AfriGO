import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../providers/live_market_activity_provider.dart';
import '../../widgets/experience_shortcuts_strip.dart';
import '../../widgets/live_role_exchange_panel.dart';
import '../../widgets/motion_system.dart';

/// Exporter Home Screen - Export operations and compliance focused
///
/// Layout:
/// - Export Pipeline (orders moving through fulfillment stages)
/// - Dossiers (export documentation)
/// - Warehouse Slots (inventory & storage management)
/// - Contracts (active export agreements)
/// - Tracking (real-time shipment monitoring)
class ExporterHomeScreen extends ConsumerStatefulWidget {
  const ExporterHomeScreen({super.key});

  @override
  ConsumerState<ExporterHomeScreen> createState() => _ExporterHomeScreenState();
}

class _ExporterHomeScreenState extends ConsumerState<ExporterHomeScreen>
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

              // ========== PRIMARY CTA: Create Export Order ==========
              SlideInTransition(
                begin: const Offset(0, 0.3),
                duration: const Duration(milliseconds: 500),
                child: _buildCreateExportButton(context),
              ),
              const SizedBox(height: 20),

              // ========== LIVE ROLE INTERACTION ==========
              FadeInTransition(
                duration: const Duration(milliseconds: 450),
                child:
                    const LiveRoleExchangePanel(role: LiveActorRole.exporter),
              ),
              const SizedBox(height: 12),
              const FadeInTransition(
                duration: Duration(milliseconds: 420),
                child: ExperienceShortcutsStrip(roleLabel: 'Exporter'),
              ),
              const SizedBox(height: 32),

              // ========== EXPORT PIPELINE ==========
              _buildSectionHeader(
                icon: Icons.timeline_outlined,
                title: 'Export Pipeline',
                subtitle: '8 orders in progress',
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildPipelineStagesCard(context),
              ),
              const SizedBox(height: 24),

              // ========== DOSSIERS ==========
              _buildSectionHeader(
                icon: Icons.folder_outlined,
                title: 'Dossiers',
                subtitle: 'Export documentation',
                action: 'View All',
                onActionTap: () => context.push('/dossiers'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildDossierCard(
                  context,
                  title: 'COCOA-2024-001',
                  description: '5 Tonnes Premium Cocoa Beans',
                  destination: 'Germany',
                  status: 'approved',
                  documents: '8/8',
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildDossierCard(
                  context,
                  title: 'SHEA-2024-002',
                  description: '500L Grade A Shea Butter',
                  destination: 'France',
                  status: 'pending',
                  documents: '6/8',
                ),
              ),
              const SizedBox(height: 24),

              // ========== WAREHOUSE SLOTS ==========
              _buildSectionHeader(
                icon: Icons.warehouse_outlined,
                title: 'Warehouse Slots',
                subtitle: 'Current inventory',
                action: 'Manage',
                onActionTap: () => context.push('/warehouse'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildWarehouseSlotCard(
                        title: 'Slot A1-3',
                        commodity: 'Cocoa Beans',
                        quantity: '2.5T',
                        available: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildWarehouseSlotCard(
                        title: 'Slot B2-1',
                        commodity: 'Shea Butter',
                        quantity: '450L',
                        available: true,
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
                      child: _buildWarehouseSlotCard(
                        title: 'Slot C3-2',
                        commodity: 'Palm Oil',
                        quantity: '800L',
                        available: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildWarehouseSlotCard(
                        title: 'Slot D4-1',
                        commodity: 'Empty',
                        quantity: '—',
                        available: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ========== CONTRACTS ==========
              _buildSectionHeader(
                icon: Icons.description_outlined,
                title: 'Active Contracts',
                subtitle: '5 contracts',
                action: 'View All',
                onActionTap: () => context.push('/contracts'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildContractCard(
                  context,
                  company: 'Global Import Trading Ltd',
                  product: 'Cocoa Beans (Monthly Supply)',
                  volume: '10 Tonnes/Month',
                  nextDelivery: 'June 15, 2026',
                  status: 'active',
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildContractCard(
                  context,
                  company: 'West Europe Export Co',
                  product: 'Shea Butter (Grade A)',
                  volume: '500L per shipment',
                  nextDelivery: 'June 30, 2026',
                  status: 'active',
                ),
              ),
              const SizedBox(height: 24),

              // ========== REAL-TIME TRACKING ==========
              _buildSectionHeader(
                icon: Icons.location_on_outlined,
                title: 'Real-Time Tracking',
                subtitle: '3 shipments active',
                action: 'Track All',
                onActionTap: () => context.push('/tracking'),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildTrackingCard(
                  context,
                  shipmentID: 'EXP-2024-156',
                  commodity: 'Cocoa Beans - 5T',
                  from: 'Kumasi Warehouse',
                  currentLocation: 'Tema Port',
                  to: 'Hamburg, Germany',
                  status: 'at_port',
                  eta: 'June 2, 2026',
                ),
              ),
              const SizedBox(height: 12),
              ScaleInTransition(
                child: _buildTrackingCard(
                  context,
                  shipmentID: 'EXP-2024-155',
                  commodity: 'Shea Butter - 500L',
                  from: 'Ouagadougou Warehouse',
                  currentLocation: 'At Sea',
                  to: 'Marseille, France',
                  status: 'in_transit',
                  eta: 'June 8, 2026',
                ),
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
          'Manage your exports seamlessly',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateExportButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/exports/create');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGold.withOpacity(0.3),
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
              context.push('/exports/create');
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
                        'CREATE EXPORT ORDER',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start a new export shipment',
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

  Widget _buildPipelineStagesCard(BuildContext context) {
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
              'Pipeline Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPipelineStage('📦 Pending', '2', AppColors.warningOrange),
            const SizedBox(height: 12),
            _buildPipelineStage('🔍 Quality Check', '1', AppColors.accentBlue),
            const SizedBox(height: 12),
            _buildPipelineStage('📋 Docs Ready', '3', AppColors.primaryGreen),
            const SizedBox(height: 12),
            _buildPipelineStage('🚢 Shipped', '2', AppColors.successGreen),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/pipeline');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                ),
                child: const Text('View Full Pipeline'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStage(String stage, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            stage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDossierCard(
    BuildContext context, {
    required String title,
    required String description,
    required String destination,
    required String status,
    required String documents,
  }) {
    final isApproved = status == 'approved';
    final dossierId = Uri.encodeComponent(title);

    return GestureDetector(
      onTap: () => context.push('/dossiers/detail/$dossierId'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isApproved ? AppColors.successGreen : AppColors.warningOrange,
            width: 1.5,
          ),
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
            onTap: () => context.push('/dossiers/detail/$dossierId'),
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
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? AppColors.successGreenLight
                              : AppColors.warningOrangeLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isApproved ? '✓ Approved' : '⏳ Pending',
                          style: TextStyle(
                            color: isApproved
                                ? AppColors.successGreen
                                : AppColors.warningOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.borderDefault),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destination',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination,
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
                            'Documents',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            documents,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isApproved
                                      ? AppColors.successGreen
                                      : AppColors.warningOrange,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/dossiers/view/$dossierId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApproved
                            ? AppColors.successGreen
                            : AppColors.warningOrange,
                      ),
                      child: Text(isApproved ? 'Download' : 'Complete'),
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

  Widget _buildWarehouseSlotCard({
    required String title,
    required String commodity,
    required String quantity,
    required bool available,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: available ? AppColors.borderDefault : AppColors.warningOrange,
          width: available ? 1 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title - Details opened')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Icon(
                      available ? Icons.done_all : Icons.warning_rounded,
                      color: available
                          ? AppColors.successGreen
                          : AppColors.warningOrange,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  commodity,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  quantity,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: available
                            ? AppColors.primaryGreen
                            : AppColors.warningOrange,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContractCard(
    BuildContext context, {
    required String company,
    required String product,
    required String volume,
    required String nextDelivery,
    required String status,
  }) {
    return GestureDetector(
      onTap: () => context.push('/contracts/detail/1'),
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
            onTap: () => context.push('/contracts/detail/1'),
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
                              company,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                          color: AppColors.successGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '✓ Active',
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.borderDefault),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Volume',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            volume,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Next Delivery',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextDelivery,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/contracts/manage/1');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text('Manage Contract'),
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

  Widget _buildTrackingCard(
    BuildContext context, {
    required String shipmentID,
    required String commodity,
    required String from,
    required String currentLocation,
    required String to,
    required String status,
    required String eta,
  }) {
    final statusLabel = status == 'at_port' ? '⛴️ At Port' : '🌊 At Sea';
    final statusColor =
        status == 'at_port' ? AppColors.warningOrange : AppColors.accentBlue;

    return GestureDetector(
      onTap: () => context.push('/tracking/detail/$shipmentID'),
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
            onTap: () => context.push('/tracking/detail/$shipmentID'),
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
                        shipmentID,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    commodity,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),

                  // Route with live location
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
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ],
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

                  // Live location indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Currently: $currentLocation',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ETA: $eta',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
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
            Icon(icon, color: AppColors.secondaryGold, size: 22),
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
                color: AppColors.secondaryGold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
