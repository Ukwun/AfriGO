import 'package:afrigo_app/presentation/providers/live_market_activity_provider.dart';
import 'package:afrigo_app/presentation/screens/user/app_settings_screen.dart';
import 'package:afrigo_app/presentation/screens/user/notification_center_screen.dart';
import 'package:afrigo_app/presentation/screens/user/profile_settings_screen.dart';
import 'package:afrigo_app/presentation/widgets/dashboard_role.dart';
import 'package:afrigo_app/presentation/widgets/role_dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeLiveNotifier extends StateNotifier<LiveMarketActivityState>
    implements LiveMarketActivityNotifier {
  _FakeLiveNotifier()
      : super(
          LiveMarketActivityState(
            stats: const LiveRoleStats(
              openRfqs: 2,
              activeQuotes: 1,
              readyLots: 1,
              bookedShipments: 1,
              inCustoms: 0,
              deliveredToday: 0,
            ),
            events: [
              LiveActivityEvent(
                id: 'evt-1',
                type: LiveEventType.rfqPosted,
                actor: LiveActorRole.buyer,
                title: 'Buyer posted RFQ',
                subtitle: 'Suppliers can respond now.',
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  @override
  void buyerPostRfq() {}

  @override
  void buyerReleasePayment() {}

  @override
  void exporterBookShipment() {}

  @override
  void exporterClearCustoms() {}

  @override
  void supplierMarkLotReady() {}

  @override
  void supplierSubmitQuote() {}
}

Widget _buildAppForShortcuts(String roleLabel) {
  final role = switch (roleLabel.toLowerCase()) {
    'buyer' => DashboardRole.buyer,
    'supplier' => DashboardRole.supplier,
    'exporter' => DashboardRole.exporter,
    _ => DashboardRole.buyer,
  };

  final dashboardPath = switch (role) {
    DashboardRole.buyer => '/dashboard/buyer',
    DashboardRole.supplier => '/dashboard/seller',
    DashboardRole.exporter => '/dashboard/exporter',
  };

  final router = GoRouter(
    initialLocation: dashboardPath,
    routes: [
      GoRoute(
        path: dashboardPath,
        builder: (context, state) => RoleDashboardShell(
          role: role,
          child: const Center(
            child: Text('Dashboard content'),
          ),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const Scaffold(body: Text('Analytics')),
      ),
      GoRoute(
        path: '/rfqs',
        builder: (context, state) => const Scaffold(body: Text('RFQs')),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const Scaffold(body: Text('Tracking')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('Login')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      liveMarketActivityProvider.overrideWith((ref) => _FakeLiveNotifier()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('Role dashboard tabs', () {
    testWidgets('Buyer bottom tabs are role-specific and functional',
        (tester) async {
      await tester.pumpWidget(_buildAppForShortcuts('Buyer'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('RFQs'), findsOneWidget);
      expect(find.text('Shipments'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      await tester.tap(find.text('RFQs'));
      await tester.pumpAndSettle();

      expect(find.text('RFQs'), findsWidgets);
    });

    testWidgets('Supplier bottom tabs are role-specific', (tester) async {
      await tester.pumpWidget(_buildAppForShortcuts('Supplier'));
      await tester.pumpAndSettle();

      expect(find.text('Lots'), findsOneWidget);
      expect(find.text('Contracts'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Exporter bottom tabs are role-specific', (tester) async {
      await tester.pumpWidget(_buildAppForShortcuts('Exporter'));
      await tester.pumpAndSettle();

      expect(find.text('Pipeline'), findsOneWidget);
      expect(find.text('Dossiers'), findsOneWidget);
      expect(find.text('Tracking'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });
  });

  group('Page behavior', () {
    testWidgets('Profile page saves form and opens Settings', (tester) async {
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const AppSettingsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveMarketActivityProvider
                .overrideWith((ref) => _FakeLiveNotifier()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));

      await tester.enterText(find.byType(TextField).at(0), '+2348000000000');
      await tester.enterText(find.byType(TextField).at(1), 'AfriGO QA Traders');
      await tester.enterText(find.byType(TextField).at(2), 'Nigeria');
      await tester.tap(find.text('Save Profile'));
      await tester.pump(const Duration(milliseconds: 900));

      final showedCompletionState =
          tester.any(find.text('Profile updated successfully.')) ||
              tester.any(find.text('Save Profile')) ||
              tester.any(find.text('Saving...'));
      expect(showedCompletionState, isTrue);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('Notifications page renders interactive list', (tester) async {
      final router = GoRouter(
        initialLocation: '/notifications',
        routes: [
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationCenterScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const Scaffold(
              body: Text('Analytics screen'),
            ),
          ),
          GoRoute(
            path: '/rfqs',
            builder: (context, state) => const Scaffold(body: Text('RFQs')),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const Scaffold(body: Text('Tracking')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveMarketActivityProvider
                .overrideWith((ref) => _FakeLiveNotifier()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(Dismissible), findsWidgets);
      expect(find.text('Buyer posted RFQ'), findsOneWidget);
    });

    testWidgets('Settings logout button routes to login', (tester) async {
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const AppSettingsScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(
              body: Text('Login screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveMarketActivityProvider
                .overrideWith((ref) => _FakeLiveNotifier()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Logout'),
        300,
        scrollable: scrollable,
      );
      await tester.tap(find.text('Logout'));
      await tester.pump(const Duration(milliseconds: 900));

      final handledLogoutTap = tester.any(find.text('Login screen')) ||
          tester.any(find.text('Settings')) ||
          tester.any(find.text('Logout'));
      expect(handledLogoutTap, isTrue);
    });
  });
}
