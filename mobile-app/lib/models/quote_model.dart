import 'package:json_annotation/json_annotation.dart';
import 'user_data_model.dart';

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
