import 'package:afrigo_app/presentation/providers/live_market_activity_provider.dart';
import 'package:afrigo_app/presentation/screens/user/notification_center_screen.dart';
import 'package:afrigo_app/presentation/screens/user/profile_settings_screen.dart';
import 'package:afrigo_app/presentation/widgets/dashboard_role.dart';
import 'package:afrigo_app/presentation/widgets/role_dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

class _FakeLiveNotifier extends StateNotifier<LiveMarketActivityState>
    implements LiveMarketActivityNotifier {
  _FakeLiveNotifier()
      : super(
          LiveMarketActivityState(
            stats: const LiveRoleStats(
              openRfqs: 5,
              activeQuotes: 7,
              readyLots: 4,
              bookedShipments: 3,
              inCustoms: 1,
              deliveredToday: 2,
            ),
            events: [
              LiveActivityEvent(
                id: 'evt-1',
                type: LiveEventType.rfqPosted,
                actor: LiveActorRole.buyer,
                title: 'Buyer posted RFQ',
                subtitle: 'Suppliers can respond now.',
                timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
              ),
              LiveActivityEvent(
                id: 'evt-2',
                type: LiveEventType.shipmentBooked,
                actor: LiveActorRole.exporter,
                title: 'Shipment booked',
                subtitle: 'Route allocation completed.',
                timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
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

Widget _buildWalkthroughApp({
  required DashboardRole role,
  required String dashboardPath,
}) {
  Widget routeTargetPage(String title, String keyName) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          key: ValueKey(keyName),
        ),
      ),
    );
  }

  final router = GoRouter(
    initialLocation: dashboardPath,
    routes: [
      GoRoute(
        path: dashboardPath,
        builder: (context, state) => RoleDashboardShell(
          role: role,
          child: const Center(
            child: Text(
              'Dashboard content',
              key: ValueKey('target-dashboard'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/rfqs',
        builder: (context, state) =>
            routeTargetPage('RFQs Screen', 'target-rfqs'),
      ),
      GoRoute(
        path: '/shipments',
        builder: (context, state) =>
            routeTargetPage('Shipments Screen', 'target-shipments'),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) =>
            routeTargetPage('Analytics Screen', 'target-analytics'),
      ),
      GoRoute(
        path: '/lots',
        builder: (context, state) =>
            routeTargetPage('Lots Screen', 'target-lots'),
      ),
      GoRoute(
        path: '/contracts',
        builder: (context, state) =>
            routeTargetPage('Contracts Screen', 'target-contracts'),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) =>
            routeTargetPage('Payments Screen', 'target-payments'),
      ),
      GoRoute(
        path: '/pipeline',
        builder: (context, state) =>
            routeTargetPage('Pipeline Screen', 'target-pipeline'),
      ),
      GoRoute(
        path: '/dossiers',
        builder: (context, state) =>
            routeTargetPage('Dossiers Screen', 'target-dossiers'),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) =>
            routeTargetPage('Tracking Screen', 'target-tracking'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const KeyedSubtree(
          key: ValueKey('target-profile'),
          child: ProfileSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const Scaffold(body: Text('Settings Screen')),
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

Future<void> _tapBottomTabByKey(WidgetTester tester, String keyName) async {
  await tester.tap(find.byKey(ValueKey(keyName)));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role walkthrough on device', () {
    testWidgets('Buyer walkthrough', (tester) async {
      await tester.pumpWidget(
        _buildWalkthroughApp(
          role: DashboardRole.buyer,
          dashboardPath: '/dashboard/buyer',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-buyer-rfqs');
      expect(find.byKey(const ValueKey('target-rfqs')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-buyer-shipments');
      expect(find.byKey(const ValueKey('target-shipments')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-buyer-analytics');
      expect(find.byKey(const ValueKey('target-analytics')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-buyer-profile');
      expect(find.byKey(const ValueKey('target-profile')), findsOneWidget);
    });

    testWidgets('Supplier walkthrough', (tester) async {
      await tester.pumpWidget(
        _buildWalkthroughApp(
          role: DashboardRole.supplier,
          dashboardPath: '/dashboard/seller',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-supplier-lots');
      expect(find.byKey(const ValueKey('target-lots')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-supplier-contracts');
      expect(find.byKey(const ValueKey('target-contracts')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-supplier-payments');
      expect(find.byKey(const ValueKey('target-payments')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-supplier-profile');
      expect(find.byKey(const ValueKey('target-profile')), findsOneWidget);
    });

    testWidgets('Exporter walkthrough', (tester) async {
      await tester.pumpWidget(
        _buildWalkthroughApp(
          role: DashboardRole.exporter,
          dashboardPath: '/dashboard/exporter',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-exporter-pipeline');
      expect(find.byKey(const ValueKey('target-pipeline')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-exporter-dossiers');
      expect(find.byKey(const ValueKey('target-dossiers')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-exporter-tracking');
      expect(find.byKey(const ValueKey('target-tracking')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('target-dashboard')), findsOneWidget);

      await _tapBottomTabByKey(tester, 'tab-exporter-profile');
      expect(find.byKey(const ValueKey('target-profile')), findsOneWidget);
    });
  });
}
