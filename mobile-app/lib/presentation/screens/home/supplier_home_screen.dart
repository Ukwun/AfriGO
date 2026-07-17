import 'package:flutter/material.dart';

import '../../widgets/dashboard_role.dart';
import '../../widgets/production_dashboard.dart';

class SupplierHomeScreen extends StatelessWidget {
  const SupplierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProductionDashboard(
        role: DashboardRole.supplier,
        headline: 'Supplier workspace',
        description:
            'Publish real inventory, respond to buyers, and track fulfilment and settlement.',
        actionLabel: 'List a new lot',
        actionRoute: '/lots/create',
        feeds: [
          DashboardFeed(resource: 'lots', title: 'Active lots', route: '/lots'),
          DashboardFeed(
              resource: 'offers',
              title: 'Offers',
              route: '/trading/seller-rfqs'),
          DashboardFeed(
              resource: 'contracts', title: 'Contracts', route: '/contracts'),
          DashboardFeed(
              resource: 'shipments', title: 'Shipments', route: '/shipments'),
        ],
      );
}
