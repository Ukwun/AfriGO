import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_components.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _timeline = [
    {
      'status': 'Payment Confirmed',
      'timestamp': '2 hours ago',
      'icon': Icons.check_circle,
      'color': AfrigoColors.success,
      'completed': true,
    },
    {
      'status': 'Quality Inspection',
      'timestamp': '1 hour ago',
      'icon': Icons.search,
      'color': AfrigoColors.primary,
      'completed': true,
    },
    {
      'status': 'Packing',
      'timestamp': 'In progress',
      'icon': Icons.local_shipping,
      'color': AfrigoColors.accent,
      'completed': false,
    },
    {
      'status': 'In Transit',
      'timestamp': 'Expected tomorrow',
      'icon': Icons.directions_boat,
      'color': AfrigoColors.neutral300,
      'completed': false,
    },
    {
      'status': 'Delivered',
      'timestamp': 'Expected in 5 days',
      'icon': Icons.home,
      'color': AfrigoColors.neutral300,
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text(
          'Order #${widget.orderId}',
          style: AfrigoTypography.soraHeading5,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeIn,
            ),
          ),
          child: Column(
            children: [
              // Order Summary Card
              Padding(
                padding: const EdgeInsets.all(AfrigoSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AfriBorderRadius.lg,
                    ),
                    border: Border.all(
                      color: AfrigoColors.borderLight,
                    ),
                    boxShadow: AfrigoElevation.shadow1,
                  ),
                  padding: const EdgeInsets.all(AfrigoSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium Cocoa Beans',
                                style: AfrigoTypography.soraHeading5,
                              ),
                              const SizedBox(
                                height: AfrigoSpacing.sm,
                              ),
                              Text(
                                '500 kg • \$2,500',
                                style: AfrigoTypography.bodySmall.copyWith(
                                  color: AfrigoColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AfrigoSpacing.lg,
                              vertical: AfrigoSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AfrigoColors.bgLightAlt,
                              borderRadius: BorderRadius.circular(
                                AfriBorderRadius.lg,
                              ),
                            ),
                            child: Text(
                              'Packing',
                              style: AfrigoTypography.labelSmall.copyWith(
                                color: AfrigoColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AfrigoSpacing.lg,
                      ),
                      Divider(
                        color: AfrigoColors.borderLight,
                        height: AfrigoSpacing.lg,
                      ),
                      const SizedBox(
                        height: AfrigoSpacing.lg,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                            'From',
                            'Ghana, West Africa',
                          ),
                          _buildInfoColumn(
                            'To',
                            'Lagos, Nigeria',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Timeline
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AfrigoSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracking Details',
                      style: AfrigoTypography.soraHeading5,
                    ),
                    const SizedBox(
                      height: AfrigoSpacing.lg,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _timeline.length,
                      itemBuilder: (context, index) {
                        final item = _timeline[index];
                        final isLast = index == _timeline.length - 1;

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AfrigoSpacing.lg,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 600,
                                    ),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: item['completed']
                                          ? item['color']
                                          : Colors.white,
                                      border: Border.all(
                                        color: item['color'] as Color,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AfriBorderRadius.full,
                                      ),
                                      boxShadow: item['completed']
                                          ? AfrigoElevation.shadow2
                                          : [],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        item['icon'],
                                        color: item['completed']
                                            ? Colors.white
                                            : item['color'],
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  if (!isLast) ...[
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      width: 2,
                                      height: 48,
                                      color: item['completed']
                                          ? item['color']
                                          : AfrigoColors.borderLight,
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(
                                width: AfrigoSpacing.lg,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: AfrigoSpacing.md,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['status'],
                                        style: AfrigoTypography.interBody1Semi,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        item['timestamp'],
                                        style:
                                            AfrigoTypography.bodySmall.copyWith(
                                          color: AfrigoColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AfrigoSpacing.xxl,
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AfrigoSpacing.lg,
                ),
                child: Column(
                  children: [
                    ModernButton(
                      onPressed: () {},
                      child: const Text(
                        'Contact Seller',
                      ),
                    ),
                    const SizedBox(
                      height: AfrigoSpacing.md,
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                      ),
                      child: const Text(
                        'Download Invoice',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: AfrigoSpacing.xxl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AfrigoTypography.bodySmall.copyWith(
            color: AfrigoColors.textSecondary,
          ),
        ),
        const SizedBox(
          height: AfrigoSpacing.sm,
        ),
        Text(
          value,
          style: AfrigoTypography.interBody1Semi,
        ),
      ],
    );
  }
}
