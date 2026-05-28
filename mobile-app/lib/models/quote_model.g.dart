// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteModel _$QuoteModelFromJson(Map<String, dynamic> json) => QuoteModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      lotId: json['lotId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      quoteType: json['quoteType'] as String?,
      quotedPrice: (json['quotedPrice'] as num).toDouble(),
      quotedQuantity: (json['quotedQuantity'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      termsAndConditions: json['termsAndConditions'] as String?,
      notes: json['notes'] as String?,
      deliveryLocation: json['deliveryLocation'] as String?,
      proposedDeliveryDate: json['proposedDeliveryDate'] == null
          ? null
          : DateTime.parse(json['proposedDeliveryDate'] as String),
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isExpired: json['isExpired'] as bool,
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      rejectedAt: json['rejectedAt'] == null
          ? null
          : DateTime.parse(json['rejectedAt'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      counterQuoteId: json['counterQuoteId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fromUser: json['fromUser'] == null
          ? null
          : UserData.fromJson(json['fromUser'] as Map<String, dynamic>),
      toUser: json['toUser'] == null
          ? null
          : UserData.fromJson(json['toUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuoteModelToJson(QuoteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'lotId': instance.lotId,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'quoteType': instance.quoteType,
      'quotedPrice': instance.quotedPrice,
      'quotedQuantity': instance.quotedQuantity,
      'quantityUnit': instance.quantityUnit,
      'termsAndConditions': instance.termsAndConditions,
      'notes': instance.notes,
      'deliveryLocation': instance.deliveryLocation,
      'proposedDeliveryDate': instance.proposedDeliveryDate?.toIso8601String(),
      'status': instance.status,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isExpired': instance.isExpired,
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'rejectionReason': instance.rejectionReason,
      'counterQuoteId': instance.counterQuoteId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'fromUser': instance.fromUser,
      'toUser': instance.toUser,
    };
