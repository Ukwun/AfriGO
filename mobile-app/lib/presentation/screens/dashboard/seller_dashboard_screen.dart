import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../presentation/providers/auth_provider.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfriGo Seller'),
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
              icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Lots'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildAnalyticsPage();
      case 1:
        return _buildLotsPage();
      case 2:
        return _buildOrdersPage();
      case 3:
        return _buildProfilePage();
      default:
        return const SizedBox();
    }
  }

  /// ANALYTICS PAGE - Sales metrics and business performance
  Widget _buildAnalyticsPage() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Not logged in'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Summary
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
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
                        'Total Revenue (This Month)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '\$24,500',
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
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '↑ 12% from last month',
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
                  'Key Metrics',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricCard('Total Orders', '47', Colors.blue),
                    _buildMetricCard('Active Lots', '12', Colors.green),
                    _buildMetricCard('Avg Rating', '4.8★', Colors.orange),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Sales
                Text(
                  'Recent Sales',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _buildSalesActivity(),

                const SizedBox(height: 24),

                // Top Products
                Text(
                  'Top Selling Products',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _buildTopProducts(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// LOTS PAGE - Manage inventory
  Widget _buildLotsPage() {
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
                  'Your Lots',
                  style: AfrigoTypography.headingMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Create Lot'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lots listing
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                final lots = [
                  {
                    'name': 'Organic Coffee Beans - Grade A',
                    'quantity': '500kg',
                    'price': '\$5,000',
                    'status': 'Active',
                    'orders': 8,
                  },
                  {
                    'name': 'Cocoa Export - Premium Selection',
                    'quantity': '300kg',
                    'price': '\$4,500',
                    'status': 'Active',
                    'orders': 5,
                  },
                  {
                    'name': 'Shea Butter - Pure & Natural',
                    'quantity': '200kg',
                    'price': '\$2,000',
                    'status': 'Active',
                    'orders': 3,
                  },
                  {
                    'name': 'Premium Tea Leaves',
                    'quantity': '100kg',
                    'price': '\$1,500',
                    'status': 'Pending',
                    'orders': 0,
                  },
                  {
                    'name': 'Spice Mix - Special Blend',
                    'quantity': '50kg',
                    'price': '\$800',
                    'status': 'Sold Out',
                    'orders': 12,
                  },
                ];
                final lot = lots[index];

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
                                    (lot['name'] ?? '').toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${lot['quantity']} • ${lot['price']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text((lot['status'] ?? '').toString()),
                              backgroundColor:
                                  (lot['status'] ?? '').toString() == 'Active'
                                      ? Colors.green[100]
                                      : (lot['status'] ?? '').toString() ==
                                              'Sold Out'
                                          ? Colors.red[100]
                                          : Colors.yellow[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${lot['orders']} orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {},
                                  iconSize: 18,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {},
                                  iconSize: 18,
                                  color: Colors.red,
                                ),
                              ],
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

  /// ORDERS PAGE - Manage customer orders
  Widget _buildOrdersPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders Received',
              style: AfrigoTypography.headingMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                final orders = [
                  {
                    'orderId': '#ORD-001842',
                    'buyer': 'Global Traders Ltd',
                    'product': 'Organic Coffee Beans',
                    'qty': '100kg',
                    'total': '\$5,000',
                    'status': 'Pending Approval',
                  },
                  {
                    'orderId': '#ORD-001841',
                    'buyer': 'Africa Import Co.',
                    'product': 'Cocoa Export',
                    'qty': '200kg',
                    'total': '\$8,500',
                    'status': 'Approved',
                  },
                  {
                    'orderId': '#ORD-001840',
                    'buyer': 'Europe Trade',
                    'product': 'Shea Butter',
                    'qty': '50kg',
                    'total': '\$1,200',
                    'status': 'Shipped',
                  },
                  {
                    'orderId': '#ORD-001839',
                    'buyer': 'Asia Exports',
                    'product': 'Premium Tea',
                    'qty': '75kg',
                    'total': '\$3,500',
                    'status': 'Delivered',
                  },
                  {
                    'orderId': '#ORD-001838',
                    'buyer': 'Local Distributor',
                    'product': 'Spice Mix',
                    'qty': '30kg',
                    'total': '\$900',
                    'status': 'Approved',
                  },
                  {
                    'orderId': '#ORD-001837',
                    'buyer': 'Middle East Trading',
                    'product': 'Coffee & Cocoa Bundle',
                    'qty': '300kg',
                    'total': '\$12,500',
                    'status': 'Pending Approval',
                  },
                ];
                final order = orders[index];

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
                            Text(
                              order['orderId']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(order['status']!),
                              backgroundColor: order['status'] == 'Delivered'
                                  ? Colors.green[100]
                                  : order['status'] == 'Shipped'
                                      ? Colors.blue[100]
                                      : order['status'] == 'Approved'
                                          ? Colors.green[100]
                                          : Colors.orange[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order['buyer']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${order['product']} • ${order['qty']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['total']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.check),
                                  label: const Text('Accept'),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.close),
                                  label: const Text('Decline'),
                                ),
                              ],
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

  /// PROFILE PAGE - Business profile management
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
                // Business Profile Header
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
                        backgroundColor: Colors.blue[600],
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
                        'Premium Seller',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Business Stats
                Text(
                  'Business Statistics',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _buildBusinessStatCard('Active Lots', '12'),
                _buildBusinessStatCard('Total Orders', '47'),
                _buildBusinessStatCard('Completion Rate', '98%'),

                const SizedBox(height: 24),

                // Business Settings
                Text(
                  'Business Settings',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Business Information'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Shipping Locations'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Methods'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.verified),
                  title: const Text('Verification Status'),
                  subtitle: const Text('KYC: Pending'),
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

  Widget _buildSalesActivity() {
    final sales = [
      {
        'customer': 'Global Traders Ltd',
        'amount': '+\$5,000',
        'time': '2 hours ago'
      },
      {
        'customer': 'Africa Import Co.',
        'amount': '+\$8,500',
        'time': '1 day ago'
      },
      {'customer': 'Europe Trade', 'amount': '+\$1,200', 'time': '2 days ago'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return ListTile(
          leading: Icon(Icons.trending_up, color: Colors.green[600]),
          title: Text(sale['customer']!),
          subtitle: Text(sale['time']!),
          trailing: Text(
            sale['amount']!,
            style: TextStyle(
              color: Colors.green[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopProducts() {
    final products = [
      {'name': 'Organic Coffee Beans', 'sales': 156, 'revenue': '\$31,200'},
      {'name': 'Cocoa Export', 'sales': 89, 'revenue': '\$17,800'},
      {'name': 'Shea Butter', 'sales': 42, 'revenue': '\$8,400'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text((product['name'] ?? '').toString()),
          subtitle: Text('${product['sales']} units sold'),
          trailing: Text(
            (product['revenue'] ?? '').toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildBusinessStatCard(String label, String value) {
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
