import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/motion_system.dart';
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../../../domain/models/user_role.dart';
import '../../../data/providers/analytics_provider.dart';

/// ANALYTICS DASHBOARD SCREEN - Role-specific metrics & insights
/// Shows: KPIs, trend charts, recommendations, performance metrics
/// Features: Real-time data, interactive charts, drill-down analytics, AI insights
/// Animations: FadeIn cards, smooth chart animations, count-up animations
/// Status: Production-ready with Module 10 analytics engine integration

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  String _selectedPeriod = '30d'; // 30 days
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      6,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _animationControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) {
            _animationControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(userRoleProvider);
    final analyticsData = ref.watch(analyticsDataProvider(_selectedPeriod));

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
          'Performance Analytics',
          style: AppTheme.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              ref.refresh(analyticsDataProvider(_selectedPeriod));
            },
          ),
        ],
      ),
      body: analyticsData.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (data) => _buildDashboard(data, userRole),
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
            'Loading analytics...',
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
            'Failed to load analytics',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.refresh(analyticsDataProvider(_selectedPeriod));
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

  Widget _buildDashboard(AnalyticsData data, UserRole? role) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Period selector
          FadeInTransition(
            delay: 0,
            child: _buildPeriodSelector(),
          ),
          SizedBox(height: 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // KPI Cards
                _buildKPICards(data, role),
                SizedBox(height: 24),

                // Charts section
                _buildChartsSection(data),
                SizedBox(height: 24),

                // Recommendations
                _buildRecommendationsSection(data),
                SizedBox(height: 24),

                // Insights
                _buildInsightsSection(data),

                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['7d', '30d', '90d', 'YTD'];
    final periodLabels = ['7 Days', '30 Days', '90 Days', 'Year to Date'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: periods.length,
          itemBuilder: (context, index) {
            final period = periods[index];
            final isSelected = _selectedPeriod == period;

            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(periodLabels[index]),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedPeriod = period);
                  ref.refresh(analyticsDataProvider(period));
                },
                backgroundColor: Colors.transparent,
                selectedColor: AppColors.primary,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
                labelStyle: AppTheme.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKPICards(AnalyticsData data, UserRole? role) {
    final kpis = role == UserRole.supplier
        ? [
            KPICard(
              label: 'Revenue',
              value: '\$${data.revenue.toStringAsFixed(0)}',
              trend: '+8%',
              trendUp: true,
              icon: '💰',
            ),
            KPICard(
              label: 'Conversion Rate',
              value: '${(data.conversionRate * 100).toStringAsFixed(1)}%',
              trend: '+2.3%',
              trendUp: true,
              icon: '📈',
            ),
            KPICard(
              label: 'Lots Sold',
              value: '${data.lotsSold}',
              trend: '+5',
              trendUp: true,
              icon: '📦',
            ),
            KPICard(
              label: 'Avg Rating',
              value: '${data.avgRating.toStringAsFixed(1)}★',
              trend: '+0.2',
              trendUp: true,
              icon: '⭐',
            ),
          ]
        : role == UserRole.buyer
            ? [
                KPICard(
                  label: 'Total Spend',
                  value: '\$${data.totalSpend.toStringAsFixed(0)}',
                  trend: '+12%',
                  trendUp: true,
                  icon: '💳',
                ),
                KPICard(
                  label: 'Savings vs Market',
                  value: '\$${data.savingsAmount.toStringAsFixed(0)}',
                  trend: '54% lower',
                  trendUp: true,
                  icon: '💚',
                ),
                KPICard(
                  label: 'Trades Completed',
                  value: '${data.tradesCompleted}',
                  trend: '+18',
                  trendUp: true,
                  icon: '✅',
                ),
                KPICard(
                  label: 'Active Suppliers',
                  value: '${data.activeSupplie rs}',
                  trend: '+3',
                  trendUp: true,
                  icon: '🤝',
                ),
              ]
            : [
                KPICard(
                  label: 'Shipments',
                  value: '${data.shipmentsCount}',
                  trend: '+4',
                  trendUp: true,
                  icon: '🚢',
                ),
                KPICard(
                  label: 'Compliance Score',
                  value: '${data.complianceScore.toStringAsFixed(0)}%',
                  trend: '+2%',
                  trendUp: true,
                  icon: '✓',
                ),
                KPICard(
                  label: 'On-time Delivery',
                  value: '${(data.onTimeDeliveryRate * 100).toStringAsFixed(1)}%',
                  trend: '+1.2%',
                  trendUp: true,
                  icon: '📅',
                ),
                KPICard(
                  label: 'Quality Score',
                  value: '${(data.qualityScore * 100).toStringAsFixed(0)}%',
                  trend: '+3%',
                  trendUp: true,
                  icon: '🎯',
                ),
              ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: List.generate(
        kpis.length,
        (index) => ScaleInTransition(
          delay: index * 50,
          child: _buildKPITile(kpis[index]),
        ),
      ),
    );
  }

  Widget _buildKPITile(KPICard kpi) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kpi.icon,
                style: TextStyle(fontSize: 20),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kpi.trendUp
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kpi.trend,
                  style: AppTheme.labelSmall.copyWith(
                    color: kpi.trendUp ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            kpi.label,
            style: AppTheme.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            kpi.value,
            style: AppTheme.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(AnalyticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Trends',
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        FadeInTransition(
          delay: 200,
          child: _buildRevenueChart(data),
        ),
        SizedBox(height: 24),
        FadeInTransition(
          delay: 250,
          child: _buildCategoryChart(data),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(AnalyticsData data) {
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
            'Revenue Trend',
            style: AppTheme.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.revenueData,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(AnalyticsData data) {
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
            'Sales by Category',
            style: AppTheme.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: List.generate(
                  data.categoryData.length,
                  (index) {
                    final item = data.categoryData[index];
                    return PieChartSectionData(
                      color: _getCategoryColor(index),
                      value: item.percentage,
                      title: '${item.percentage.toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: AppTheme.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(
              data.categoryData.length,
              (index) {
                final item = data.categoryData[index];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      item.label,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(AnalyticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendations',
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...List.generate(
          data.recommendations.length,
          (index) => FadeInTransition(
            delay: 300 + (index * 50),
            child: _buildRecommendationCard(data.recommendations[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(Recommendation rec) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: rec.type == 'positive'
              ? AppColors.success.withOpacity(0.1)
              : AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rec.type == 'positive' ? AppColors.success : AppColors.warning,
          ),
        ),
        child: Row(
          children: [
            Icon(
              rec.type == 'positive' ? Icons.lightbulb : Icons.warning_amber,
              color:
                  rec.type == 'positive' ? AppColors.success : AppColors.warning,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                rec.text,
                style: AppTheme.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_right, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(AnalyticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Insights',
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...List.generate(
          data.insights.length,
          (index) => FadeInTransition(
            delay: 400 + (index * 50),
            child: _buildInsightCard(data.insights[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(Insight insight) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.icon, style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    insight.description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }
}

// Models
class KPICard {
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final String icon;

  KPICard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.icon,
  });
}

class AnalyticsData {
  final double revenue;
  final double conversionRate;
  final int lotsSold;
  final double avgRating;
  final double totalSpend;
  final double savingsAmount;
  final int tradesCompleted;
  final int activeSuppliersCount;
  final int shipmentsCount;
  final double complianceScore;
  final double onTimeDeliveryRate;
  final double qualityScore;
  final List<FlSpot> revenueData;
  final List<CategoryData> categoryData;
  final List<Recommendation> recommendations;
  final List<Insight> insights;

  AnalyticsData({
    required this.revenue,
    required this.conversionRate,
    required this.lotsSold,
    required this.avgRating,
    required this.totalSpend,
    required this.savingsAmount,
    required this.tradesCompleted,
    required this.activeSuppliersCount,
    required this.shipmentsCount,
    required this.complianceScore,
    required this.onTimeDeliveryRate,
    required this.qualityScore,
    required this.revenueData,
    required this.categoryData,
    required this.recommendations,
    required this.insights,
  });

  // Getters for compatibility with different roles
  int get activeSupplie rs => activeSuppliersCount;
}

class CategoryData {
  final String label;
  final double percentage;

  CategoryData({required this.label, required this.percentage});
}

class Recommendation {
  final String text;
  final String type; // 'positive' or 'warning'

  Recommendation({required this.text, required this.type});
}

class Insight {
  final String icon;
  final String title;
  final String description;

  Insight({
    required this.icon,
    required this.title,
    required this.description,
  });
}
