import 'package:json_annotation/json_annotation.dart';

part 'lot.g.dart';

/// Quality Test Result
@JsonSerializable()
class QualityTest {
  final String testName;
  final String result;
  final bool passed;
  final DateTime testedAt;

  QualityTest({
    required this.testName,
    required this.result,
    required this.passed,
    required this.testedAt,
  });

  factory QualityTest.fromJson(Map<String, dynamic> json) =>
      _$QualityTestFromJson(json);

  Map<String, dynamic> toJson() => _$QualityTestToJson(this);
}

/// Buyer Review
@JsonSerializable()
class BuyerReview {
  final String buyerName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  BuyerReview({
    required this.buyerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory BuyerReview.fromJson(Map<String, dynamic> json) =>
      _$BuyerReviewFromJson(json);

  Map<String, dynamic> toJson() => _$BuyerReviewToJson(this);
}

/// Bid Model
@JsonSerializable()
class Bid {
  final String id;
  final String buyerId;
  final String buyerName;
  final double price;
  final double quantity;
  final String status; // PENDING, ACCEPTED, REJECTED, CANCELLED
  final DateTime createdAt;

  Bid({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.price,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

  Map<String, dynamic> toJson() => _$BidToJson(this);
}

/// Lot Model (Product)
/// Contains REAL data from backend:
/// - Real trust scores from TrustScoringService
/// - Real fraud risk scores from FraudDetectionService
/// - Real quality tests (immutable)
/// - Real seller verification status
/// - Real buyer reviews
@JsonSerializable()
class Lot {
  final String id;
  final String productName;
  final String productType;
  final double quantity;
  final double price;
  final String qualityGrade;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> photoUrls;
  final DateTime harvestDate;
  final DateTime createdAt;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;

  // REAL data from backend services
  final double? sellerTrustScore; // From TrustScoringService (0-5★)
  final double? fraudRiskScore; // From FraudDetectionService (0-100)
  final int? sellerCompletedTrades;
  final double? sellerSuccessRate;
  final bool? sellerKycVerified;
  final bool? sellerPhoneVerified;
  final bool? sellerEmailVerified;

  // Immutable quality tests
  final List<QualityTest> qualityTests;

  // Real buyer reviews
  final List<BuyerReview> buyerReviews;

  // Real bids (updated in real-time via WebSocket)
  final List<Bid>? bids;

  // QR code (cryptographic, unique, unforgeable)
  final String? qrCode;

  // Activity log (immutable, append-only)
  final List<String>? activityLog;

  // Status tracking
  final String status; // CREATED, LISTED, RESERVED, SOLD, IN_TRANSIT, DELIVERED

  Lot({
    required this.id,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.price,
    required this.qualityGrade,
    this.location,
    this.latitude,
    this.longitude,
    required this.photoUrls,
    required this.harvestDate,
    required this.createdAt,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    this.sellerTrustScore,
    this.fraudRiskScore,
    this.sellerCompletedTrades,
    this.sellerSuccessRate,
    this.sellerKycVerified,
    this.sellerPhoneVerified,
    this.sellerEmailVerified,
    required this.qualityTests,
    required this.buyerReviews,
    this.bids,
    this.qrCode,
    this.activityLog,
    required this.status,
  });

  factory Lot.fromJson(Map<String, dynamic> json) => _$LotFromJson(json);

  Map<String, dynamic> toJson() => _$LotToJson(this);
}
