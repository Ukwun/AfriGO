// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String?,
      contractId: json['contractId'] as String?,
      buyerId: json['buyerId'] as String?,
      sellerId: json['sellerId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentStatus: json['paymentStatus'] as String?,
      status: json['status'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      invoiceReference: json['invoiceReference'] as String?,
      description: json['description'] as String?,
      relatedProduct: json['relatedProduct'] as String?,
      reference: json['reference'] as String?,
      flutterwaveReference: json['flutterwaveReference'] as String?,
      flutterwavePaymentUrl: json['flutterwavePaymentUrl'] as String?,
      escrowStatus: json['escrowStatus'] as String?,
      cardInfo: json['cardInfo'] == null
          ? null
          : CardInfoModel.fromJson(json['cardInfo'] as Map<String, dynamic>),
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      stripeChargeId: json['stripeChargeId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      lateFeeAmount: (json['lateFeeAmount'] as num?)?.toDouble(),
      lateFeeTriggeredAt: json['lateFeeTriggeredAt'] == null
          ? null
          : DateTime.parse(json['lateFeeTriggeredAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'contractId': instance.contractId,
      'buyerId': instance.buyerId,
      'sellerId': instance.sellerId,
      'amount': instance.amount,
      'currency': instance.currency,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'status': instance.status,
      'invoiceNumber': instance.invoiceNumber,
      'invoiceReference': instance.invoiceReference,
      'description': instance.description,
      'relatedProduct': instance.relatedProduct,
      'reference': instance.reference,
      'flutterwaveReference': instance.flutterwaveReference,
      'flutterwavePaymentUrl': instance.flutterwavePaymentUrl,
      'escrowStatus': instance.escrowStatus,
      'cardInfo': instance.cardInfo,
      'stripePaymentIntentId': instance.stripePaymentIntentId,
      'stripeChargeId': instance.stripeChargeId,
      'receiptUrl': instance.receiptUrl,
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'lateFeeAmount': instance.lateFeeAmount,
      'lateFeeTriggeredAt': instance.lateFeeTriggeredAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

EscrowModel _$EscrowModelFromJson(Map<String, dynamic> json) => EscrowModel(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      holdingPeriodDays: (json['holdingPeriodDays'] as num).toInt(),
      holdingFeePercentage: (json['holdingFeePercentage'] as num).toDouble(),
      conditionsMet: json['conditionsMet'] as Map<String, dynamic>,
      autoReleaseDate: json['autoReleaseDate'] == null
          ? null
          : DateTime.parse(json['autoReleaseDate'] as String),
      releasedAt: json['releasedAt'] == null
          ? null
          : DateTime.parse(json['releasedAt'] as String),
      refundedAt: json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EscrowModelToJson(EscrowModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentId': instance.paymentId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'holdingPeriodDays': instance.holdingPeriodDays,
      'holdingFeePercentage': instance.holdingFeePercentage,
      'conditionsMet': instance.conditionsMet,
      'autoReleaseDate': instance.autoReleaseDate?.toIso8601String(),
      'releasedAt': instance.releasedAt?.toIso8601String(),
      'refundedAt': instance.refundedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

PaymentResponseDto _$PaymentResponseDtoFromJson(Map<String, dynamic> json) =>
    PaymentResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : PaymentModel.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$PaymentResponseDtoToJson(PaymentResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
    };

CardInfoModel _$CardInfoModelFromJson(Map<String, dynamic> json) =>
    CardInfoModel(
      brand: json['brand'] as String,
      last4: json['last4'] as String,
      expMonth: (json['expMonth'] as num?)?.toInt(),
      expYear: (json['expYear'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CardInfoModelToJson(CardInfoModel instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'last4': instance.last4,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
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
