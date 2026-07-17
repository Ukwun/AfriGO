import 'package:flutter/material.dart';

/// User roles in AfriGO platform
enum UserRole {
  supplier, // Product sellers, commodity producers
  buyer, // Importers, retailers, distributors
  exporter, // Export-focused businesses, warehouse operators
}

/// Navigation item configuration
class NavigationItem {
  final String label;
  final IconData icon;
  final String routePath;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.routePath,
  });
}

/// Role-based navigation configuration
class RoleNavigationConfig {
  /// Get navigation items for a specific role
  static List<NavigationItem> getNavItems(UserRole role) {
    return switch (role) {
      UserRole.supplier => _supplierNavigation,
      UserRole.buyer => _buyerNavigation,
      UserRole.exporter => _exporterNavigation,
    };
  }

  /// SUPPLIER Navigation (Mobile-first, Action-focused)
  /// Priority: Quick actions, simplified flows
  static final _supplierNavigation = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home,
      routePath: '/supplier/home',
    ),
    NavigationItem(
      label: 'Sales',
      icon: Icons.store,
      routePath: '/supplier/sales',
    ),
    NavigationItem(
      label: 'Payments',
      icon: Icons.attach_money,
      routePath: '/supplier/payments',
    ),
    NavigationItem(
      label: 'Profile',
      icon: Icons.person,
      routePath: '/supplier/profile',
    ),
  ];

  /// BUYER Navigation (Desktop/Mobile, Discovery-focused)
  /// Priority: Analytics, dashboards, comparisons
  static final _buyerNavigation = [
    NavigationItem(
      label: 'Home',
      icon: Icons.dashboard,
      routePath: '/buyer/home',
    ),
    NavigationItem(
      label: 'Marketplace',
      icon: Icons.shopping_bag,
      routePath: '/buyer/marketplace',
    ),
    NavigationItem(
      label: 'Analytics',
      icon: Icons.bar_chart,
      routePath: '/buyer/analytics',
    ),
    NavigationItem(
      label: 'Shipments',
      icon: Icons.local_shipping,
      routePath: '/buyer/shipments',
    ),
    NavigationItem(
      label: 'More',
      icon: Icons.more_horiz,
      routePath: '/buyer/more',
    ),
  ];

  /// EXPORTER Navigation (Desktop/Mobile, Export-focused)
  /// Priority: Contracts, documentation, warehouse, tracking
  static final _exporterNavigation = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home,
      routePath: '/exporter/home',
    ),
    NavigationItem(
      label: 'Contracts',
      icon: Icons.description,
      routePath: '/exporter/contracts',
    ),
    NavigationItem(
      label: 'Warehouse',
      icon: Icons.warehouse,
      routePath: '/exporter/warehouse',
    ),
    NavigationItem(
      label: 'Tracking',
      icon: Icons.track_changes,
      routePath: '/exporter/tracking',
    ),
    NavigationItem(
      label: 'Dossiers',
      icon: Icons.folder,
      routePath: '/exporter/dossiers',
    ),
  ];

  /// Get button height for role (larger for suppliers, standard for others)
  static double getButtonHeight(UserRole role) {
    return switch (role) {
      UserRole.supplier => 64.0, // Larger buttons for mobile-first supplier
      UserRole.exporter => 56.0, // Large for gloved/outdoor use
      _ => 48.0, // Standard for others
    };
  }

  /// Get data table row density (suppliers: fewer rows, admins: many rows)
  static int getTableRowsPerPage(UserRole role) {
    return switch (role) {
      UserRole.supplier => 5, // Show 5 items (card-based)
      UserRole.buyer => 10, // Show 10 items
      UserRole.exporter => 8, // Show 8 items
    };
  }

  /// Determine if role prefers cards (suppliers, exporters) vs tables (buyer, admin)
  static bool prefersCardLayout(UserRole role) {
    return role == UserRole.supplier || role == UserRole.exporter;
  }

  /// Get emphasized color for role
  static Color getRoleEmphasisColor(UserRole role) {
    return switch (role) {
      UserRole.supplier => const Color(0xFF0F5B46), // Brand green (Action)
      UserRole.buyer => const Color(0xFF1E88E5), // Blue (Data)
      UserRole.exporter => const Color(0xFFFF9800), // Orange (Location)
    };
  }

  /// Get role-specific app bar title
  static String getAppBarTitle(UserRole role) {
    return switch (role) {
      UserRole.supplier => 'AfriGO Supplier',
      UserRole.buyer => 'AfriGO Buyer',
      UserRole.exporter => 'AfriGO Exporter',
    };
  }

  /// Check if role should show advanced features
  static bool showAdvancedFeatures(UserRole role) {
    return role == UserRole.buyer;
  }

  /// Check if role needs real-time updates
  static bool needsRealtimeUpdates(UserRole role) {
    return role == UserRole.exporter;
  }
}
