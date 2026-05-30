import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});
  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text('Buyer Dashboard', style: AfrigoTypography.soraHeading5),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AfrigoSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Trading Requests',
                style: AfrigoTypography.soraHeading4,
              ),
              const SizedBox(height: AfrigoSpacing.lg),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AfrigoSpacing.lg),
                    child: Padding(
                      padding: const EdgeInsets.all(AfrigoSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trading Request ${index + 1}',
                            style: AfrigoTypography.soraHeading5,
                          ),
                          const SizedBox(height: AfrigoSpacing.md),
                          Text(
                            'Quantity: 1000 units',
                            style: AfrigoTypography.interBody2.copyWith(
                              color: AfrigoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
