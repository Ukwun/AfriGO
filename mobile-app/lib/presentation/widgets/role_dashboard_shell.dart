import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/colors.dart';
import '../providers/notification_read_provider.dart';
import 'app_global_search_delegate.dart';
import 'dashboard_role.dart';

class _RoleTab {
  const _RoleTab({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.prefixes,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final List<String> prefixes;
}

class RoleDashboardShell extends ConsumerWidget {
  const RoleDashboardShell({
    super.key,
    required this.role,
    required this.child,
  });

  final DashboardRole role;
  final Widget child;

  static const Map<DashboardRole, List<_RoleTab>> _roleTabs = {
    DashboardRole.buyer: [
      _RoleTab(
        label: 'Home',
        route: '/dashboard/buyer',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        prefixes: ['/dashboard/buyer'],
      ),
      _RoleTab(
        label: 'RFQs',
        route: '/rfqs',
        icon: Icons.request_quote_outlined,
        activeIcon: Icons.request_quote,
        prefixes: ['/rfqs'],
      ),
      _RoleTab(
        label: 'Shipments',
        route: '/shipments',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping,
        prefixes: ['/shipments'],
      ),
      _RoleTab(
        label: 'Analytics',
        route: '/analytics',
        icon: Icons.query_stats_outlined,
        activeIcon: Icons.query_stats,
        prefixes: ['/analytics'],
      ),
      _RoleTab(
        label: 'Profile',
        route: '/profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        prefixes: ['/profile', '/settings'],
      ),
    ],
    DashboardRole.supplier: [
      _RoleTab(
        label: 'Home',
        route: '/dashboard/seller',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        prefixes: ['/dashboard/seller'],
      ),
      _RoleTab(
        label: 'Lots',
        route: '/lots',
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        prefixes: ['/lots'],
      ),
      _RoleTab(
        label: 'Contracts',
        route: '/contracts',
        icon: Icons.description_outlined,
        activeIcon: Icons.description,
        prefixes: ['/contracts'],
      ),
      _RoleTab(
        label: 'Payments',
        route: '/payments',
        icon: Icons.account_balance_wallet_outlined,
        activeIcon: Icons.account_balance_wallet,
        prefixes: ['/payments'],
      ),
      _RoleTab(
        label: 'Profile',
        route: '/profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        prefixes: ['/profile', '/settings'],
      ),
    ],
    DashboardRole.exporter: [
      _RoleTab(
        label: 'Home',
        route: '/dashboard/exporter',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        prefixes: ['/dashboard/exporter'],
      ),
      _RoleTab(
        label: 'Pipeline',
        route: '/pipeline',
        icon: Icons.timeline_outlined,
        activeIcon: Icons.timeline,
        prefixes: ['/pipeline'],
      ),
      _RoleTab(
        label: 'Dossiers',
        route: '/dossiers',
        icon: Icons.folder_outlined,
        activeIcon: Icons.folder,
        prefixes: ['/dossiers'],
      ),
      _RoleTab(
        label: 'Tracking',
        route: '/tracking',
        icon: Icons.my_location_outlined,
        activeIcon: Icons.my_location,
        prefixes: ['/tracking'],
      ),
      _RoleTab(
        label: 'Profile',
        route: '/profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        prefixes: ['/profile', '/settings'],
      ),
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = _roleTabs[role]!;
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(location, tabs);
    final unreadCount = ref.watch(roleUnreadNotificationCountProvider(role));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(_titleForRole(role)),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              showSearch<void>(
                context: context,
                delegate: AppGlobalSearchDelegate(role: role),
              );
            },
            icon: const Icon(Icons.search),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_none),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 9,
                    top: 9,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<String>(location),
          child: child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: NavigationBar(
              key: ValueKey('role-nav-${role.name}'),
              height: 74,
              selectedIndex: selectedIndex,
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.primaryGreenLighter,
              animationDuration: const Duration(milliseconds: 260),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                for (var i = 0; i < tabs.length; i++)
                  NavigationDestination(
                    icon: KeyedSubtree(
                      key: ValueKey(
                        'tab-${role.name}-${tabs[i].label.toLowerCase()}',
                      ),
                      child: _AnimatedTabIcon(
                        icon: tabs[i].icon,
                        activeIcon: tabs[i].activeIcon,
                        selected: i == selectedIndex,
                      ),
                    ),
                    label: tabs[i].label,
                  ),
              ],
              onDestinationSelected: (index) {
                final target = tabs[index].route;
                if (target == location) return;

                if (target.startsWith('/dashboard/')) {
                  context.go(target);
                  return;
                }

                context.push(target);
              },
            ),
          ),
        ),
      ),
    );
  }

  int _selectedIndex(String location, List<_RoleTab> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      for (final prefix in tab.prefixes) {
        if (location.startsWith(prefix)) {
          return i;
        }
      }
    }
    return 0;
  }

  String _titleForRole(DashboardRole role) {
    switch (role) {
      case DashboardRole.buyer:
        return 'Buyer Dashboard';
      case DashboardRole.supplier:
        return 'Supplier Dashboard';
      case DashboardRole.exporter:
        return 'Exporter Dashboard';
    }
  }
}

class _AnimatedTabIcon extends StatelessWidget {
  const _AnimatedTabIcon({
    required this.icon,
    required this.activeIcon,
    required this.selected,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.08 : 1,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          selected ? activeIcon : icon,
          key: ValueKey<bool>(selected),
          color: selected ? AppColors.primaryGreen : AppColors.textSecondary,
        ),
      ),
    );
  }
}
