class QuoteModel {
  final String id;
  final String buyerId;
  final String? buyerName;
  final String lotId;
  final String productName;
  final double pricePerUnit;
  final double suggestedPricePerUnit;
  final double quantity;
  final String quantityUnit;
  final double suggestedTotalPrice;
  final String status; // pending, counter_offered, accepted, rejected, expired
  final String? notes;
  final DateTime expiryAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;

  QuoteModel({
    required this.id,
    required this.buyerId,
    this.buyerName,
    required this.lotId,
    required this.productName,
    required this.pricePerUnit,
    required this.suggestedPricePerUnit,
    required this.quantity,
    required this.quantityUnit,
    required this.suggestedTotalPrice,
    required this.status,
    this.notes,
    required this.expiryAt,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String?,
      lotId: json['lotId'] as String,
      productName: json['productName'] as String,
      pricePerUnit: double.parse(json['pricePerUnit'].toString()),
      suggestedPricePerUnit: double.parse(json['suggestedPricePerUnit'].toString()),
      quantity: double.parse(json['quantity'].toString()),
      quantityUnit: json['quantityUnit'] as String,
      suggestedTotalPrice: double.parse(json['suggestedTotalPrice'].toString()),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      expiryAt: DateTime.parse(json['expiryAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'lotId': lotId,
      'productName': productName,
      'pricePerUnit': pricePerUnit,
      'suggestedPricePerUnit': suggestedPricePerUnit,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'suggestedTotalPrice': suggestedTotalPrice,
      'status': status,
      'notes': notes,
      'expiryAt': expiryAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  QuoteModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? lotId,
    String? productName,
    double? pricePerUnit,
    double? suggestedPricePerUnit,
    double? quantity,
    String? quantityUnit,
    double? suggestedTotalPrice,
    String? status,
    String? notes,
    DateTime? expiryAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      lotId: lotId ?? this.lotId,
      productName: productName ?? this.productName,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      suggestedPricePerUnit: suggestedPricePerUnit ?? this.suggestedPricePerUnit,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      suggestedTotalPrice: suggestedTotalPrice ?? this.suggestedTotalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      expiryAt: expiryAt ?? this.expiryAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  double get priceDiscount => (pricePerUnit - suggestedPricePerUnit).abs();
  double get discountPercentage => (priceDiscount / pricePerUnit * 100);
  bool get isExpired => DateTime.now().isAfter(expiryAt);
  bool get isAccepted => status == 'accepted';
  bool get isPending => status == 'pending';
  bool get isCounterOffered => status == 'counter_offered';

  @override
  String toString() => 'QuoteModel(id: $id, product: $productName, suggested: \$$suggestedPricePerUnit, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
import 'package:json_annotation/json_annotation.dart';

part 'quote_model.g.dart';

@JsonSerializable()
class QuoteModel {
  final String id;
  final String orderId;
  final String lotId;
  final String fromUserId;
  final String toUserId;
  final String? quoteType;
  final double quotedPrice;
  final double quotedQuantity;
  final String quantityUnit;
  final String? termsAndConditions;
  final String? notes;
  final String? deliveryLocation;
  final DateTime? proposedDeliveryDate;
  final String status;
  final DateTime expiresAt;
  final bool isExpired;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? counterQuoteId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserData? fromUser;
  final UserData? toUser;

  QuoteModel({
    required this.id,
    required this.orderId,
    required this.lotId,
    required this.fromUserId,
    required this.toUserId,
    this.quoteType,
    required this.quotedPrice,
    required this.quotedQuantity,
    required this.quantityUnit,
    this.termsAndConditions,
    this.notes,
    this.deliveryLocation,
    this.proposedDeliveryDate,
    required this.status,
    required this.expiresAt,
    required this.isExpired,
    this.acceptedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.counterQuoteId,
    required this.createdAt,
    required this.updatedAt,
    this.fromUser,
    this.toUser,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuoteModelToJson(this);

  QuoteModel copyWith({
    String? id,
    String? orderId,
    String? lotId,
    String? fromUserId,
    String? toUserId,
    String? quoteType,
    double? quotedPrice,
    double? quotedQuantity,
    String? quantityUnit,
    String? termsAndConditions,
    String? notes,
    String? deliveryLocation,
    DateTime? proposedDeliveryDate,
    String? status,
    DateTime? expiresAt,
    bool? isExpired,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
    String? counterQuoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserData? fromUser,
    UserData? toUser,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      lotId: lotId ?? this.lotId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      quoteType: quoteType ?? this.quoteType,
      quotedPrice: quotedPrice ?? this.quotedPrice,
      quotedQuantity: quotedQuantity ?? this.quotedQuantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      notes: notes ?? this.notes,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      proposedDeliveryDate: proposedDeliveryDate ?? this.proposedDeliveryDate,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpired: isExpired ?? this.isExpired,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      counterQuoteId: counterQuoteId ?? this.counterQuoteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteModel &&
        other.id == id &&
        other.orderId == orderId &&
        other.status == status &&
        other.quotedPrice == quotedPrice;
  }

  @override
  int get hashCode => id.hashCode ^ orderId.hashCode;
}

@JsonSerializable()
class UserData {
  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;

  UserData({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

// Quote status enum
enum QuoteStatus {
  pending,
  accepted,
  rejected,
  expired,
  countered,
}

// Quote type enum
enum QuoteType {
  sellerQuote,
  buyerCounterOffer,
  negotiation,
}
