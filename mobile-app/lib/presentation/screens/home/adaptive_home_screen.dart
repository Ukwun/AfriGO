import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/role_navigation_config.dart';
import '../../providers/role_provider.dart';
import 'supplier_home_screen.dart';
import 'buyer_home_screen.dart';
import 'exporter_home_screen.dart';

/// Adaptive home screen that renders different content based on user role
class AdaptiveHomeScreen extends ConsumerWidget {
  const AdaptiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      data: (role) {
        return switch (role) {
          UserRole.supplier => const SupplierHomeScreen(),
          UserRole.buyer => const BuyerHomeScreen(),
          UserRole.exporter => const ExporterHomeScreen(),
        };
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
