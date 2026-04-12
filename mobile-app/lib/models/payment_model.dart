import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

/// Payment model for Stripe payment processing
@JsonSerializable()
class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String currency;
  final String
      status; // pending, processing, succeeded, failed, cancelled, refunded
  final String escrowStatus; // pending, held, released, refunded
  final String? paymentMethod;
  final CardInfoModel? cardInfo;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final String? failureReason;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.escrowStatus,
    this.paymentMethod,
    this.cardInfo,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.receiptUrl,
    required this.createdAt,
    this.paidAt,
    this.refundedAt,
    this.failureReason,
  });

  /// Check if payment is successful
  bool get isSucceeded => status == 'succeeded';

  /// Check if payment failed
  bool get isFailed => status == 'failed';

  /// Check if payment is pending
  bool get isPending => status == 'pending' || status == 'processing';

  /// Check if payment is refunded
  bool get isRefunded => status == 'refunded';

  /// Check if escrow is held
  bool get isEscrowHeld => escrowStatus == 'held';

  /// Display status text
  String get statusText {
    switch (status) {
      case 'succeeded':
        return 'Payment Successful';
      case 'processing':
        return 'Processing...';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Payment Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  /// Display escrow status text
  String get escrowStatusText {
    switch (escrowStatus) {
      case 'pending':
        return 'Pending Escrow';
      case 'held':
        return 'In Escrow';
      case 'released':
        return 'Funds Released';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  /// Format amount as currency string
  String get formattedAmount => '\$$amount';

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}

/// Card information model
@JsonSerializable()
class CardInfoModel {
  final String? brand; // visa, mastercard, amex, discover
  final String? last4;
  @JsonKey(name: 'expiryMonth')
  final int? expMonth;
  @JsonKey(name: 'expiryYear')
  final int? expYear;

  CardInfoModel({
    this.brand,
    this.last4,
    this.expMonth,
    this.expYear,
  });

  /// Display card brand icon
  String get brandIcon {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return '💳'; // 💳 or use actual visa logo
      case 'mastercard':
        return '💳';
      case 'amex':
        return '💳';
      case 'discover':
        return '💳';
      default:
        return '💳';
    }
  }

  /// Display masked card
  String get displayCard {
    if (last4 != null && brand != null) {
      return '${brand!.toUpperCase()} ••••$last4';
    }
    return 'Unknown Card';
  }

  /// Check if card is expired
  bool get isExpired {
    if (expYear == null || expMonth == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(expYear!, expMonth! + 1);
    return now.isAfter(expiry);
  }

  /// Format expiration date
  String get formattedExpiry {
    if (expMonth == null || expYear == null) return 'N/A';
    return '${expMonth!.toString().padLeft(2, '0')}/${expYear!.toString().substring(2)}';
  }

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
