import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/shipments/shipment_list_screen.dart';
import '../screens/shipments/shipment_details_screen.dart';
import '../screens/shipments/delivery_proof_screen.dart';

/// Shipment Routes Configuration
class ShipmentRoutes {
  static List<RouteBase> routes = [
    // Shipments List
    GoRoute(
      path: '/shipments',
      name: 'shipments',
      builder: (context, state) => const ShipmentListScreen(),
      routes: [
        // Shipment Details
        GoRoute(
          path: ':shipmentId',
          name: 'shipment-details',
          builder: (context, state) {
            final shipmentId = state.pathParameters['shipmentId'];
            return ShipmentDetailsScreen(shipmentId: shipmentId!);
          },
          routes: [
            // Delivery Proof Capture
            GoRoute(
              path: 'delivery-proof',
              name: 'delivery-proof',
              builder: (context, state) {
                final shipmentId = state.pathParameters['shipmentId'];
                return DeliveryProofScreen(shipmentId: shipmentId!);
              },
            ),
          ],
        ),
      ],
    ),
  ];
}

/// Navigation Extension for GoRouter
extension ShipmentNavigation on GoRouter {
  /// Navigate to shipments list
  void goToShipments() {
    goNamed('shipments');
  }

  /// Navigate to shipment details
  void goToShipmentDetails(String shipmentId) {
    goNamed('shipment-details', pathParameters: {'shipmentId': shipmentId});
  }

  /// Navigate to delivery proof capture
  void goToDeliveryProof(String shipmentId) {
    goNamed('delivery-proof', pathParameters: {'shipmentId': shipmentId});
  }
}

/// Named Route Constants
class ShipmentRouteName {
  static const shipments = 'shipments';
  static const shipmentDetails = 'shipment-details';
  static const deliveryProof = 'delivery-proof';
}
