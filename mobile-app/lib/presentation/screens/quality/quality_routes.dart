import 'package:go_router/go_router.dart';
import 'quality_inspection_screen.dart';
import 'quality_report_screen.dart';
import 'lab_registry_screen.dart';
import 'quality_approval_screen.dart';
import 'quality_stats_screen.dart';

/// Quality Module Routes for GoRouter
class QualityRoutes {
  /// Define all quality-related routes
  static List<RouteBase> routes = [
    GoRoute(
      path: '/quality/inspections',
      name: 'quality-inspections',
      builder: (context, state) => const QualityInspectionScreen(),
    ),
    GoRoute(
      path: '/quality/inspections/:inspectionId/report',
      name: 'quality-report',
      builder: (context, state) {
        final inspectionId = state.pathParameters['inspectionId']!;
        return QualityReportScreen(inspectionId: inspectionId);
      },
    ),
    GoRoute(
      path: '/quality/inspections/:inspectionId/approve',
      name: 'quality-approval',
      builder: (context, state) {
        final inspectionId = state.pathParameters['inspectionId']!;
        return QualityApprovalScreen(inspectionId: inspectionId);
      },
    ),
    GoRoute(
      path: '/quality/labs',
      name: 'quality-labs',
      builder: (context, state) => const LabRegistryScreen(),
    ),
    GoRoute(
      path: '/quality/stats',
      name: 'quality-stats',
      builder: (context, state) => const QualityStatsScreen(),
    ),
  ];
}

/// Helper extension for easy navigation
extension QualityNavigation on GoRouter {
  void goToQualityInspections() {
    pushNamed('quality-inspections');
  }

  void goToQualityReport(String inspectionId) {
    pushNamed('quality-report', pathParameters: {'inspectionId': inspectionId});
  }

  void goToQualityApproval(String inspectionId) {
    pushNamed('quality-approval',
        pathParameters: {'inspectionId': inspectionId});
  }

  void goToLabRegistry() {
    pushNamed('quality-labs');
  }

  void goToQualityStats() {
    pushNamed('quality-stats');
  }
}
