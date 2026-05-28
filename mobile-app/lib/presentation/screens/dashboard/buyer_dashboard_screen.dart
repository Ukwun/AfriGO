import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../presentation/providers/auth_provider.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfriGo Buyer'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildBrowsePage();
      case 2:
        return _buildCartPage();
      case 3:
        return _buildProfilePage();
      default:
        return const SizedBox();
    }
  }

  /// HOME PAGE - Main dashboard with quick stats and featured lots
  Widget _buildHomePage() {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Welcome Card
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user.firstName}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to find great deals?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('In Cart', '0', Icons.shopping_cart),
                    _buildStatCard('Saved', '5', Icons.favorite),
                    _buildStatCard('RFQs', '2', Icons.mail),
                  ],
                ),

                const SizedBox(height: 24),

                // Featured Lots Section
                Text(
                  'Featured Lots',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _buildFeaturedLotsSection(),

                const SizedBox(height: 24),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _buildActivityList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// BROWSE PAGE - Search and filter lots
  Widget _buildBrowsePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for lots...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Section
            Text(
              'Filter by Category',
              style: AfrigoTypography.headingSmall,
            ),
            const SizedBox(height: 12),
            _buildCategoryFilter(),

            const SizedBox(height: 24),

            // Browse Lots List
            Text(
              'Available Lots',
              style: AfrigoTypography.headingMedium,
            ),
            const SizedBox(height: 12),
            _buildLotsGrid(),
          ],
        ),
      ),
    );
  }

  /// CART PAGE
  Widget _buildCartPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Your Cart is Empty',
            style: AfrigoTypography.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start browsing lots to add to your cart',
            style: TextStyle(color: AfrigoColors.gray600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedIndex = 1),
            icon: const Icon(Icons.search),
            label: const Text('Browse Lots'),
          ),
        ],
      ),
    );
  }

  /// PROFILE PAGE
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
                // Profile Header
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
                        user.email,
                        style: TextStyle(color: AfrigoColors.gray600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Info Cards
                _buildProfileInfoCard('Email', user.email),
                _buildProfileInfoCard('Account Status', user.kycStatus),
                _buildProfileInfoCard('User Role',
                    user.roles.isNotEmpty ? user.roles[0] : 'Buyer'),

                const SizedBox(height: 24),

                // Account Settings
                Text(
                  'Account Settings',
                  style: AfrigoTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notification Settings'),
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
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.green[600]),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLotsSection() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          final lots = [
            {
              'name': 'Organic Coffee Beans',
              'price': '\$2,500',
              'quantity': '100kg'
            },
            {'name': 'Fresh Cocoa', 'price': '\$1,800', 'quantity': '50kg'},
            {'name': 'Premium Tea', 'price': '\$950', 'quantity': '20kg'},
          ];
          final lot = lots[index];

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.inventory, color: Colors.green[600]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lot['price']!,
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lot['quantity']!,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'action': 'Viewed',
        'item': 'Coffee Beans Lot #2045',
        'time': '2 hours ago'
      },
      {
        'action': 'Added to Cart',
        'item': 'Premium Tea from Kenya',
        'time': '1 day ago'
      },
      {
        'action': 'Submitted RFQ',
        'item': 'Bulk Cocoa Purchase',
        'time': '3 days ago'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: Icon(
            activity['action'] == 'Viewed'
                ? Icons.visibility
                : activity['action'] == 'Added to Cart'
                    ? Icons.add_shopping_cart
                    : Icons.mail,
            color: Colors.green[600],
          ),
          title: Text(activity['action'] ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity['item'] ?? ''),
              Text(
                activity['time'] ?? '',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Agricultural', 'Textile', 'Minerals', 'Spices'];
    return Wrap(
      spacing: 8,
      children: categories.map((category) {
        return FilterChip(
          label: Text(category),
          onSelected: (selected) {},
        );
      }).toList(),
    );
  }

  Widget _buildLotsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final lots = [
          {
            'name': 'Organic Coffee',
            'seller': 'Ethiopia Farms',
            'price': '\$2,500'
          },
          {
            'name': 'Cocoa Beans',
            'seller': 'Ghana Trade Co.',
            'price': '\$1,800'
          },
          {'name': 'Premium Tea', 'seller': 'Kenya Gardens', 'price': '\$950'},
          {'name': 'Textiles ', 'seller': 'Mali Weavers', 'price': '\$3,200'},
          {
            'name': 'Shea Butter',
            'seller': 'Burkina Exports',
            'price': '\$1,200'
          },
          {'name': 'Spices Mix', 'seller': 'Tanzania Herbs', 'price': '\$850'},
        ];
        final lot = lots[index];

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.green[600],
                  size: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lot['seller']!,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lot['price']!,
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.favorite_outline,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoCard(String label, String value) {
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
