import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards
              Row(
                children: [
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildKPICard(
                        title: 'Total Trade Volume',
                        value: '\$125,400',
                        change: '+18% vs last month',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildKPICard(
                        title: 'Active Trades',
                        value: '12',
                        change: '3 new this week',
                        icon: Icons.sync,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildKPICard(
                        title: 'Avg. Order Value',
                        value: '\$10,450',
                        change: '+5% vs last month',
                        icon: Icons.receipt,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ScaleInTransition(
                      child: _buildKPICard(
                        title: 'Success Rate',
                        value: '94%',
                        change: 'Completed trades',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Category Breakdown
              Text(
                'Trading by Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SlideInTransition(
                child: _buildCategoryRow('Cocoa', 45000, 0.36, Colors.brown),
              ),
              const SizedBox(height: 8),
              SlideInTransition(
                child: _buildCategoryRow(
                    'Shea Butter', 38000, 0.30, Colors.orange),
              ),
              const SizedBox(height: 8),
              SlideInTransition(
                child: _buildCategoryRow('Cashew', 28400, 0.23, Colors.amber),
              ),
              const SizedBox(height: 8),
              SlideInTransition(
                child: _buildCategoryRow('Other', 14000, 0.11, Colors.grey),
              ),
              const SizedBox(height: 28),

              // Top Suppliers (for buyers)
              Text(
                'Top Suppliers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...List.generate(3, (index) {
                final suppliers = [
                  ('Premium Cocoa Co', '\$45,000', '12 trades'),
                  ('Shea Butter Ltd', '\$38,000', '8 trades'),
                  ('African Cashew Exports', '\$28,400', '6 trades'),
                ];
                final (name, volume, trades) = suppliers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SlideInTransition(
                    child: _buildSupplierTile(name, volume, trades),
                  ),
                );
              }),
            ],
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              change,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
      String label, int value, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '\$${value.toString()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierTile(String name, String volume, String trades) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  trades,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Text(
              volume,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
