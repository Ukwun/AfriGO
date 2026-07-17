import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/colors.dart';
import 'dashboard_role.dart';

class AppSearchItem {
  const AppSearchItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.roles,
    this.keywords = const <String>[],
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final List<DashboardRole> roles;
  final List<String> keywords;
}

class AppGlobalSearchDelegate extends SearchDelegate<void> {
  AppGlobalSearchDelegate({required this.role});

  final DashboardRole role;

  static const List<AppSearchItem> _catalog = <AppSearchItem>[
    AppSearchItem(
      title: 'Dashboard',
      subtitle: 'Role home overview',
      route: '/dashboard/buyer',
      icon: Icons.home_outlined,
      roles: [DashboardRole.buyer],
      keywords: ['home', 'overview', 'trade volume'],
    ),
    AppSearchItem(
      title: 'Open RFQs',
      subtitle: 'Buyer requests and quotes',
      route: '/rfqs',
      icon: Icons.request_quote_outlined,
      roles: [DashboardRole.buyer],
      keywords: ['quotes', 'rfq', 'buyer'],
    ),
    AppSearchItem(
      title: 'Shipments',
      subtitle: 'Track inbound deliveries',
      route: '/shipments',
      icon: Icons.local_shipping_outlined,
      roles: [DashboardRole.buyer],
      keywords: ['eta', 'delivery', 'tracking'],
    ),
    AppSearchItem(
      title: 'Analytics',
      subtitle: 'Trends and demand intelligence',
      route: '/analytics',
      icon: Icons.query_stats_outlined,
      roles: [DashboardRole.buyer],
      keywords: ['insights', 'reports', 'forecast'],
    ),
    AppSearchItem(
      title: 'Supplier Dashboard',
      subtitle: 'Manage supply operations',
      route: '/dashboard/seller',
      icon: Icons.home_outlined,
      roles: [DashboardRole.supplier],
      keywords: ['seller', 'supplier', 'home'],
    ),
    AppSearchItem(
      title: 'Active Lots',
      subtitle: 'Inventory, offers, and statuses',
      route: '/lots',
      icon: Icons.inventory_2_outlined,
      roles: [DashboardRole.supplier],
      keywords: ['inventory', 'stock', 'lot'],
    ),
    AppSearchItem(
      title: 'Contracts',
      subtitle: 'Agreements and milestones',
      route: '/contracts',
      icon: Icons.description_outlined,
      roles: [DashboardRole.supplier, DashboardRole.exporter],
      keywords: ['agreement', 'terms', 'deal'],
    ),
    AppSearchItem(
      title: 'Payments',
      subtitle: 'Escrow and settlement history',
      route: '/payments',
      icon: Icons.account_balance_wallet_outlined,
      roles: [DashboardRole.supplier],
      keywords: ['wallet', 'payout', 'escrow'],
    ),
    AppSearchItem(
      title: 'Exporter Dashboard',
      subtitle: 'Run export workflows',
      route: '/dashboard/exporter',
      icon: Icons.home_outlined,
      roles: [DashboardRole.exporter],
      keywords: ['export', 'home', 'operations'],
    ),
    AppSearchItem(
      title: 'Export Pipeline',
      subtitle: 'Monitor current export stages',
      route: '/pipeline',
      icon: Icons.timeline_outlined,
      roles: [DashboardRole.exporter],
      keywords: ['stage', 'flow', 'shipment'],
    ),
    AppSearchItem(
      title: 'Dossiers',
      subtitle: 'Compliance document packs',
      route: '/dossiers',
      icon: Icons.folder_outlined,
      roles: [DashboardRole.exporter],
      keywords: ['documents', 'compliance', 'customs'],
    ),
    AppSearchItem(
      title: 'Tracking',
      subtitle: 'Real-time shipment visibility',
      route: '/tracking',
      icon: Icons.my_location_outlined,
      roles: [DashboardRole.exporter],
      keywords: ['gps', 'location', 'checkpoint'],
    ),
    AppSearchItem(
      title: 'Notifications',
      subtitle: 'Alerts and role activity updates',
      route: '/notifications',
      icon: Icons.notifications_none,
      roles: [
        DashboardRole.buyer,
        DashboardRole.supplier,
        DashboardRole.exporter
      ],
      keywords: ['alerts', 'updates', 'events'],
    ),
    AppSearchItem(
      title: 'Profile',
      subtitle: 'Identity, trust, and account controls',
      route: '/profile',
      icon: Icons.person_outline,
      roles: [
        DashboardRole.buyer,
        DashboardRole.supplier,
        DashboardRole.exporter
      ],
      keywords: ['account', 'identity', 'settings'],
    ),
    AppSearchItem(
      title: 'Settings',
      subtitle: 'Preferences and app controls',
      route: '/settings',
      icon: Icons.settings_outlined,
      roles: [
        DashboardRole.buyer,
        DashboardRole.supplier,
        DashboardRole.exporter
      ],
      keywords: ['preferences', 'config', 'controls'],
    ),
  ];

  List<AppSearchItem> get _roleItems {
    return _catalog.where((item) => item.roles.contains(role)).toList();
  }

  @override
  String? get searchFieldLabel =>
      'Search lots, contracts, tracking, profile...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: query.isEmpty ? 0.4 : 1,
        child: IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _resolve(query);
    return _ResultsList(
      items: results,
      onSelected: (item) {
        close(context, null);
        context.push(item.route);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _resolve(query);
    return _ResultsList(
      items: results,
      onSelected: (item) {
        close(context, null);
        context.push(item.route);
      },
    );
  }

  List<AppSearchItem> _resolve(String input) {
    final q = input.trim().toLowerCase();
    if (q.isEmpty) {
      return _roleItems;
    }

    return _roleItems.where((item) {
      final searchable = <String>[
        item.title,
        item.subtitle,
        item.route,
        ...item.keywords,
      ].join(' ').toLowerCase();
      return searchable.contains(q);
    }).toList();
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.items,
    required this.onSelected,
  });

  final List<AppSearchItem> items;
  final ValueChanged<AppSearchItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No matches yet. Try keyword like RFQ, contracts, tracking, or profile.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
      itemBuilder: (context, index) {
        final item = items[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.95, end: 1),
          duration: Duration(milliseconds: 180 + (index * 30)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: value, child: child),
            );
          },
          child: ListTile(
            onTap: () => onSelected(item),
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderDefault),
            ),
            leading: Icon(item.icon, color: AppColors.accentBlue),
            title: Text(
              item.title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              item.subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing:
                const Icon(Icons.north_east, color: AppColors.textSecondary),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: items.length,
    );
  }
}
