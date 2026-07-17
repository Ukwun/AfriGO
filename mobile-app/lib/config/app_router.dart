import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/onboarding/splash_screen_modern.dart';
import '../presentation/screens/onboarding/welcome_screen.dart';
import '../presentation/screens/auth/login_screen_modern.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/animations/page_transitions.dart';
import '../presentation/screens/home/buyer_home_screen.dart';
import '../presentation/screens/home/supplier_home_screen.dart';
import '../presentation/screens/home/exporter_home_screen.dart';
import '../presentation/screens/trading/trading_screen.dart';
import '../presentation/screens/trading/create_rfq_screen_modern.dart';
import '../presentation/screens/trading/trade_detail_screen.dart';
import '../presentation/screens/trading/open_rfq_marketplace_screen.dart';
import '../presentation/screens/trading/submit_bid_screen.dart';
import '../presentation/screens/trading/seller_bid_detail_screen.dart';
import '../presentation/screens/trading/payment_screen.dart';
import '../presentation/screens/trading/contract_signing_screen.dart';
import '../presentation/screens/trading/order_tracking_screen.dart';
import '../presentation/screens/trading/shipping_instructions_screen.dart';
import '../presentation/screens/trading/buyer_delivery_confirmation_screen.dart';
import '../presentation/screens/trading/dispute_resolution_screen.dart';
import '../presentation/screens/marketplace/marketplace_screen.dart';
import '../presentation/screens/trading/lots/create_lot_screen.dart';
import '../presentation/screens/trading/lots/lot_photo_upload_screen.dart';
import '../presentation/screens/trading/lots/lot_qr_display_screen.dart';
import '../presentation/screens/trading/lots/lot_tracking_screen.dart';
import '../presentation/screens/trading/lots/lot_history_screen.dart';
import '../presentation/screens/user/profile_settings_screen.dart';
import '../presentation/screens/user/notification_center_screen.dart';
import '../presentation/screens/user/app_settings_screen.dart';
import '../presentation/screens/dashboard/buyer_analytics_screen.dart';
import '../presentation/screens/dashboard/buyer_more_screen.dart';
import '../presentation/screens/dashboard/exporter_warehouse_screen.dart';
import '../presentation/screens/dashboard/exporter_tracking_screen.dart';
// New real screens
import '../presentation/screens/trading/rfq_list_screen.dart';
import '../presentation/screens/trading/rfq_detail_screen.dart';
import '../presentation/screens/trading/shipment_list_screen.dart';
import '../presentation/screens/dashboard/export_pipeline_screen.dart';
import '../presentation/screens/messaging/messages_screen.dart';
// New real implementation screens
import '../presentation/screens/trading/rfq_edit_screen.dart';
import '../presentation/screens/trading/shipment_detail_screen.dart';
import '../presentation/screens/trading/lot_edit_screen.dart';
import '../presentation/screens/trading/contract_manage_screen.dart';
import '../presentation/screens/trading/supplier_profile_screen.dart';
import '../presentation/screens/trading/create_export_request_screen.dart';
import '../presentation/screens/dashboard/tracking_detail_screen.dart';
import '../presentation/widgets/production_dashboard.dart';
import '../presentation/widgets/dashboard_role.dart';
import '../presentation/screens/shared/live_resource_screen.dart';
import '../presentation/screens/shared/live_record_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublic = location == '/' ||
          location == '/welcome' ||
          location == '/login' ||
          location == '/register';
      if (authState is AuthLoading || authState is AuthIdle) {
        return location == '/' ? null : '/';
      }
      if (authState is! AuthAuthenticated) {
        return isPublic ? null : '/login';
      }

      final role = authState.user.roles.isEmpty
          ? 'buyer'
          : authState.user.roles.first.toLowerCase();
      final home = switch (role) {
        'supplier' => '/supplier/home',
        'exporter' => '/exporter/home',
        _ => '/buyer/home',
      };
      if (isPublic) return home;
      if (location == '/dashboard/seller') return '/supplier/home';

      final requiredRole = location.startsWith('/supplier/')
          ? 'supplier'
          : location.startsWith('/buyer/')
              ? 'buyer'
              : location.startsWith('/exporter/')
                  ? 'exporter'
                  : null;
      return requiredRole != null && requiredRole != role ? home : null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreenModern(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => slideRightTransition(
            context: context, state: state, child: const LoginScreenModern()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => slideRightTransition(
            context: context, state: state, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/dashboard/buyer',
        pageBuilder: (context, state) => fadeTransition(
            context: context, state: state, child: const BuyerHomeScreen()),
      ),
      GoRoute(
        path: '/dashboard/seller',
        pageBuilder: (context, state) => fadeTransition(
            context: context, state: state, child: const SupplierHomeScreen()),
      ),
      GoRoute(
        path: '/dashboard/exporter',
        pageBuilder: (context, state) => fadeTransition(
            context: context, state: state, child: const ExporterHomeScreen()),
      ),

      // ==================== MISSING HOME ROUTES ====================
      GoRoute(
        path: '/supplier/home',
        name: 'supplier_home',
        pageBuilder: (context, state) => fadeTransition(
            context: context, state: state, child: const SupplierHomeScreen()),
      ),
      GoRoute(
        path: '/buyer/home',
        name: 'buyer_home',
        pageBuilder: (context, state) => fadeTransition(
            context: context, state: state, child: const BuyerHomeScreen()),
      ),
      GoRoute(
        path: '/exporter/home',
        name: 'exporter_home',
        pageBuilder: (context, state) => fadeTransition(
            context: context, state: state, child: const ExporterHomeScreen()),
      ),

      // ==================== SUPPLIER DASHBOARD ROUTES ====================
      GoRoute(
        path: '/supplier/sales',
        name: 'supplier_sales',
        builder: (context, state) => const ProductionDashboard(
          role: DashboardRole.supplier,
          headline: 'Sales activity',
          description: 'Orders and contracts confirmed for your account.',
          actionLabel: 'Create a lot',
          actionRoute: '/lots/create',
          feeds: [
            DashboardFeed(resource: 'orders', title: 'Orders', route: '/trading'),
            DashboardFeed(resource: 'contracts', title: 'Contracts', route: '/contracts'),
          ],
        ),
      ),
      GoRoute(
        path: '/supplier/payments',
        name: 'supplier_payments',
        builder: (context, state) => const ProductionDashboard(
          role: DashboardRole.supplier,
          headline: 'Payments',
          description: 'Only verified payment and escrow records are shown.',
          actionLabel: 'View contracts',
          actionRoute: '/contracts',
          feeds: [
            DashboardFeed(resource: 'payments', title: 'Payments', route: '/payments'),
          ],
        ),
      ),
      GoRoute(
        path: '/supplier/profile',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),

      // ==================== BUYER DASHBOARD ROUTES ====================
      GoRoute(
        path: '/buyer/analytics',
        name: 'buyer_analytics',
        builder: (context, state) => const BuyerAnalyticsScreen(),
      ),
      GoRoute(
        path: '/buyer/shipments',
        name: 'buyer_shipments',
        builder: (context, state) => const ShipmentListScreen(),
      ),
      GoRoute(
        path: '/buyer/marketplace',
        name: 'buyer_marketplace',
        builder: (context, state) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: '/buyer/more',
        name: 'buyer_more',
        builder: (context, state) => const BuyerMoreScreen(),
      ),

      // ==================== EXPORTER DASHBOARD ROUTES ====================
      GoRoute(
        path: '/exporter/contracts',
        name: 'exporter_contracts',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'contracts',
          title: 'Export contracts',
          emptyMessage: 'Contracts assigned to your export operation will appear here.',
          detailRoute: '/contracts/detail',
        ),
      ),
      GoRoute(
        path: '/exporter/warehouse',
        name: 'exporter_warehouse',
        builder: (context, state) => const ProductionDashboard(
          role: DashboardRole.exporter,
          headline: 'Warehouse activity',
          description: 'Lots and shipments assigned to your export operation.',
          actionLabel: 'Create export order',
          actionRoute: '/exports/create',
          feeds: [
            DashboardFeed(resource: 'lots', title: 'Lots', route: '/lots'),
            DashboardFeed(resource: 'shipments', title: 'Shipments', route: '/shipments'),
          ],
        ),
      ),
      GoRoute(
        path: '/exporter/tracking',
        name: 'exporter_tracking',
        builder: (context, state) => const ShipmentListScreen(),
      ),
      GoRoute(
        path: '/exporter/dossiers',
        name: 'exporter_dossiers',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'quality_inspections',
          title: 'Quality dossiers',
          emptyMessage: 'Verified inspection records will appear here.',
          detailRoute: '/dossiers/detail',
        ),
      ),

      // ==================== HOME DASHBOARD ACTION ROUTES ====================

      GoRoute(
        path: '/rfqs',
        builder: (context, state) => const RfqListScreen(),
      ),
      GoRoute(
        path: '/rfqs/create',
        builder: (context, state) => const CreateRFQScreen(),
      ),
      GoRoute(
        path: '/rfqs/detail/:rfqId',
        builder: (context, state) {
          final rfqId = state.pathParameters['rfqId']!;
          return RfqDetailScreen(rfqId: rfqId);
        },
      ),
      GoRoute(
        path: '/rfqs/edit/:rfqId',
        builder: (context, state) {
          final rfqId = state.pathParameters['rfqId']!;
          return RfqEditScreen(rfqId: rfqId);
        },
      ),
      GoRoute(
        path: '/shipments',
        builder: (context, state) => const ShipmentListScreen(),
      ),
      GoRoute(
        path: '/shipments/detail/:shipmentId',
        builder: (context, state) {
          final shipmentId = state.pathParameters['shipmentId']!;
          return ShipmentDetailScreen(shipmentId: shipmentId);
        },
      ),
      GoRoute(
        path: '/lots',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'lots',
          title: 'My lots',
          emptyMessage: 'Create a real inventory lot to begin trading.',
          detailRoute: '/lots/detail',
        ),
      ),
      GoRoute(
        path: '/lots/create',
        builder: (context, state) => const CreateLotScreen(),
      ),
      GoRoute(
        path: '/lots/detail/:lotId',
        builder: (context, state) {
          final lotId = state.pathParameters['lotId']!;
          return LiveRecordDetailScreen(
            resource: 'lots',
            recordId: lotId,
            title: 'Lot details',
          );
        },
      ),
      GoRoute(
        path: '/lots/edit/:lotId',
        builder: (context, state) {
          final lotId = state.pathParameters['lotId']!;
          return LotEditScreen(lotId: lotId);
        },
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'payments',
          title: 'Payments',
          emptyMessage: 'Verified payment and escrow activity will appear here.',
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'orders',
          title: 'Orders',
          emptyMessage: 'Orders created from accepted offers will appear here.',
        ),
      ),
      GoRoute(
        path: '/contracts',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'contracts',
          title: 'Contracts',
          emptyMessage: 'Contracts created from accepted offers will appear here.',
          detailRoute: '/contracts/detail',
        ),
      ),
      GoRoute(
        path: '/contracts/detail/:contractId',
        builder: (context, state) {
          final contractId = state.pathParameters['contractId']!;
          return LiveRecordDetailScreen(
            resource: 'contracts',
            recordId: contractId,
            title: 'Contract details',
          );
        },
      ),
      GoRoute(
        path: '/contracts/manage/:contractId',
        builder: (context, state) {
          final contractId = state.pathParameters['contractId']!;
          return ContractManageScreen(contractId: contractId);
        },
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesScreen(),
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
        builder: (context, state) => const BuyerAnalyticsScreen(),
      ),
      GoRoute(
        path: '/marketplace/supplier/:supplierId',
        builder: (context, state) {
          final supplierId = state.pathParameters['supplierId']!;
          return SupplierProfileScreen(supplierId: supplierId);
        },
      ),
      GoRoute(
        path: '/dossiers',
        builder: (context, state) => const LiveResourceScreen(
          resource: 'quality_inspections',
          title: 'Quality dossiers',
          emptyMessage: 'Verified inspection activity will appear here.',
          detailRoute: '/dossiers/detail',
        ),
      ),
      GoRoute(
        path: '/dossiers/detail/:dossierId',
        builder: (context, state) {
          final dossierId = state.pathParameters['dossierId']!;
          return LiveRecordDetailScreen(
            resource: 'quality_inspections',
            recordId: dossierId,
            title: 'Inspection details',
          );
        },
      ),
      GoRoute(
        path: '/dossiers/view/:dossierId',
        builder: (context, state) {
          final dossierId = state.pathParameters['dossierId']!;
          return LiveRecordDetailScreen(
            resource: 'quality_inspections',
            recordId: dossierId,
            title: 'Inspection details',
          );
        },
      ),
      GoRoute(
        path: '/warehouse',
        builder: (context, state) => const ExporterWarehouseScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const ExporterTrackingScreen(),
      ),
      GoRoute(
        path: '/tracking/detail/:trackingId',
        builder: (context, state) {
          final trackingId = state.pathParameters['trackingId']!;
          return TrackingDetailScreen(trackingId: trackingId);
        },
      ),
      GoRoute(
        path: '/exports/create',
        builder: (context, state) => const CreateExportRequestScreen(),
      ),
      GoRoute(
        path: '/pipeline',
        builder: (context, state) => const ExportPipelineScreen(),
      ),

      // ==================== TRADING & RFQ ROUTES ====================

      /// Trading Dashboard - Main hub for all RFQ/bid operations
      GoRoute(
        path: '/trading',
        name: 'trading',
        builder: (context, state) => const TradingScreen(),
      ),

      /// Create RFQ - Buyer creates request for quote
      GoRoute(
        path: '/trading/create-rfq',
        name: 'create_rfq',
        builder: (context, state) => const CreateRFQScreen(),
      ),

      /// Trade Detail - View specific RFQ with live bids and chat
      GoRoute(
        path: '/trading/trade/:tradeId',
        name: 'trade_detail',
        builder: (context, state) {
          final tradeId = state.pathParameters['tradeId']!;
          return TradeDetailScreen(tradeId: tradeId);
        },
      ),

      /// Seller RFQ List - View all available RFQs for quoting
      GoRoute(
        path: '/trading/seller-rfqs',
        name: 'seller_rfqs',
        builder: (context, state) => const OpenRfqMarketplaceScreen(),
      ),

      /// Submit Bid - Seller submits quote for RFQ
      GoRoute(
        path: '/trading/submit-bid/:rfqId',
        name: 'submit_bid',
        builder: (context, state) {
          final rfqId = state.pathParameters['rfqId']!;
          return SubmitBidScreen(rfqId: rfqId);
        },
      ),

      /// Seller Bid Detail - Seller views buyer's response and proceeds to shipping
      GoRoute(
        path: '/trading/seller-bid/:bidId',
        name: 'seller_bid_detail',
        builder: (context, state) {
          final bidId = state.pathParameters['bidId']!;
          return SellerBidDetailScreen(bidId: bidId);
        },
      ),

      /// Payment Screen - Buyer processes payment with fraud detection
      GoRoute(
        path: '/trading/payment/:tradeId',
        name: 'payment',
        builder: (context, state) {
          final tradeId = state.pathParameters['tradeId']!;
          return PaymentScreen(tradeId: tradeId);
        },
      ),

      /// Contract Signing - Both parties sign contract with digital e-signature
      GoRoute(
        path: '/trading/contract/:tradeId',
        name: 'contract_signing',
        builder: (context, state) {
          final tradeId = state.pathParameters['tradeId']!;
          return ContractSigningScreen(tradeId: tradeId);
        },
      ),

      /// Order Tracking - Real-time GPS tracking, temperature monitoring, ETA
      GoRoute(
        path: '/trading/tracking/:tradeId',
        name: 'order_tracking',
        builder: (context, state) {
          final tradeId = state.pathParameters['tradeId']!;
          return OrderTrackingScreen(tradeId: tradeId);
        },
      ),

      /// Shipping Instructions - Seller provides carrier, tracking, delivery info
      GoRoute(
        path: '/trading/shipping/:bidId',
        name: 'shipping_instructions',
        builder: (context, state) {
          final bidId = state.pathParameters['bidId']!;
          return ShippingInstructionsScreen(bidId: bidId);
        },
      ),

      /// Buyer Delivery Confirmation - Buyer verifies delivery and quality
      GoRoute(
        path: '/trading/delivery/:tradeId',
        name: 'delivery_confirmation',
        builder: (context, state) {
          final tradeId = state.pathParameters['tradeId']!;
          return BuyerDeliveryConfirmationScreen(tradeId: tradeId);
        },
      ),

      /// Dispute Resolution - Handle quality issues, submit evidence, real-time chat
      GoRoute(
        path: '/trading/dispute/:tradeId',
        name: 'dispute_resolution',
        builder: (context, state) {
          final tradeId = state.pathParameters['tradeId']!;
          return DisputeResolutionScreen(tradeId: tradeId);
        },
      ),

      // ==================== LOT MANAGEMENT ROUTES ====================

      /// Create Lot - Seller creates new lot listing
      GoRoute(
        path: '/trading/create-lot',
        name: 'create_lot',
        builder: (context, state) => const CreateLotScreen(),
      ),

      /// Lot Photo Upload - Upload product photos for lot
      GoRoute(
        path: '/trading/lot-photo-upload/:lotId',
        name: 'lot_photo_upload',
        builder: (context, state) {
          final lotId = state.pathParameters['lotId']!;
          return LotPhotoUploadScreen(lotId: lotId);
        },
      ),

      /// Lot QR Display - Show unique QR code for tracking
      GoRoute(
        path: '/trading/lot-qr-display/:lotId',
        name: 'lot_qr_display',
        builder: (context, state) {
          final lotId = state.pathParameters['lotId']!;
          return LotQRDisplayScreen(lotId: lotId);
        },
      ),

      /// Lot Tracking - Real-time GPS tracking, temperature, status
      GoRoute(
        path: '/trading/lot-tracking/:lotId',
        name: 'lot_tracking',
        builder: (context, state) {
          final lotId = state.pathParameters['lotId']!;
          return LotTrackingScreen(lotId: lotId);
        },
      ),

      /// Lot History - Complete immutable lot history and events
      GoRoute(
        path: '/trading/lot-history/:lotId',
        name: 'lot_history',
        builder: (context, state) {
          final lotId = state.pathParameters['lotId']!;
          return LotHistoryScreen(lotId: lotId);
        },
      ),

      // ==================== MARKETPLACE ROUTES ====================

      /// Marketplace - Search and browse all products with real-time filters
      GoRoute(
        path: '/marketplace',
        name: 'marketplace',
        builder: (context, state) => const MarketplaceScreen(),
      ),
    ],
  );
});
