import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuyerAnalyticsScreen extends ConsumerStatefulWidget {
  const BuyerAnalyticsScreen({super.key});

  @override
  ConsumerState<BuyerAnalyticsScreen> createState() =>
      _BuyerAnalyticsScreenState();
}

class _BuyerAnalyticsScreenState extends ConsumerState<BuyerAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FadeTransition(
        opacity:
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsRow(theme),
                const SizedBox(height: 24),
                _buildChartSection(theme),
                const SizedBox(height: 24),
                _buildTopSuppliersSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(ThemeData theme) {
    final metrics = [
      {'label': 'Total Spent', 'value': '\$45,600', 'color': Colors.blue},
      {'label': 'Avg Order', 'value': '\$1,850', 'color': Colors.green},
      {'label': 'Orders', 'value': '24', 'color': Colors.purple},
      {'label': 'Savings', 'value': '\$3,200', 'color': Colors.orange},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          metrics.length,
          (index) => Padding(
            padding:
                EdgeInsets.only(right: index < metrics.length - 1 ? 12 : 0),
            child: ScaleTransition(
              scale: CurvedAnimation(
                  parent: _fadeController, curve: Curves.elasticOut),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metrics[index]['label'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        metrics[index]['value'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: metrics[index]['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Trends',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBarChart(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(ThemeData theme) {
    final data = [45, 38, 52, 48, 61, 55, 42];
    final maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          data.length,
          (index) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: data[index] / maxValue),
                  duration: Duration(milliseconds: 800 + (100 * index)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Container(
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      height: (160 * value),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSuppliersSection(ThemeData theme) {
    final suppliers = [
      {'name': 'Premium Agriculture', 'rating': 4.8, 'orders': 12},
      {'name': 'Fresh Produce Co.', 'rating': 4.6, 'orders': 8},
      {'name': 'Global Farms', 'rating': 4.9, 'orders': 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Suppliers',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            suppliers.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
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
                              suppliers[index]['name'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${suppliers[index]['rating']} • ${suppliers[index]['orders']} orders',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
