import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});
  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text('Seller Dashboard', style: AfrigoTypography.soraHeading5),
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
                'Your Listings',
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
                            'Product ${index + 1}',
                            style: AfrigoTypography.soraHeading5,
                          ),
                          const SizedBox(height: AfrigoSpacing.md),
                          Text(
                            'Price: \$100/unit',
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
