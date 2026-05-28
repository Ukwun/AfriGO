import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../models/quality_model.dart';
import '../providers/quality_provider.dart';

class QualityStatsScreen extends ConsumerWidget {
  const QualityStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(qualityStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Statistics'),
      ),
      body: statsAsync.when(
        data: (stats) => _buildStatsContent(context, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, QualityStatsModel stats) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grade Distribution Chart
            const Text(
              'Grade Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _GradeChartVisualizer(
                  gradeA: stats.gradeAPercentage,
                  gradeB: stats.gradeBPercentage,
                  gradeC: stats.gradeCPercentage,
                  rejected: stats.rejectedPercentage,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Grade Statistics Cards
            const Text(
              'Grade Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _GradeStatCard(
              grade: 'A',
              percentage: stats.gradeAPercentage,
              color: Colors.green,
              description: 'Excellent Quality',
            ),
            const SizedBox(height: 12),
            _GradeStatCard(
              grade: 'B',
              percentage: stats.gradeBPercentage,
              color: Colors.blue,
              description: 'Good Quality',
            ),
            const SizedBox(height: 12),
            _GradeStatCard(
              grade: 'C',
              percentage: stats.gradeCPercentage,
              color: Colors.orange,
              description: 'Fair Quality',
            ),
            const SizedBox(height: 12),
            _GradeStatCard(
              grade: 'Rejected',
              percentage: stats.rejectedPercentage,
              color: Colors.red,
              description: 'Below Standards',
            ),
            const SizedBox(height: 24),

            // Key Insights
            const Text(
              'Key Insights',
              style: TextStyle(
                  fontSize: 18, fontWeight: AspectRatio.decorationChild),
            ),
            const SizedBox(height: 16),
            _buildInsights(stats),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(QualityStatsModel stats) {
    final totalGood = stats.gradeAPercentage + stats.gradeBPercentage;
    final message = totalGood >= 80
        ? 'Excellent! Over 80% of products meet high quality standards.'
        : totalGood >= 60
            ? 'Good. Most products pass quality checks.'
            : 'Attention needed. Consider quality improvement initiatives.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Quality Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, height: 1.6),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InsightMetric('Grade A+B', '${(totalGood).toStringAsFixed(1)}%'),
              _InsightMetric('Rejection Rate',
                  '${stats.rejectedPercentage.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeChartVisualizer extends StatelessWidget {
  final double gradeA;
  final double gradeB;
  final double gradeC;
  final double rejected;

  const _GradeChartVisualizer({
    required this.gradeA,
    required this.gradeB,
    required this.gradeC,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final total = gradeA + gradeB + gradeC + rejected;
    final normalizedTotal = total > 0 ? total : 100;

    return Column(
      children: [
        // Horizontal Bar Chart
        Container(
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Row(
            children: [
              _BarSegment(
                percentage: (gradeA / normalizedTotal) * 100,
                color: Colors.green,
                label: 'A',
              ),
              _BarSegment(
                percentage: (gradeB / normalizedTotal) * 100,
                color: Colors.blue,
                label: 'B',
              ),
              _BarSegment(
                percentage: (gradeC / normalizedTotal) * 100,
                color: Colors.orange,
                label: 'C',
              ),
              _BarSegment(
                percentage: (rejected / normalizedTotal) * 100,
                color: Colors.red,
                label: 'Rejected',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Legend
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _LegendItem('Grade A', gradeA.toStringAsFixed(1), Colors.green),
            _LegendItem('Grade B', gradeB.toStringAsFixed(1), Colors.blue),
            _LegendItem('Grade C', gradeC.toStringAsFixed(1), Colors.orange),
            _LegendItem('Rejected', rejected.toStringAsFixed(1), Colors.red),
          ],
        ),
      ],
    );
  }
}

class _BarSegment extends StatelessWidget {
  final double percentage;
  final Color color;
  final String label;

  const _BarSegment({
    required this.percentage,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (percentage <= 0) return const SizedBox.shrink();

    return Expanded(
      flex: (percentage * 100).toInt(),
      child: Container(
        color: color,
        child: Center(
          child: percentage > 8
              ? Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String percentage;
  final Color color;

  const _LegendItem(this.label, this.percentage, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GradeStatCard extends StatelessWidget {
  final String grade;
  final double percentage;
  final Color color;
  final String description;

  const _GradeStatCard({
    required this.grade,
    required this.percentage,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}% of products',
                    style: const TextStyle(
                      color: Colors.grey,
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
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightMetric extends StatelessWidget {
  final String label;
  final String value;

  const _InsightMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
