import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/role_navigation_config.dart';
import '../../../config/theme.dart';
import '../../providers/role_provider.dart';

/// Adaptive shell that renders role-specific navigation
/// This widget wraps the main content and shows appropriate bottom nav based on user role
class AdaptiveNavigationShell extends ConsumerStatefulWidget {
  final Widget child;
  final StatefulNavigationShell? navigationShell;

  const AdaptiveNavigationShell({
    super.key,
    required this.child,
    this.navigationShell,
  });

  @override
  ConsumerState<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState
    extends ConsumerState<AdaptiveNavigationShell> {
  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(userRoleProvider);
    final navItems = ref.watch(roleNavigationProvider);

    return roleAsync.when(
      data: (role) {
        return Scaffold(
          appBar: AppBar(
            title: Text(RoleNavigationConfig.getAppBarTitle(role)),
            backgroundColor: AppTheme.primaryGreen,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Handle notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.push('/settings');
                },
              ),
            ],
          ),
          body: widget.child,
          bottomNavigationBar: _buildBottomNavigation(
            role: role,
            items: navItems,
            context: context,
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  /// Build role-specific bottom navigation
  Widget _buildBottomNavigation({
    required UserRole role,
    required List<NavigationItem> items,
    required BuildContext context,
  }) {
    switch (role) {
      case UserRole.supplier:
        return _buildSupplierNav(items, context);
      case UserRole.buyer:
        return _buildBuyerNav(items, context);
      case UserRole.exporter:
        return _buildLogisticsNav(items, context);
    }
  }

  /// SUPPLIER Navigation - Simplified, 4 tabs
  Widget _buildSupplierNav(List<NavigationItem> items, BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryGreen,
      unselectedItemColor: Colors.grey.shade400,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon, size: 28),
              label: item.label,
            ),
          )
          .toList(),
      onTap: (index) {
        context.go(items[index].routePath);
      },
    );
  }

  /// BUYER Navigation - 5 tabs with overflow menu
  Widget _buildBuyerNav(List<NavigationItem> items, BuildContext context) {
    // Show first 4 items, rest in menu
    final mainItems = items.take(4).toList();
    final hasMore = items.length > 4;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryGreen,
      unselectedItemColor: Colors.grey.shade400,
      items: [
        ...mainItems.map(
          (item) => BottomNavigationBarItem(
            icon: Icon(item.icon, size: 28),
            label: item.label,
          ),
        ),
        if (hasMore)
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, size: 28),
            label: 'More',
          ),
      ],
      onTap: (index) {
        if (hasMore && index == 4) {
          // Show menu
          _showMoreMenu(context, items.skip(4).toList());
        } else {
          context.go(mainItems[index].routePath);
        }
      },
    );
  }

  /// LOGISTICS Navigation - 5 tabs
  Widget _buildLogisticsNav(List<NavigationItem> items, BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF9800),
      unselectedItemColor: Colors.grey.shade400,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon, size: 28),
              label: item.label,
            ),
          )
          .toList(),
      onTap: (index) {
        context.go(items[index].routePath);
      },
    );
  }

  /// Show additional menu items
  void _showMoreMenu(
    BuildContext context,
    List<NavigationItem> items,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'More Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.routePath);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
