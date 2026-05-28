import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/onboarding/splash_screen.dart';
import '../presentation/screens/onboarding/welcome_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/dashboard/buyer_dashboard_screen.dart';
import '../presentation/screens/dashboard/seller_dashboard_screen.dart';
import '../presentation/screens/dashboard/exporter_dashboard_screen.dart';
import '../presentation/screens/trading/trading_screen.dart';
import '../presentation/screens/trading/create_rfq_screen.dart';
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
        builder: (context, state) => const BuyerDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/seller',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/exporter',
        builder: (context, state) => const ExporterDashboardScreen(),
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
