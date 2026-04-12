class OrderModel {
  final String id;
  final String buyerId;
  final String? buyerName;
  final String sellerId;
  final String? sellerName;
  final String lotId;
  final String productName;
  final double quantity;
  final String quantityUnit;
  final double pricePerUnit;
  final double totalPrice;
  final String status; // pending, confirmed, shipped, delivered, cancelled, disputed
  final String paymentStatus; // pending, paid, refunded
  final DateTime deliveryDate;
  final String shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    this.buyerName,
    required this.sellerId,
    this.sellerName,
    required this.lotId,
    required this.productName,
    required this.quantity,
    required this.quantityUnit,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.deliveryDate,
    required this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String?,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String?,
      lotId: json['lotId'] as String,
      productName: json['productName'] as String,
      quantity: double.parse(json['quantity'].toString()),
      quantityUnit: json['quantityUnit'] as String,
      pricePerUnit: double.parse(json['pricePerUnit'].toString()),
      totalPrice: double.parse(json['totalPrice'].toString()),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      deliveryDate: DateTime.parse(json['deliveryDate'] as String),
      shippingAddress: json['shippingAddress'] as String,
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'lotId': lotId,
      'productName': productName,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'deliveryDate': deliveryDate.toIso8601String(),
      'shippingAddress': shippingAddress,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    String? lotId,
    String? productName,
    double? quantity,
    String? quantityUnit,
    double? pricePerUnit,
    double? totalPrice,
    String? status,
    String? paymentStatus,
    DateTime? deliveryDate,
    String? shippingAddress,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      lotId: lotId ?? this.lotId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'OrderModel(id: $id, product: $productName, qty: $quantity, total: \$$totalPrice)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
import 'package:json_annotation/json_annotation.dart';

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
