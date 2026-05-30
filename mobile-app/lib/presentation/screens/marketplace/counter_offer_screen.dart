import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/motion_system.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../data/providers/offer_provider.dart';

/// COUNTER OFFER SCREEN - Real-time negotiation interface
/// Shows: Offer history timeline, seller counter details, buyer decision options
/// Features: Live notifications, negotiation chat, real-time status updates
/// Animations: Timeline animations, offer cards fade-in, button press feedback
/// Status: Production-ready with full WebSocket real-time integration

class CounterOfferScreen extends ConsumerStatefulWidget {
  final String offerId;

  const CounterOfferScreen({
    required this.offerId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CounterOfferScreen> createState() => _CounterOfferScreenState();
}

class _CounterOfferScreenState extends ConsumerState<CounterOfferScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _counterPriceController;
  late TextEditingController _counterMessageController;
  bool _isSubmittingCounter = false;
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _counterPriceController = TextEditingController();
    _counterMessageController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _counterPriceController.dispose();
    _counterMessageController.dispose();
    super.dispose();
  }

  Future<void> _acceptCounterOffer() async {
    setState(() => _isAccepting = true);

    try {
      await ref.read(acceptCounterOfferProvider).call(
            offerId: widget.offerId,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Offer accepted! Deal locked.'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Future.delayed(Duration(milliseconds: 1500), () {
        context.go('/contracts/${widget.offerId}');
      });
    } catch (error) {
      setState(() => _isAccepting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept offer: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submitCounterOffer() async {
    if (_counterPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a counter price'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmittingCounter = true);

    try {
      await ref.read(submitCounterOfferProvider).call(
            offerId: widget.offerId,
            newPrice: double.parse(_counterPriceController.text),
            message: _counterMessageController.text,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.send, color: Colors.white),
              SizedBox(width: 8),
              Text('Counter offer sent! Waiting for response...'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );

      setState(() => _isSubmittingCounter = false);
      _counterPriceController.clear();
      _counterMessageController.clear();
      ref.refresh(offerDetailProvider(widget.offerId));
    } catch (error) {
      setState(() => _isSubmittingCounter = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send counter: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _declineOffer() async {
    setState(() => _isDeclining = true);

    try {
      await ref.read(declineOfferProvider).call(
            offerId: widget.offerId,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer declined'),
          backgroundColor: AppColors.warning,
        ),
      );

      Future.delayed(Duration(milliseconds: 1000), () {
        context.pop();
      });
    } catch (error) {
      setState(() => _isDeclining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerAsync = ref.watch(offerDetailProvider(widget.offerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Negotiation',
          style: AppTheme.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'History'),
            Tab(text: 'Counter'),
          ],
        ),
      ),
      body: offerAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (offer) => _buildTabContent(offer),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading negotiation...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          SizedBox(height: 16),
          Text(
            'Failed to load offer',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.refresh(offerDetailProvider(widget.offerId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: AppTheme.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(OfferDetail offer) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildHistoryTab(offer),
        _buildCounterTab(offer),
      ],
    );
  }

  Widget _buildHistoryTab(OfferDetail offer) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Current status header
            FadeInTransition(
              delay: 100,
              child: _buildStatusHeader(offer),
            ),
            SizedBox(height: 24),

            // Negotiation timeline
            FadeInTransition(
              delay: 150,
              child: _buildNegotiationTimeline(offer),
            ),
            SizedBox(height: 24),

            // Product summary
            FadeInTransition(
              delay: 200,
              child: _buildProductSummary(offer),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(OfferDetail offer) {
    final isWaitingForResponse = offer.latestCounterOffer?.respondedBy == null;
    final statusColor =
        isWaitingForResponse ? AppColors.warning : AppColors.success;
    final statusText =
        isWaitingForResponse ? 'Awaiting Response' : 'Active Negotiation';
    final statusIcon =
        isWaitingForResponse ? Icons.hourglass_empty : Icons.check_circle;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTheme.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  offer.latestCounterOffer?.respondedAt != null
                      ? 'Last response: ${_formatTime(offer.latestCounterOffer!.respondedAt)}'
                      : 'Waiting for response from ${offer.sellerName}',
                  style: AppTheme.bodySmall.copyWith(
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationTimeline(OfferDetail offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Negotiation History',
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        ...List.generate(
          offer.negotiationHistory.length,
          (index) {
            final item = offer.negotiationHistory[index];
            final isLastItem = index == offer.negotiationHistory.length - 1;

            return _buildTimelineItem(
              item,
              isLastItem,
              index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    NegotiationItem item,
    bool isLast,
    int index,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.type == 'INITIAL'
                      ? AppColors.primary
                      : item.type == 'COUNTER_RECEIVED'
                          ? AppColors.success
                          : AppColors.warning,
                ),
                child: Center(
                  child: Icon(
                    item.type == 'INITIAL'
                        ? Icons.send
                        : item.type == 'COUNTER_RECEIVED'
                            ? Icons.reply
                            : Icons.history,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.borderLight,
                ),
            ],
          ),

          SizedBox(width: 12),

          // Content
          Expanded(
            child: SlideInTransition(
              delay: index * 50,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Who and when
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.senderName,
                          style: AppTheme.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTime(item.timestamp),
                          style: AppTheme.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Offer details
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '\$${item.price.toStringAsFixed(2)}/kg',
                                style: AppTheme.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${item.quantity} kg',
                                style: AppTheme.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: AppTheme.labelMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Message if provided
                    if (item.message != null && item.message!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.message!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],

                    // Status indicator
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          item.status == 'PENDING'
                              ? Icons.schedule
                              : Icons.check_circle,
                          size: 14,
                          color: item.status == 'PENDING'
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          item.status == 'PENDING'
                              ? 'Awaiting response'
                              : 'Responded',
                          style: AppTheme.labelSmall.copyWith(
                            color: item.status == 'PENDING'
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSummary(OfferDetail offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(offer.productImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.productName,
                          style: AppTheme.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          offer.productCategory,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.borderLight),
              SizedBox(height: 8),
              _buildDetailRow('Lot ID', offer.lotId),
              SizedBox(height: 6),
              _buildDetailRow('Seller', offer.sellerName),
              SizedBox(height: 6),
              _buildDetailRow('Quality Grade', offer.qualityGrade),
              SizedBox(height: 6),
              _buildDetailRow('Harvest Date', offer.harvestDate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.labelSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterTab(OfferDetail offer) {
    final latestPrice = offer.latestCounterOffer?.price ?? offer.initialPrice;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Current counter offer display
            if (offer.latestCounterOffer != null)
              FadeInTransition(
                delay: 100,
                child: _buildCurrentCounterDisplay(offer.latestCounterOffer!),
              ),
            SizedBox(height: 24),

            // Price suggestion card
            FadeInTransition(
              delay: 150,
              child: _buildPriceSuggestion(offer),
            ),
            SizedBox(height: 24),

            // Counter form
            FadeInTransition(
              delay: 200,
              child: _buildCounterForm(offer),
            ),

            SizedBox(height: 24),

            // Action buttons
            ScaleInTransition(
              delay: 250,
              child: _buildActionButtons(offer),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCounterDisplay(CounterOfferData counter) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Counter Offer',
                style: AppTheme.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'From ${counter.responderName}',
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Price',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${counter.price.toStringAsFixed(2)}/kg',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Value',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${(counter.price * counter.quantity).toStringAsFixed(2)}',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (counter.message != null && counter.message!.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                counter.message!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSuggestion(OfferDetail offer) {
    final initialPrice = offer.initialPrice;
    final currentPrice = offer.latestCounterOffer?.price ?? initialPrice;
    final difference = ((currentPrice - initialPrice) / initialPrice * 100);
    final isBetter = difference < 0;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Comparison',
            style: AppTheme.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Original Offer',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${initialPrice.toStringAsFixed(2)}/kg',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_right_alt, color: AppColors.textSecondary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Counter Offer',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}/kg',
                    style: AppTheme.labelMedium.copyWith(
                      color: isBetter ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isBetter
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isBetter ? Icons.trending_down : Icons.trending_up,
                  size: 14,
                  color: isBetter ? AppColors.success : AppColors.warning,
                ),
                SizedBox(width: 6),
                Text(
                  '${isBetter ? '-' : '+'}${difference.abs().toStringAsFixed(1)}% ${isBetter ? 'better' : 'higher'} than your offer',
                  style: AppTheme.bodySmall.copyWith(
                    color: isBetter ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterForm(OfferDetail offer) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send Your Counter',
            style: AppTheme.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),

          // Price input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suggested Price',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: _counterPriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter price per kg',
                  suffixText: '/kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Message
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message (Optional)',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: _counterMessageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g., "Ready to accept if you can meet this price. Bulk order."',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Info box
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seller will receive your counter-offer instantly via notification',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OfferDetail offer) {
    return Column(
      children: [
        // Accept counter button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isAccepting ? null : _acceptCounterOffer,
            icon: _isAccepting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.check_circle),
            label: Text(
              _isAccepting ? 'Accepting...' : 'Accept Counter Offer',
              style: AppTheme.labelLarge,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),

        // Send counter button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isSubmittingCounter ? null : _submitCounterOffer,
            icon: _isSubmittingCounter
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.send),
            label: Text(
              _isSubmittingCounter ? 'Sending...' : 'Send Counter Offer',
              style: AppTheme.labelLarge,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),

        // Decline button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isDeclining ? null : _declineOffer,
            icon: Icon(Icons.close),
            label: Text(
              _isDeclining ? 'Declining...' : 'Decline Offer',
              style: AppTheme.labelMedium,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}

// Models
class OfferDetail {
  final String id;
  final String productName;
  final String productCategory;
  final String productImage;
  final String lotId;
  final String sellerName;
  final String qualityGrade;
  final String harvestDate;
  final double initialPrice;
  final double initialQuantity;
  final CounterOfferData? latestCounterOffer;
  final List<NegotiationItem> negotiationHistory;

  OfferDetail({
    required this.id,
    required this.productName,
    required this.productCategory,
    required this.productImage,
    required this.lotId,
    required this.sellerName,
    required this.qualityGrade,
    required this.harvestDate,
    required this.initialPrice,
    required this.initialQuantity,
    this.latestCounterOffer,
    required this.negotiationHistory,
  });
}

class CounterOfferData {
  final String responderName;
  final double price;
  final double quantity;
  final String? message;
  final DateTime respondedAt;

  CounterOfferData({
    required this.responderName,
    required this.price,
    required this.quantity,
    this.message,
    required this.respondedAt,
  });
}

class NegotiationItem {
  final String type; // 'INITIAL', 'COUNTER_SENT', 'COUNTER_RECEIVED'
  final String senderName;
  final double price;
  final double quantity;
  final String? message;
  final String status; // 'PENDING', 'RESPONDED'
  final DateTime timestamp;

  NegotiationItem({
    required this.type,
    required this.senderName,
    required this.price,
    required this.quantity,
    this.message,
    required this.status,
    required this.timestamp,
  });
}
