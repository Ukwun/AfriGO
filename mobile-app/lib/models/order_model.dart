import 'package:json_annotation/json_annotation.dart';
import 'user_data_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  final String lotId;
  final String buyerId;
  final String sellerId;
  final double quantity;
  final String quantityUnit;
  final double pricePerUnit;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String? escrowId;
  final bool escrowReleased;
  final DateTime? confirmedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final int? buyerRating;
  final String? buyerReview;
  final int? sellerRating;
  final String? sellerReview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LotData? lot;
  final UserData? buyer;
  final UserData? seller;

  OrderModel({
    required this.id,
    required this.lotId,
    required this.buyerId,
    required this.sellerId,
    required this.quantity,
    required this.quantityUnit,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.escrowId,
    required this.escrowReleased,
    this.confirmedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
    this.buyerRating,
    this.buyerReview,
    this.sellerRating,
    this.sellerReview,
    required this.createdAt,
    required this.updatedAt,
    this.lot,
    this.buyer,
    this.seller,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    String? id,
    String? lotId,
    String? buyerId,
    String? sellerId,
    double? quantity,
    String? quantityUnit,
    double? pricePerUnit,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    String? escrowId,
    bool? escrowReleased,
    DateTime? confirmedAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
    int? buyerRating,
    String? buyerReview,
    int? sellerRating,
    String? sellerReview,
    DateTime? createdAt,
    DateTime? updatedAt,
    LotData? lot,
    UserData? buyer,
    UserData? seller,
  }) {
    return OrderModel(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      escrowId: escrowId ?? this.escrowId,
      escrowReleased: escrowReleased ?? this.escrowReleased,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
      buyerRating: buyerRating ?? this.buyerRating,
      buyerReview: buyerReview ?? this.buyerReview,
      sellerRating: sellerRating ?? this.sellerRating,
      sellerReview: sellerReview ?? this.sellerReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lot: lot ?? this.lot,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel &&
        other.id == id &&
        other.lotId == lotId &&
        other.buyerId == buyerId &&
        other.sellerId == sellerId &&
        other.quantity == quantity &&
        other.status == status;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class LotData {
  final String id;
  final String productName;
  final String? productImage;
  final double? price;

  LotData({
    required this.id,
    required this.productName,
    this.productImage,
    this.price,
  });

  factory LotData.fromJson(Map<String, dynamic> json) =>
      _$LotDataFromJson(json);

  Map<String, dynamic> toJson() => _$LotDataToJson(this);
}

// Order status enum
enum OrderStatus {
  pending,
  quoted,
  negotiating,
  confirmed,
  paid,
  shipped,
  delivered,
  completed,
  cancelled,
  disputed,
}

// Payment status enum
enum PaymentStatus {
  notPaid,
  escrowed,
  paid,
  refunded,
}
