import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierSalesScreen extends ConsumerStatefulWidget {
  const SupplierSalesScreen({super.key});

  @override
  ConsumerState<SupplierSalesScreen> createState() =>
      _SupplierSalesScreenState();
}

class _SupplierSalesScreenState extends ConsumerState<SupplierSalesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FadeTransition(
        opacity:
            CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: _slideController, curve: Curves.easeOutCubic)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(theme),
                  const SizedBox(height: 24),
                  _buildSalesListSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _fadeController, curve: Curves.elasticOut),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Sales',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '12',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _fadeController, curve: Curves.elasticOut),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Revenue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$45,600',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesListSection(ThemeData theme) {
    final sales = [
      {
        'id': 'SALE-001',
        'buyer': 'Fresh Import Co.',
        'quantity': '500 kg',
        'amount': '\$2,500',
        'status': 'Shipped',
      },
      {
        'id': 'SALE-002',
        'buyer': 'Global Foods Ltd',
        'quantity': '1.2 MT',
        'amount': '\$6,800',
        'status': 'Delivered',
      },
      {
        'id': 'SALE-003',
        'buyer': 'Urban Market',
        'quantity': '750 kg',
        'amount': '\$4,200',
        'status': 'Processing',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sales',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            sales.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
                        .animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Interval(
                      0.1 * index,
                      0.1 * index + 0.5,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: _buildSaleItem(theme, sales[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleItem(ThemeData theme, Map<String, String> sale) {
    final statusColors = {
      'Shipped': Colors.blue,
      'Delivered': Colors.green,
      'Processing': Colors.orange,
    };

    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${sale['id']}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                    Icons.shopping_bag,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale['buyer']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sale['quantity']} • ${sale['amount']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (statusColors[sale['status']] ?? Colors.grey)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sale['status']!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColors[sale['status']] ?? Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
