import 'package:go_router/go_router.dart';
import 'contract_list_screen.dart';
import 'contract_details_screen.dart';
import 'contract_sign_screen.dart';

/// Contract Module Routes for GoRouter
class ContractRoutes {
  /// Define all contract-related routes
  static List<RouteBase> routes = [
    GoRoute(
      path: '/contracts',
      name: 'contracts',
      builder: (context, state) => const ContractListScreen(),
    ),
    GoRoute(
      path: '/contracts/:contractId',
      name: 'contract-details',
      builder: (context, state) {
        final contractId = state.pathParameters['contractId']!;
        return ContractDetailsScreen(contractId: contractId);
      },
    ),
    GoRoute(
      path: '/contracts/:contractId/sign',
      name: 'contract-sign',
      builder: (context, state) {
        final contractId = state.pathParameters['contractId']!;
        return ContractSignScreen(contractId: contractId);
      },
    ),
  ];
}

/// Helper extension for easy navigation
extension ContractNavigation on GoRouter {
  void goToContracts() {
    pushNamed('contracts');
  }

  void goToContractDetails(String contractId) {
    pushNamed('contract-details', pathParameters: {'contractId': contractId});
  }

  void goToContractSign(String contractId) {
    pushNamed('contract-sign', pathParameters: {'contractId': contractId});
  }
}
