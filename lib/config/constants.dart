/// App Constants
class Constants {
  // API Configuration
  static const String baseUrl = 'https://api.afrigo.com';
  static const String webSocketUrl = 'wss://api.afrigo.com';

  // API Endpoints - Marketplace
  static const String lotsEndpoint = '/api/lots';
  static const String rfqEndpoint = '/api/trades/rfq';
  static const String offersEndpoint = '/api/offers';
  static const String favoriteEndpoint = '/api/favorites';

  // API Endpoints - Fraud Detection
  static const String fraudDetectionEndpoint = '/api/fraud-detection';

  // API Endpoints - Authentication
  static const String authLoginEndpoint = '/api/auth/login';
  static const String authRegisterEndpoint = '/api/auth/register';
  static const String authRefreshEndpoint = '/api/auth/refresh';

  // Fraud Detection Thresholds
  static const double fraudBlockThreshold = 80.0; // >80: BLOCK
  static const double fraudReviewThreshold = 70.0; // 70-80: MANUAL REVIEW
  // <70: PROCEED

  // Fraud Detection Patterns
  static const Map<String, double> fraudPatterns = {
    'unusual_location': 20,
    'activity_spike': 15,
    'large_transaction': 10,
    'payment_reversal': 25,
    'rapid_trades': 18,
    'dispute_abuse': 12,
    'kyc_mismatch': 22,
    'account_takeover': 35,
  };

  // Trust Score Configuration
  static const double trustScoreBase = 40.0;
  static const double trustScoreMax = 100.0;
  static const double trustScoreDisplayMax = 5.0;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration webSocketTimeout = Duration(seconds: 10);

  // Real-time Latencies (guaranteed)
  static const Duration websocketLatency = Duration(
    milliseconds: 300,
  ); // 0.3 seconds
  static const Duration databaseQueryLatency = Duration(
    milliseconds: 50,
  ); // <50ms

  // Product Categories
  static const List<String> productTypes = [
    'Cocoa',
    'Coffee',
    'Cashew',
    'Shea Butter',
    'Sesame',
    'Maize',
    'Cassava',
    'Beans',
    'Peas',
    'Rice',
  ];

  // Quality Grades
  static const List<String> qualityGrades = [
    'Grade A',
    'Grade B',
    'Grade C',
    'Premium',
    'Standard',
  ];

  // African Countries
  static const List<String> africanCountries = [
    'Uganda',
    'Ghana',
    'Kenya',
    'Nigeria',
    'Tanzania',
    'Ivory Coast',
    'Rwanda',
    'Malawi',
    'Zambia',
    'Ethiopia',
    'Cameroon',
    'Senegal',
    'South Africa',
    'Morocco',
    'Egypt',
  ];

  // Trade Statuses
  static const String tradeStatusRFQOpen = 'RFQ_OPEN';
  static const String tradeStatusQuoted = 'QUOTED';
  static const String tradeStatusNegotiating = 'NEGOTIATING';
  static const String tradeStatusAccepted = 'ACCEPTED';
  static const String tradeStatusPaymentPending = 'PAYMENT_PENDING';
  static const String tradeStatusCompleted = 'COMPLETED';

  // Lot Statuses
  static const String lotStatusCreated = 'CREATED';
  static const String lotStatusListed = 'LISTED';
  static const String lotStatusReserved = 'RESERVED';
  static const String lotStatusSold = 'SOLD';
  static const String lotStatusInTransit = 'IN_TRANSIT';
  static const String lotStatusDelivered = 'DELIVERED';
}
