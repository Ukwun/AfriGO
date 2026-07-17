import 'package:flutter/material.dart';

import '../../widgets/dashboard_role.dart';
import '../../widgets/production_dashboard.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProductionDashboard(
        role: DashboardRole.buyer,
        headline: 'Buyer workspace',
        description:
            'Source verified goods, compare live offers, and follow every order through delivery.',
        actionLabel: 'Create a request for quote',
        actionRoute: '/rfqs/create',
        feeds: [
          DashboardFeed(resource: 'rfqs', title: 'Open RFQs', route: '/rfqs'),
          DashboardFeed(
              resource: 'contracts', title: 'Contracts', route: '/contracts'),
          DashboardFeed(
              resource: 'shipments', title: 'Shipments', route: '/shipments'),
        ],
      );
}
