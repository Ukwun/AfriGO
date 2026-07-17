import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/role_navigation_config.dart';
import 'auth_provider.dart';

/// Provider for current user's role
/// This watches auth state and determines user role based on their profile
final userRoleProvider = FutureProvider<UserRole>((ref) async {
  // Get current user from auth provider
  final authState = ref.watch(authProvider);

  if (authState is AuthAuthenticated) return _getUserRole(authState.user);
  return UserRole.buyer;
});

/// Determine user role from user data
UserRole _getUserRole(dynamic user) {
  final roles = (user.roles as List<String>).map((role) => role.toLowerCase());
  if (roles.contains('supplier')) {
    return UserRole.supplier;
  } else if (roles.contains('exporter')) {
    return UserRole.exporter;
  }

  // Default to buyer
  return UserRole.buyer;
}

/// Synchronous version of user role (if available in cache)
final userRoleSyncProvider = Provider<UserRole?>((ref) {
  final authState = ref.watch(authProvider);

  if (authState is AuthAuthenticated) return _getUserRole(authState.user);
  return null;
});

/// Get role-specific button height
final roleButtonHeightProvider = Provider<double>((ref) {
  final userRole = ref.watch(userRoleSyncProvider);
  if (userRole == null) return 48.0;
  return RoleNavigationConfig.getButtonHeight(userRole);
});

/// Get role-specific table rows per page
final roleTableRowsProvider = Provider<int>((ref) {
  final userRole = ref.watch(userRoleSyncProvider);
  if (userRole == null) return 10;
  return RoleNavigationConfig.getTableRowsPerPage(userRole);
});

/// Get role-specific emphasis color
final roleEmphasisColorProvider = Provider((ref) {
  final userRole = ref.watch(userRoleSyncProvider);
  if (userRole == null) return const Color(0xFF0F5B46);
  return RoleNavigationConfig.getRoleEmphasisColor(userRole);
});

/// Check if role prefers card layout
final rolePreferencesProvider = Provider<RolePreferences>((ref) {
  final userRole = ref.watch(userRoleSyncProvider);
  if (userRole == null) {
    return RolePreferences.defaultPreferences;
  }

  return RolePreferences(
    prefersCards: RoleNavigationConfig.prefersCardLayout(userRole),
    buttonHeight: RoleNavigationConfig.getButtonHeight(userRole),
    showAdvancedFeatures: RoleNavigationConfig.showAdvancedFeatures(userRole),
    needsRealtimeUpdates: RoleNavigationConfig.needsRealtimeUpdates(userRole),
    tableRowsPerPage: RoleNavigationConfig.getTableRowsPerPage(userRole),
  );
});

/// Role-specific UI preferences
class RolePreferences {
  final bool prefersCards;
  final double buttonHeight;
  final bool showAdvancedFeatures;
  final bool needsRealtimeUpdates;
  final int tableRowsPerPage;

  RolePreferences({
    required this.prefersCards,
    required this.buttonHeight,
    required this.showAdvancedFeatures,
    required this.needsRealtimeUpdates,
    required this.tableRowsPerPage,
  });

  static RolePreferences defaultPreferences = RolePreferences(
    prefersCards: false,
    buttonHeight: 48.0,
    showAdvancedFeatures: false,
    needsRealtimeUpdates: false,
    tableRowsPerPage: 10,
  );
}

/// Get navigation items for current user's role
final roleNavigationProvider = Provider<List<NavigationItem>>((ref) {
  final userRole = ref.watch(userRoleSyncProvider);
  if (userRole == null) {
    return RoleNavigationConfig.getNavItems(UserRole.buyer);
  }
  return RoleNavigationConfig.getNavItems(userRole);
});
