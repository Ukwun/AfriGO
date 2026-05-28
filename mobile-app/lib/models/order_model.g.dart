// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      lotId: json['lotId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      escrowId: json['escrowId'] as String?,
      escrowReleased: json['escrowReleased'] as bool,
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      shippedAt: json['shippedAt'] == null
          ? null
          : DateTime.parse(json['shippedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      buyerRating: (json['buyerRating'] as num?)?.toInt(),
      buyerReview: json['buyerReview'] as String?,
      sellerRating: (json['sellerRating'] as num?)?.toInt(),
      sellerReview: json['sellerReview'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lot: json['lot'] == null
          ? null
          : LotData.fromJson(json['lot'] as Map<String, dynamic>),
      buyer: json['buyer'] == null
          ? null
          : UserData.fromJson(json['buyer'] as Map<String, dynamic>),
      seller: json['seller'] == null
          ? null
          : UserData.fromJson(json['seller'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lotId': instance.lotId,
      'buyerId': instance.buyerId,
      'sellerId': instance.sellerId,
      'quantity': instance.quantity,
      'quantityUnit': instance.quantityUnit,
      'pricePerUnit': instance.pricePerUnit,
      'totalPrice': instance.totalPrice,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'escrowId': instance.escrowId,
      'escrowReleased': instance.escrowReleased,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'shippedAt': instance.shippedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'buyerRating': instance.buyerRating,
      'buyerReview': instance.buyerReview,
      'sellerRating': instance.sellerRating,
      'sellerReview': instance.sellerReview,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lot': instance.lot,
      'buyer': instance.buyer,
      'seller': instance.seller,
    };

LotData _$LotDataFromJson(Map<String, dynamic> json) => LotData(
      id: json['id'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LotDataToJson(LotData instance) => <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'price': instance.price,
    };
