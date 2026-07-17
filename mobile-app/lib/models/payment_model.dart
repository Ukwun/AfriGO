import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

/// Payment model for Flutterwave payment processing
@JsonSerializable()
class PaymentModel {
  final String id;
  final String? orderId;
  final String? contractId;
  final String? buyerId;
  final String? sellerId;
  final double amount;
  final String currency; // KES, USD, EUR, ZAR, UGX, TZS
  final String
      paymentMethod; // FULL_UPFRONT, PARTIAL_DEPOSIT, ON_DELIVERY, INSTALLMENT, ESCROW
  final String? paymentStatus;
  final String?
      status; // PENDING, INITIATED, PROCESSING, COMPLETED, FAILED, REFUNDED, DISPUTED, SUCCEEDED
  final String? invoiceNumber;
  final String? invoiceReference; // INV-YYYY-XXXXXX
  final String? description;
  final String? relatedProduct;
  final String? reference;
  final String? flutterwaveReference;
  final String? flutterwavePaymentUrl;
  final String? escrowStatus;
  final CardInfoModel? cardInfo;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? receiptUrl;
  final DateTime? paymentDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final double? lateFeeAmount;
  final DateTime? lateFeeTriggeredAt;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.id,
    this.orderId,
    this.contractId,
    this.buyerId,
    this.sellerId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.paymentStatus,
    this.status,
    this.invoiceNumber,
    this.invoiceReference,
    this.description,
    this.relatedProduct,
    this.reference,
    this.flutterwaveReference,
    this.flutterwavePaymentUrl,
    this.escrowStatus,
    this.cardInfo,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.receiptUrl,
    this.paymentDate,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.lateFeeAmount,
    this.lateFeeTriggeredAt,
    this.metadata,
  });

  /// Check if payment is successful
  bool get isCompleted {
    final current = (status ?? paymentStatus)?.toUpperCase();
    return current == 'COMPLETED' || current == 'SUCCEEDED';
  }

  /// Check if payment failed
  bool get isFailed {
    final current = (status ?? paymentStatus)?.toUpperCase();
    return current == 'FAILED';
  }

  /// Check if payment is pending
  bool get isPending {
    final current = (status ?? paymentStatus)?.toUpperCase();
    return current == 'PENDING' ||
        current == 'INITIATED' ||
        current == 'PROCESSING';
  }

  /// Check if payment is refunded
  bool get isRefunded {
    final current = (status ?? paymentStatus)?.toUpperCase();
    return current == 'REFUNDED';
  }

  /// Check if payment is disputed
  bool get isDisputed {
    final current = (status ?? paymentStatus)?.toUpperCase();
    return current == 'DISPUTED';
  }

  /// Check if payment is overdue
  bool get isOverdue =>
      dueDate != null && isPending && DateTime.now().isAfter(dueDate!);

  /// Display status text
  String get statusText {
    final current = (status ?? paymentStatus)?.toUpperCase();
    switch (current) {
      case 'COMPLETED':
      case 'SUCCEEDED':
        return 'Payment Successful';
      case 'PROCESSING':
        return 'Processing...';
      case 'INITIATED':
        return 'Awaiting Payment';
      case 'PENDING':
        return 'Pending';
      case 'FAILED':
        return 'Payment Failed';
      case 'REFUNDED':
        return 'Refunded';
      case 'DISPUTED':
        return 'Under Dispute';
      default:
        return 'Unknown';
    }
  }

  /// Display payment method text
  String get paymentMethodText {
    switch (paymentMethod) {
      case 'FULL_UPFRONT':
        return 'Full Payment Upfront';
      case 'PARTIAL_DEPOSIT':
        return 'Deposit Required';
      case 'ON_DELIVERY':
        return 'Pay on Delivery';
      case 'INSTALLMENT':
        return 'Installment Plan';
      case 'ESCROW':
        return 'Escrow Fund Hold';
      default:
        return 'Unknown';
    }
  }

  /// Format amount as currency string
  String get formattedAmount {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format amount status text
  String get escrowStatusText {
    switch (escrowStatus?.toUpperCase()) {
      case 'HELD':
        return 'Held in Escrow';
      case 'RELEASED':
        return 'Released';
      case 'REFUNDED':
        return 'Refunded';
      case 'DISPUTED':
        return 'Disputed';
      case 'CREATED':
        return 'Created';
      default:
        return 'No Escrow';
    }
  }

  /// Get currency symbol
  String _getCurrencySymbol(String cur) {
    switch (cur.toUpperCase()) {
      case 'KES':
        return 'Ksh ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'ZAR':
        return 'R ';
      case 'UGX':
        return 'UGX ';
      case 'TZS':
        return 'Tsh ';
      default:
        return '$cur ';
    }
  }

  /// Days until payment is due
  int get daysUntilDue {
    if (dueDate == null) return 0;
    final now = DateTime.now();
    return dueDate!.difference(now).inDays;
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

/// Escrow Model for funds held
@JsonSerializable()
class EscrowModel {
  final String id;
  final String paymentId;
  final double amount;
  final String currency;
  final String
      status; // CREATED, FUNDED, HELD, RELEASED, REFUNDED, DISPUTED, RESOLVED
  final int holdingPeriodDays;
  final double holdingFeePercentage;
  final Map<String, dynamic>
      conditionsMet; // {DELIVERY_PROOF, QUALITY_APPROVAL, BUYER_SIGNOFF}
  final DateTime? autoReleaseDate;
  final DateTime? releasedAt;
  final DateTime? refundedAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  EscrowModel({
    required this.id,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.holdingPeriodDays,
    required this.holdingFeePercentage,
    required this.conditionsMet,
    this.autoReleaseDate,
    this.releasedAt,
    this.refundedAt,
    required this.createdAt,
    this.metadata,
  });

  /// Check if escrow is held
  bool get isHeld => status == 'HELD';

  /// Check if escrow is released
  bool get isReleased => status == 'RELEASED';

  /// Check if escrow is disputed
  bool get isDisputed => status == 'DISPUTED';

  /// Count conditions met
  int get conditionsMetCount {
    int count = 0;
    for (var condition in conditionsMet.values) {
      if (condition is Map && condition['met'] == true) count++;
    }
    return count;
  }

  /// Check all conditions met
  bool get allConditionsMet => conditionsMetCount == 3;

  /// Display status text
  String get statusText {
    switch (status) {
      case 'CREATED':
        return 'Escrow Created';
      case 'FUNDED':
        return 'Funds Added';
      case 'HELD':
        return 'Funds In Escrow';
      case 'RELEASED':
        return 'Funds Released';
      case 'REFUNDED':
        return 'Refunded';
      case 'DISPUTED':
        return 'Under Dispute';
      case 'RESOLVED':
        return 'Dispute Resolved';
      default:
        return 'Unknown';
    }
  }

  factory EscrowModel.fromJson(Map<String, dynamic> json) =>
      _$EscrowModelFromJson(json);

  Map<String, dynamic> toJson() => _$EscrowModelToJson(this);
}

/// Request model for creating payment
class CreatePaymentRequest {
  final String contractId;
  final String paymentMethod;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final Map<String, dynamic>? metadata;

  CreatePaymentRequest({
    required this.contractId,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'contractId': contractId,
        'paymentMethod': paymentMethod,
        'amount': amount,
        'currency': currency,
        'dueDate': dueDate.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };
}

/// Response model for payment operations
@JsonSerializable()
class PaymentResponseDto {
  final bool success;
  final String message;
  final PaymentModel? data;
  final String? error;

  PaymentResponseDto({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory PaymentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseDtoToJson(this);
}

/// Card payment details
@JsonSerializable()
class CardInfoModel {
  final String brand;
  final String last4;
  final int? expMonth;
  final int? expYear;

  CardInfoModel({
    required this.brand,
    required this.last4,
    this.expMonth,
    this.expYear,
  });

  bool get isExpired {
    if (expMonth == null || expYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(expYear!, expMonth! + 1);
    return now.isAfter(expiry);
  }

  /// Format expiration date
  String get formattedExpiry {
    if (expMonth == null || expYear == null) return 'N/A';
    final yearString = expYear!.toString().padLeft(4, '0');
    final shortYear = yearString.length > 2
        ? yearString.substring(yearString.length - 2)
        : yearString;
    return '${expMonth!.toString().padLeft(2, '0')}/$shortYear';
  }

  String get displayCard => '$brand •••• $last4';

  factory CardInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CardInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardInfoModelToJson(this);
}

/// Payment request DTO models

/// Create payment request
class CreatePaymentRequestModel {
  final String orderId;
  final double amount;
  final String currency;
  final String paymentMethodId;
  final String? description;

  CreatePaymentRequestModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.paymentMethodId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'paymentMethodId': paymentMethodId,
        'description': description,
      };
}

/// Confirm payment request (for 3D Secure)
class ConfirmPaymentRequestModel {
  final String paymentIntentId;
  final String paymentMethodId;

  ConfirmPaymentRequestModel({
    required this.paymentIntentId,
    required this.paymentMethodId,
  });

  Map<String, dynamic> toJson() => {
        'paymentIntentId': paymentIntentId,
        'paymentMethodId': paymentMethodId,
      };
}

/// Refund payment request
class RefundPaymentRequestModel {
  final String reason;
  final double? amount; // Optional for partial refunds

  RefundPaymentRequestModel({
    required this.reason,
    this.amount,
  });

  Map<String, dynamic> toJson() => {
        'reason': reason,
        if (amount != null) 'amount': amount,
      };
}

/// Payment history response with pagination
@JsonSerializable()
class PaymentHistoryResponseModel {
  final List<PaymentModel> payments;
  final PaymentPaginationModel pagination;

  PaymentHistoryResponseModel({
    required this.payments,
    required this.pagination,
  });

  factory PaymentHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryResponseModelToJson(this);
}

/// Pagination metadata
@JsonSerializable()
class PaymentPaginationModel {
  final int page;
  final int limit;
  final int total;

  PaymentPaginationModel({
    required this.page,
    required this.limit,
    required this.total,
  });

  get hasMore => (page * limit) < total;

  factory PaymentPaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentPaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentPaginationModelToJson(this);
}
