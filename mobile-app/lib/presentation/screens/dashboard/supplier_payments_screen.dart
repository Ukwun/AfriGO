import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierPaymentsScreen extends ConsumerStatefulWidget {
  const SupplierPaymentsScreen({super.key});

  @override
  ConsumerState<SupplierPaymentsScreen> createState() =>
      _SupplierPaymentsScreenState();
}

class _SupplierPaymentsScreenState extends ConsumerState<SupplierPaymentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FadeTransition(
        opacity:
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                    parent: _fadeController, curve: Curves.elasticOut),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$12,450.50',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Withdrawal initiated')),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Withdraw',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Received'),
                  Tab(text: 'Pending'),
                ],
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentsList(theme, 'all'),
                    _buildPaymentsList(theme, 'received'),
                    _buildPaymentsList(theme, 'pending'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsList(ThemeData theme, String filter) {
    final payments = [
      {
        'id': 'PAY-001',
        'from': 'Fresh Import Co.',
        'amount': '+\$2,500',
        'date': 'Jun 1, 2026',
        'type': 'received',
        'icon': Icons.arrow_downward,
      },
      {
        'id': 'PAY-002',
        'from': 'Global Foods Ltd',
        'amount': '+\$6,800',
        'date': 'May 31, 2026',
        'type': 'received',
        'icon': Icons.arrow_downward,
      },
      {
        'id': 'PAY-003',
        'from': 'Platform Commission',
        'amount': '-\$450',
        'date': 'Jun 1, 2026',
        'type': 'pending',
        'icon': Icons.access_time,
      },
    ];

    final filtered = filter == 'all'
        ? payments
        : payments.where((p) => p['type'] == filter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      filtered[index]['icon'] as IconData,
                      color: filtered[index]['type'] == 'received'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filtered[index]['from'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filtered[index]['date'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  filtered[index]['amount'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: filtered[index]['type'] == 'received'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
