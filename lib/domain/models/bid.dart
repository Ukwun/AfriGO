/// Bid Model
/// Represents a seller's quote/bid on an RFQ
class Bid {
  final String id;
  final String rfqId;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;
  final double? sellerTrustScore; // 0-5 scale
  final int? sellerCompletedTrades;
  final double? sellerSuccessRate;
  final bool? sellerKycVerified;

  final double offeredPrice; // Per kg
  final double quantity;
  final String qualityGrade;
  final int estimatedDeliveryDays;

  final String status; // PENDING, ACCEPTED, REJECTED, COUNTERED
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;

  final List<String>? counterOfferHistory; // All counter-offers for negotiation
  final List<String>? activityLog; // Immutable append-only log

  final double? fraudScore; // 0-100

  Bid({
    required this.id,
    required this.rfqId,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    this.sellerTrustScore,
    this.sellerCompletedTrades,
    this.sellerSuccessRate,
    this.sellerKycVerified,
    required this.offeredPrice,
    required this.quantity,
    required this.qualityGrade,
    required this.estimatedDeliveryDays,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.counterOfferHistory,
    this.activityLog,
    this.fraudScore,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rfqId': rfqId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatarUrl': sellerAvatarUrl,
      'sellerTrustScore': sellerTrustScore,
      'sellerCompletedTrades': sellerCompletedTrades,
      'sellerSuccessRate': sellerSuccessRate,
      'sellerKycVerified': sellerKycVerified,
      'offeredPrice': offeredPrice,
      'quantity': quantity,
      'qualityGrade': qualityGrade,
      'estimatedDeliveryDays': estimatedDeliveryDays,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'counterOfferHistory': counterOfferHistory,
      'activityLog': activityLog,
      'fraudScore': fraudScore,
    };
  }

  /// Create from JSON
  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] as String,
      rfqId: json['rfqId'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sellerAvatarUrl: json['sellerAvatarUrl'] as String?,
      sellerTrustScore: (json['sellerTrustScore'] as num?)?.toDouble(),
      sellerCompletedTrades: json['sellerCompletedTrades'] as int?,
      sellerSuccessRate: (json['sellerSuccessRate'] as num?)?.toDouble(),
      sellerKycVerified: json['sellerKycVerified'] as bool?,
      offeredPrice: (json['offeredPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      qualityGrade: json['qualityGrade'] as String,
      estimatedDeliveryDays: json['estimatedDeliveryDays'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'] as String)
          : null,
      counterOfferHistory: (json['counterOfferHistory'] as List<dynamic>?)
          ?.cast<String>(),
      activityLog: (json['activityLog'] as List<dynamic>?)?.cast<String>(),
      fraudScore: (json['fraudScore'] as num?)?.toDouble(),
    );
  }

  /// Copy with modifications
  Bid copyWith({
    String? id,
    String? rfqId,
    String? sellerId,
    String? sellerName,
    String? sellerAvatarUrl,
    double? sellerTrustScore,
    int? sellerCompletedTrades,
    double? sellerSuccessRate,
    bool? sellerKycVerified,
    double? offeredPrice,
    double? quantity,
    String? qualityGrade,
    int? estimatedDeliveryDays,
    String? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    List<String>? counterOfferHistory,
    List<String>? activityLog,
    double? fraudScore,
  }) {
    return Bid(
      id: id ?? this.id,
      rfqId: rfqId ?? this.rfqId,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatarUrl: sellerAvatarUrl ?? this.sellerAvatarUrl,
      sellerTrustScore: sellerTrustScore ?? this.sellerTrustScore,
      sellerCompletedTrades:
          sellerCompletedTrades ?? this.sellerCompletedTrades,
      sellerSuccessRate: sellerSuccessRate ?? this.sellerSuccessRate,
      sellerKycVerified: sellerKycVerified ?? this.sellerKycVerified,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      quantity: quantity ?? this.quantity,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      estimatedDeliveryDays:
          estimatedDeliveryDays ?? this.estimatedDeliveryDays,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      counterOfferHistory: counterOfferHistory ?? this.counterOfferHistory,
      activityLog: activityLog ?? this.activityLog,
      fraudScore: fraudScore ?? this.fraudScore,
    );
  }
}
