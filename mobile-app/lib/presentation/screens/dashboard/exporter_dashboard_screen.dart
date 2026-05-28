import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../presentation/providers/auth_provider.dart';

class ExporterDashboardScreen extends StatefulWidget {
  const ExporterDashboardScreen({super.key});

  @override
  State<ExporterDashboardScreen> createState() =>
      _ExporterDashboardScreenState();
}

class _ExporterDashboardScreenState extends State<ExporterDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfriGo Exporter'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: 'Shipments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildShipmentsPage();
      case 2:
        return _buildDocumentsPage();
      case 3:
        return _buildProfilePage();
      default:
        return const SizedBox();
    }
  }

  /// DASHBOARD PAGE - Overview of shipments and exports
  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Shipments Summary
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Shipments',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '3 awaiting customs clearance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Key Metrics
            Text(
              'Export Metrics',
              style: AfrigoTypography.headingMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricCard('Goods Exported', '\$450K', Colors.blue),
                _buildMetricCard('Containers', '12', Colors.orange),
                _buildMetricCard('Destinations', '6', Colors.purple),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: AfrigoTypography.headingMedium,
            ),
            const SizedBox(height: 12),
            _buildActivityFeed(),

            const SizedBox(height: 24),

            // Compliance Status
            Text(
              'Compliance Status',
              style: AfrigoTypography.headingMedium,
            ),
            const SizedBox(height: 12),
            _buildComplianceStatus(),
          ],
        ),
      ),
    );
  }

  /// SHIPMENTS PAGE - Manage active shipments
  Widget _buildShipmentsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipments',
                  style: AfrigoTypography.headingMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('New Shipment'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shipments listing
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) {
                final shipments = [
                  {
                    'trackingNo': 'AFRI-2024-001842',
                    'destination': 'Rotterdam, Netherlands',
                    'product': 'Cocoa Beans - Grade A',
                    'weight': '20 MT',
                    'status': 'In Transit',
                    'eta': '2024-04-25',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001841',
                    'destination': 'Hamburg, Germany',
                    'product': 'Coffee Beans - Arabica',
                    'weight': '15 MT',
                    'status': 'Customs Clearance',
                    'eta': '2024-04-22',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001840',
                    'destination': 'Shanghai, China',
                    'product': 'Shea Butter - Organic',
                    'weight': '10 MT',
                    'status': 'Loaded',
                    'eta': '2024-05-10',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001839',
                    'destination': 'Dubai, UAE',
                    'product': 'Premium Tea - Loose Leaf',
                    'weight': '5 MT',
                    'status': 'In Transit',
                    'eta': '2024-04-28',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001838',
                    'destination': 'Singapore',
                    'product': 'Spice Mix - Premium Blend',
                    'weight': '8 MT',
                    'status': 'Port Departure',
                    'eta': '2024-05-15',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001837',
                    'destination': 'Port Said, Egypt',
                    'product': 'Cocoa & Coffee Bundle',
                    'weight': '25 MT',
                    'status': 'In Transit',
                    'eta': '2024-04-20',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001836',
                    'destination': 'Los Angeles, USA',
                    'product': 'Organic Coffee & Tea',
                    'weight': '18 MT',
                    'status': 'Pending Departure',
                    'eta': '2024-05-05',
                  },
                  {
                    'trackingNo': 'AFRI-2024-001835',
                    'destination': 'London, UK',
                    'product': 'Premium Spice Mix',
                    'weight': '6 MT',
                    'status': 'Delivered',
                    'eta': '2024-04-15',
                  },
                ];
                final shipment = shipments[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shipment['trackingNo']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    shipment['destination']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(shipment['status']!),
                              backgroundColor: shipment['status'] == 'Delivered'
                                  ? Colors.green[100]
                                  : shipment['status'] == 'Customs Clearance'
                                      ? Colors.orange[100]
                                      : Colors.blue[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipment['product']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${shipment['weight']} • ETA: ${shipment['eta']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.track_changes),
                              label: const Text('Track'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.description),
                              label: const Text('Docs'),
                            ),
                          ],
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
    );
  }

  /// DOCUMENTS PAGE - Export documentation
  Widget _buildDocumentsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Export Documents',
                  style: AfrigoTypography.headingMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Documents listing
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                final documents = [
                  {
                    'name': 'CE Certificate of Origin',
                    'trackingNo': 'AFRI-2024-001842',
                    'status': 'Verified',
                    'type': 'Legal Document',
                    'date': '2024-04-18',
                  },
                  {
                    'name': 'Packing List - Container #1',
                    'trackingNo': 'AFRI-2024-001841',
                    'status': 'Approved',
                    'type': 'Logistics',
                    'date': '2024-04-17',
                  },
                  {
                    'name': 'Commercial Invoice',
                    'trackingNo': 'AFRI-2024-001840',
                    'status': 'Pending Review',
                    'type': 'Financial',
                    'date': '2024-04-16',
                  },
                  {
                    'name': 'Bill of Lading',
                    'trackingNo': 'AFRI-2024-001839',
                    'status': 'Verified',
                    'type': 'Legal Document',
                    'date': '2024-04-15',
                  },
                  {
                    'name': 'Quality Inspection Report',
                    'trackingNo': 'AFRI-2024-001838',
                    'status': 'Approved',
                    'type': 'Quality Control',
                    'date': '2024-04-14',
                  },
                  {
                    'name': 'Export License',
                    'trackingNo': 'AFRI-2024-001837',
                    'status': 'Rejected',
                    'type': 'Regulatory',
                    'date': '2024-04-13',
                  },
                ];
                final doc = documents[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    doc['trackingNo']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(doc['status']!),
                              backgroundColor: doc['status'] == 'Verified'
                                  ? Colors.green[100]
                                  : doc['status'] == 'Approved'
                                      ? Colors.green[100]
                                      : doc['status'] == 'Rejected'
                                          ? Colors.red[100]
                                          : Colors.yellow[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              doc['type']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              doc['date']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                              label: const Text('Download'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility),
                              label: const Text('View'),
                            ),
                          ],
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
    );
  }

  /// PROFILE PAGE - Exporter profile
  Widget _buildProfilePage() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Not logged in'));
        }

        final user = authState.user;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Exporter Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green[600],
                        child: Text(
                          user.firstName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: AfrigoTypography.headingMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Certified Exporter',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Export Statistics
                Text(
                  'Export Statistics',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _buildExportStatCard('Total Shipments', '24'),
                _buildExportStatCard('Active Shipments', '8'),
                _buildExportStatCard('Destinations Served', '6'),
                _buildExportStatCard('Total Goods Exported', '\$450,000'),

                const SizedBox(height: 24),

                // Export Settings
                Text(
                  'Export Settings',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Company Information'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Port of Export'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Export License'),
                  subtitle: const Text('License #EXPT-2024-45678'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Customs Registration'),
                  subtitle: const Text('CRN: 987654-321'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: const Text('Insurance Information'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper Widgets
  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityFeed() {
    final activities = [
      {
        'title': 'Shipment Departure',
        'description': 'Container #5 left port',
        'time': '2 hours ago',
        'icon': Icons.flight_takeoff,
      },
      {
        'title': 'Customs Clearance',
        'description': 'Documents verified',
        'time': '5 hours ago',
        'icon': Icons.verified_user,
      },
      {
        'title': 'Port Arrival',
        'description': 'Goods arrived at Hamburg port',
        'time': '1 day ago',
        'icon': Icons.location_on,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: Icon(activity['icon'] as IconData, color: Colors.green[600]),
          title: Text(activity['title'] as String),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(activity['description'] as String),
              const SizedBox(height: 4),
              Text(
                activity['time'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplianceStatus() {
    final items = [
      {'label': 'Export License', 'status': 'Valid', 'color': Colors.green},
      {
        'label': 'KYC Verification',
        'status': 'Verified',
        'color': Colors.green
      },
      {'label': 'Documentation', 'status': 'Complete', 'color': Colors.green},
      {'label': 'Insurance', 'status': 'Active', 'color': Colors.green},
    ];

    return Column(
      children: items
          .map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Chip(
                      label: Text(item['status'] as String),
                      backgroundColor:
                          (item['color'] as Color).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: item['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildExportStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
