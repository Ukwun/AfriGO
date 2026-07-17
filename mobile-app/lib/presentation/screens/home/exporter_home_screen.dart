import 'package:flutter/material.dart';

import '../../widgets/dashboard_role.dart';
import '../../widgets/production_dashboard.dart';

class ExporterHomeScreen extends StatelessWidget {
  const ExporterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProductionDashboard(
        role: DashboardRole.exporter,
        headline: 'Exporter workspace',
        description:
            'Coordinate contracted goods, quality clearance, documentation, and international delivery.',
        actionLabel: 'Start an export shipment',
        actionRoute: '/exports/create',
        feeds: [
          DashboardFeed(
              resource: 'contracts',
              title: 'Active contracts',
              route: '/contracts'),
          DashboardFeed(
              resource: 'quality_inspections',
              title: 'Quality inspections',
              route: '/dossiers'),
          DashboardFeed(
              resource: 'shipments', title: 'Shipments', route: '/shipments'),
          DashboardFeed(
              resource: 'notifications',
              title: 'Operational alerts',
              route: '/notifications'),
        ],
      );
}
