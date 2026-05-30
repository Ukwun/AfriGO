import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/onboarding/splash_screen.dart';
import '../presentation/screens/onboarding/welcome_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/buyer_home_screen.dart';
import '../presentation/screens/home/supplier_home_screen.dart';
import '../presentation/screens/home/exporter_home_screen.dart';
import '../presentation/screens/common/feature_placeholder_screen.dart';
import '../presentation/screens/trading/trading_screen.dart';
import '../presentation/screens/trading/create_rfq_screen_modern.dart';
import '../presentation/screens/trading/trade_detail_screen.dart';
import '../presentation/screens/trading/seller_rfq_list_screen.dart';
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

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard/buyer',
        builder: (context, state) => const Scaffold(
          backgroundColor: Color(0xFFF7F8FA),
          body: BuyerHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard/seller',
        builder: (context, state) => const Scaffold(
          backgroundColor: Color(0xFFF7F8FA),
          body: SupplierHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard/exporter',
        builder: (context, state) => const Scaffold(
          backgroundColor: Color(0xFFF7F8FA),
          body: ExporterHomeScreen(),
        ),
      ),

      // ==================== HOME DASHBOARD ACTION ROUTES ====================

      GoRoute(
        path: '/rfqs',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Open RFQs',
          subtitle: 'Active requests and supplier responses in real time.',
          icon: Icons.request_quote_outlined,
        ),
      ),
      GoRoute(
        path: '/rfqs/create',
        builder: (context, state) => const CreateRFQScreen(),
      ),
      GoRoute(
        path: '/rfqs/detail/:rfqId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'RFQ ${state.pathParameters['rfqId']}',
          subtitle: 'Detailed RFQ timeline, supplier bids, and negotiation.',
          icon: Icons.description_outlined,
        ),
      ),
      GoRoute(
        path: '/rfqs/edit/:rfqId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Edit RFQ ${state.pathParameters['rfqId']}',
          subtitle: 'Update quantity, delivery terms, and compliance notes.',
          icon: Icons.edit_note_outlined,
        ),
      ),
      GoRoute(
        path: '/shipments',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Shipments',
          subtitle: 'Track active shipments, ETAs, and quality checks live.',
          icon: Icons.local_shipping_outlined,
        ),
      ),
      GoRoute(
        path: '/shipments/detail/:shipmentId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Shipment ${state.pathParameters['shipmentId']}',
          subtitle: 'Live route map, temperature telemetry, and milestones.',
          icon: Icons.pin_drop_outlined,
        ),
      ),
      GoRoute(
        path: '/lots',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Active Lots',
          subtitle: 'Manage inventory, offers, and lot lifecycle.',
          icon: Icons.inventory_2_outlined,
        ),
      ),
      GoRoute(
        path: '/lots/create',
        builder: (context, state) => const CreateLotScreen(),
      ),
      GoRoute(
        path: '/lots/detail/:lotId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Lot ${state.pathParameters['lotId']}',
          subtitle: 'Quality score, bids received, and shipping readiness.',
          icon: Icons.qr_code_2_outlined,
        ),
      ),
      GoRoute(
        path: '/lots/edit/:lotId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Edit Lot ${state.pathParameters['lotId']}',
          subtitle: 'Update lot metadata, pricing, and stock allocation.',
          icon: Icons.tune_outlined,
        ),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Payments',
          subtitle: 'Escrow timeline, payout status, and transaction history.',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ),
      GoRoute(
        path: '/contracts',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Contracts',
          subtitle: 'Manage active agreements and milestones.',
          icon: Icons.description_outlined,
        ),
      ),
      GoRoute(
        path: '/contracts/detail/:contractId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Contract ${state.pathParameters['contractId']}',
          subtitle: 'Contract clauses, signatures, and compliance checks.',
          icon: Icons.gavel_outlined,
        ),
      ),
      GoRoute(
        path: '/contracts/manage/:contractId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Manage Contract ${state.pathParameters['contractId']}',
          subtitle: 'Amendments, delivery updates, and payment milestones.',
          icon: Icons.manage_accounts_outlined,
        ),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Messages',
          subtitle: 'Live chat with suppliers, buyers, and logistics teams.',
          icon: Icons.chat_bubble_outline,
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
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Analytics',
          subtitle: 'Trade trends, pricing movement, and demand forecasts.',
          icon: Icons.bar_chart_outlined,
        ),
      ),
      GoRoute(
        path: '/marketplace/supplier/:supplierId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Supplier ${state.pathParameters['supplierId']}',
          subtitle:
              'Supplier profile, trust score, and historical performance.',
          icon: Icons.verified_user_outlined,
        ),
      ),
      GoRoute(
        path: '/dossiers',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Dossiers',
          subtitle: 'Export documentation, approvals, and customs packets.',
          icon: Icons.folder_outlined,
        ),
      ),
      GoRoute(
        path: '/dossiers/detail/:dossierId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title:
              'Dossier ${Uri.decodeComponent(state.pathParameters['dossierId']!)}',
          subtitle: 'Document status, missing items, and verification trail.',
          icon: Icons.fact_check_outlined,
        ),
      ),
      GoRoute(
        path: '/dossiers/view/:dossierId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title:
              'View Dossier ${Uri.decodeComponent(state.pathParameters['dossierId']!)}',
          subtitle: 'Full export packet preview and audit stamps.',
          icon: Icons.visibility_outlined,
        ),
      ),
      GoRoute(
        path: '/warehouse',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Warehouse',
          subtitle: 'Slot utilization, occupancy, and storage activity.',
          icon: Icons.warehouse_outlined,
        ),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Tracking',
          subtitle: 'Real-time visibility into export shipment progress.',
          icon: Icons.my_location_outlined,
        ),
      ),
      GoRoute(
        path: '/tracking/detail/:trackingId',
        builder: (context, state) => FeaturePlaceholderScreen(
          title: 'Tracking ${state.pathParameters['trackingId']}',
          subtitle: 'Granular events, checkpoints, and ETA projection.',
          icon: Icons.location_searching_outlined,
        ),
      ),
      GoRoute(
        path: '/exports/create',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Create Export Order',
          subtitle:
              'Initialize a new export workflow and compliance checklist.',
          icon: Icons.add_chart_outlined,
        ),
      ),
      GoRoute(
        path: '/pipeline',
        builder: (context, state) => const FeaturePlaceholderScreen(
          title: 'Export Pipeline',
          subtitle: 'Pipeline stages with live status and bottleneck signals.',
          icon: Icons.timeline_outlined,
        ),
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
        builder: (context, state) => const SellerRFQListScreen(),
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
