// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      escrowStatus: json['escrowStatus'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      cardInfo: json['cardInfo'] == null
          ? null
          : CardInfoModel.fromJson(json['cardInfo'] as Map<String, dynamic>),
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      stripeChargeId: json['stripeChargeId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      refundedAt: json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
      failureReason: json['failureReason'] as String?,
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'userId': instance.userId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'escrowStatus': instance.escrowStatus,
      'paymentMethod': instance.paymentMethod,
      'cardInfo': instance.cardInfo,
      'stripePaymentIntentId': instance.stripePaymentIntentId,
      'stripeChargeId': instance.stripeChargeId,
      'receiptUrl': instance.receiptUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'refundedAt': instance.refundedAt?.toIso8601String(),
      'failureReason': instance.failureReason,
    };

CardInfoModel _$CardInfoModelFromJson(Map<String, dynamic> json) =>
    CardInfoModel(
      brand: json['brand'] as String?,
      last4: json['last4'] as String?,
      expMonth: (json['expiryMonth'] as num?)?.toInt(),
      expYear: (json['expiryYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CardInfoModelToJson(CardInfoModel instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'last4': instance.last4,
      'expiryMonth': instance.expMonth,
      'expiryYear': instance.expYear,
    };

PaymentHistoryResponseModel _$PaymentHistoryResponseModelFromJson(
        Map<String, dynamic> json) =>
    PaymentHistoryResponseModel(
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaymentPaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentHistoryResponseModelToJson(
        PaymentHistoryResponseModel instance) =>
    <String, dynamic>{
      'payments': instance.payments,
      'pagination': instance.pagination,
    };

PaymentPaginationModel _$PaymentPaginationModelFromJson(
        Map<String, dynamic> json) =>
    PaymentPaginationModel(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentPaginationModelToJson(
        PaymentPaginationModel instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
    };
