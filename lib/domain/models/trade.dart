import 'package:json_annotation/json_annotation.dart';
import 'bid.dart';

part 'trade.g.dart';

/// Trade Model (RFQ/Offer/Deal)
/// REAL trade with:
/// - Immutable activity logging
/// - Real-time WebSocket updates
/// - Fraud detection on creation
/// - Trust score calculations
/// - Bids/quotes from sellers (RFQ phase)
@JsonSerializable()
class Trade {
  final String id;
  final String buyerId;
  final String? buyerName;
  final String? buyerAvatarUrl;

  final String? sellerId;
  final String? sellerName;
  final String? sellerAvatarUrl;

  final String? productId;
  final String? productName;

  // RFQ fields
  final String productType;
  final double quantity;
  final double offeredPrice;
  final String? qualityGrade;
  final DateTime? deliveryDate;
  final String? deliveryLocation;
  final String? specialRequirements;

  final String
  status; // OPEN, NEGOTIATING, ACCEPTED, PAYMENT_PENDING, COMPLETED, CANCELLED

  // Real timestamps
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Fraud information
  final double? fraudScore;
  final String? fraudStatus; // PASSED, REVIEW, BLOCKED

  // Activity tracking (immutable, append-only)
  final List<String>? activityLog;

  // Bids/quotes (for RFQ phase)
  final List<Bid>? bids;

  // Messages (for negotiation)
  final List<Map<String, dynamic>>? messages;

  // Trust impact
  final int? trustPointsEarned;

  Trade({
    required this.id,
    required this.buyerId,
    this.buyerName,
    this.buyerAvatarUrl,
    this.sellerId,
    this.sellerName,
    this.sellerAvatarUrl,
    this.productId,
    this.productName,
    required this.productType,
    required this.quantity,
    required this.offeredPrice,
    this.qualityGrade,
    this.deliveryDate,
    this.deliveryLocation,
    this.specialRequirements,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.fraudScore,
    this.fraudStatus,
    this.activityLog,
    this.bids,
    this.messages,
    this.trustPointsEarned,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String?,
      buyerAvatarUrl: json['buyerAvatarUrl'] as String?,
      sellerId: json['sellerId'] as String?,
      sellerName: json['sellerName'] as String?,
      sellerAvatarUrl: json['sellerAvatarUrl'] as String?,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      productType: json['productType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      offeredPrice: (json['offeredPrice'] as num).toDouble(),
      qualityGrade: json['qualityGrade'] as String?,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
          : null,
      deliveryLocation: json['deliveryLocation'] as String?,
      specialRequirements: json['specialRequirements'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      fraudScore: (json['fraudScore'] as num?)?.toDouble(),
      fraudStatus: json['fraudStatus'] as String?,
      activityLog: (json['activityLog'] as List<dynamic>?)?.cast<String>(),
      bids: (json['bids'] as List<dynamic>?)
          ?.map((b) => Bid.fromJson(b as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>(),
      trustPointsEarned: json['trustPointsEarned'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerAvatarUrl': buyerAvatarUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatarUrl': sellerAvatarUrl,
      'productId': productId,
      'productName': productName,
      'productType': productType,
      'quantity': quantity,
      'offeredPrice': offeredPrice,
      'qualityGrade': qualityGrade,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryLocation': deliveryLocation,
      'specialRequirements': specialRequirements,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'fraudScore': fraudScore,
      'fraudStatus': fraudStatus,
      'activityLog': activityLog,
      'bids': bids?.map((b) => b.toJson()).toList(),
      'messages': messages,
      'trustPointsEarned': trustPointsEarned,
    };
  }

  /// Check if trade is in RFQ phase (no seller yet)
  bool get isRFQPhase => sellerId == null || sellerId?.isEmpty == true;

  /// Check if trade is in active negotiation
  bool get isNegotiating => status == 'NEGOTIATING';

  /// Check if trade is accepted
  bool get isAccepted => status == 'ACCEPTED';

  /// Check if trade is completed
  bool get isCompleted => status == 'COMPLETED';

  /// Get fraud risk level
  String get fraudRiskLevel {
    if (fraudScore == null) return 'UNKNOWN';
    if (fraudScore! > 80) return 'HIGH';
    if (fraudScore! > 50) return 'MEDIUM';
    return 'LOW';
  }

  /// Get best bid from all bids
  Bid? get bestBid {
    if (bids == null || bids!.isEmpty) return null;
    return bids!.reduce((a, b) => a.offeredPrice < b.offeredPrice ? a : b);
  }

  /// Get total value of trade (quantity * price)
  double get totalValue => quantity * offeredPrice;
}
