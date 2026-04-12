import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/order_model.dart';
import 'package:mobile_app/models/quote_model.dart';

void main() {
  group('OrderModel', () {
    final mockOrderJson = {
      'id': 'order-123',
      'lotId': 'lot-123',
      'buyerId': 'buyer-123',
      'sellerId': 'seller-123',
      'quantity': 10.0,
      'quantityUnit': 'kg',
      'pricePerUnit': 10000.0,
      'totalPrice': 100000.0,
      'status': 'pending',
      'paymentStatus': 'not_paid',
      'escrowId': null,
      'escrowReleased': false,
      'confirmedAt': null,
      'paidAt': null,
      'shippedAt': null,
      'deliveredAt': null,
      'completedAt': null,
      'buyerRating': null,
      'buyerReview': null,
      'sellerRating': null,
      'sellerReview': null,
      'createdAt': '2024-01-15T10:30:00.000Z',
      'updatedAt': '2024-01-15T10:30:00.000Z',
      'lot': null,
      'buyer': null,
      'seller': null,
    };

    test('fromJson creates OrderModel correctly', () {
      final order = OrderModel.fromJson(mockOrderJson);

      expect(order.id, 'order-123');
      expect(order.lotId, 'lot-123');
      expect(order.buyerId, 'buyer-123');
      expect(order.sellerId, 'seller-123');
      expect(order.quantity, 10.0);
      expect(order.quantityUnit, 'kg');
      expect(order.pricePerUnit, 10000.0);
      expect(order.totalPrice, 100000.0);
      expect(order.status, 'pending');
      expect(order.paymentStatus, 'not_paid');
      expect(order.escrowReleased, false);
    });

    test('toJson serializes OrderModel correctly', () {
      final order = OrderModel.fromJson(mockOrderJson);
      final json = order.toJson();

      expect(json['id'], 'order-123');
      expect(json['status'], 'pending');
      expect(json['quantity'], 10.0);
      expect(json['totalPrice'], 100000.0);
    });

    test('copyWith creates new instance with updated fields', () {
      final order = OrderModel.fromJson(mockOrderJson);
      final updated = order.copyWith(status: 'confirmed');

      expect(order.status, 'pending');
      expect(updated.status, 'confirmed');
      expect(updated.id, order.id);
      expect(updated.quantity, order.quantity);
    });

    test('equality works correctly', () {
      final order1 = OrderModel.fromJson(mockOrderJson);
      final order2 = OrderModel.fromJson(mockOrderJson);
      final order3 = order1.copyWith(status: 'confirmed');

      expect(order1, order2);
      expect(order1, isNot(order3));
    });

    test('hashCode is consistent', () {
      final order = OrderModel.fromJson(mockOrderJson);
      expect(order.hashCode, order.hashCode);
    });

    test('fromJson with lot data', () {
      final jsonWithLot = {
        ...mockOrderJson,
        'lot': {
          'id': 'lot-123',
          'productName': 'Tomatoes',
          'productImage': null,
          'price': 10000.0,
        },
      };

      final order = OrderModel.fromJson(jsonWithLot);

      expect(order.lot, isNotNull);
      expect(order.lot?.productName, 'Tomatoes');
      expect(order.lot?.price, 10000.0);
    });

    test('fromJson with user data', () {
      final jsonWithUsers = {
        ...mockOrderJson,
        'buyer': {
          'id': 'buyer-123',
          'fullName': 'John Buyer',
          'phoneNumber': '+234123456789',
          'email': 'buyer@example.com',
        },
        'seller': {
          'id': 'seller-123',
          'fullName': 'Jane Seller',
          'phoneNumber': '+234987654321',
          'email': 'seller@example.com',
        },
      };

      final order = OrderModel.fromJson(jsonWithUsers);

      expect(order.buyer, isNotNull);
      expect(order.buyer?.fullName, 'John Buyer');
      expect(order.seller, isNotNull);
      expect(order.seller?.fullName, 'Jane Seller');
    });

    test('fromJson with complete timeline', () {
      final jsonWithTimeline = {
        ...mockOrderJson,
        'status': 'completed',
        'confirmedAt': '2024-01-15T11:00:00.000Z',
        'paidAt': '2024-01-15T11:15:00.000Z',
        'shippedAt': '2024-01-16T08:00:00.000Z',
        'deliveredAt': '2024-01-17T14:30:00.000Z',
        'completedAt': '2024-01-17T15:00:00.000Z',
      };

      final order = OrderModel.fromJson(jsonWithTimeline);

      expect(order.confirmedAt, isNotNull);
      expect(order.paidAt, isNotNull);
      expect(order.shippedAt, isNotNull);
      expect(order.deliveredAt, isNotNull);
      expect(order.completedAt, isNotNull);
    });

    test('fromJson with ratings and reviews', () {
      final jsonWithRatings = {
        ...mockOrderJson,
        'status': 'completed',
        'buyerRating': 4,
        'buyerReview': 'Good buyer, paid on time',
        'sellerRating': 5,
        'sellerReview': 'Excellent seller, fast delivery',
      };

      final order = OrderModel.fromJson(jsonWithRatings);

      expect(order.buyerRating, 4);
      expect(order.buyerReview, 'Good buyer, paid on time');
      expect(order.sellerRating, 5);
      expect(order.sellerReview, 'Excellent seller, fast delivery');
    });
  });

  group('QuoteModel', () {
    final mockQuoteJson = {
      'id': 'quote-123',
      'orderId': 'order-123',
      'lotId': 'lot-123',
      'fromUserId': 'seller-123',
      'toUserId': 'buyer-123',
      'quoteType': 'seller_quote',
      'quotedPrice': 9500.0,
      'quotedQuantity': 10.0,
      'quantityUnit': 'kg',
      'termsAndConditions': null,
      'notes': null,
      'deliveryLocation': null,
      'proposedDeliveryDate': null,
      'status': 'pending',
      'expiresAt': '2024-01-22T10:30:00.000Z',
      'isExpired': false,
      'acceptedAt': null,
      'rejectedAt': null,
      'rejectionReason': null,
      'counterQuoteId': null,
      'createdAt': '2024-01-15T10:30:00.000Z',
      'updatedAt': '2024-01-15T10:30:00.000Z',
      'fromUser': null,
      'toUser': null,
    };

    test('fromJson creates QuoteModel correctly', () {
      final quote = QuoteModel.fromJson(mockQuoteJson);

      expect(quote.id, 'quote-123');
      expect(quote.orderId, 'order-123');
      expect(quote.fromUserId, 'seller-123');
      expect(quote.toUserId, 'buyer-123');
      expect(quote.quotedPrice, 9500.0);
      expect(quote.quotedQuantity, 10.0);
      expect(quote.status, 'pending');
      expect(quote.isExpired, false);
    });

    test('toJson serializes QuoteModel correctly', () {
      final quote = QuoteModel.fromJson(mockQuoteJson);
      final json = quote.toJson();

      expect(json['id'], 'quote-123');
      expect(json['status'], 'pending');
      expect(json['quotedPrice'], 9500.0);
      expect(json['quotedQuantity'], 10.0);
    });

    test('copyWith creates new instance with updated fields', () {
      final quote = QuoteModel.fromJson(mockQuoteJson);
      final updated = quote.copyWith(status: 'accepted');

      expect(quote.status, 'pending');
      expect(updated.status, 'accepted');
      expect(updated.id, quote.id);
      expect(updated.quotedPrice, quote.quotedPrice);
    });

    test('equality works correctly', () {
      final quote1 = QuoteModel.fromJson(mockQuoteJson);
      final quote2 = QuoteModel.fromJson(mockQuoteJson);
      final quote3 = quote1.copyWith(status: 'accepted');

      expect(quote1, quote2);
      expect(quote1, isNot(quote3));
    });

    test('fromJson with user data', () {
      final jsonWithUsers = {
        ...mockQuoteJson,
        'fromUser': {
          'id': 'seller-123',
          'fullName': 'Jane Seller',
          'phoneNumber': '+234987654321',
          'email': 'seller@example.com',
        },
        'toUser': {
          'id': 'buyer-123',
          'fullName': 'John Buyer',
          'phoneNumber': '+234123456789',
          'email': 'buyer@example.com',
        },
      };

      final quote = QuoteModel.fromJson(jsonWithUsers);

      expect(quote.fromUser, isNotNull);
      expect(quote.fromUser?.fullName, 'Jane Seller');
      expect(quote.toUser, isNotNull);
      expect(quote.toUser?.fullName, 'John Buyer');
    });

    test('fromJson with counter quote reference', () {
      final jsonWithCounter = {
        ...mockQuoteJson,
        'counterQuoteId': 'counter-quote-456',
      };

      final quote = QuoteModel.fromJson(jsonWithCounter);

      expect(quote.counterQuoteId, 'counter-quote-456');
    });

    test('fromJson with acceptance', () {
      final jsonAccepted = {
        ...mockQuoteJson,
        'status': 'accepted',
        'acceptedAt': '2024-01-15T12:00:00.000Z',
      };

      final quote = QuoteModel.fromJson(jsonAccepted);

      expect(quote.status, 'accepted');
      expect(quote.acceptedAt, isNotNull);
    });

    test('fromJson with rejection', () {
      final jsonRejected = {
        ...mockQuoteJson,
        'status': 'rejected',
        'rejectedAt': '2024-01-15T12:00:00.000Z',
        'rejectionReason': 'Price too high',
      };

      final quote = QuoteModel.fromJson(jsonRejected);

      expect(quote.status, 'rejected');
      expect(quote.rejectionReason, 'Price too high');
      expect(quote.rejectedAt, isNotNull);
    });

    test('quoteType enum exists and can be used', () {
      expect(QuoteType.sellerQuote, isNotNull);
      expect(QuoteType.buyerCounterOffer, isNotNull);
      expect(QuoteType.negotiation, isNotNull);
    });

    test('quoteStatus enum exists and can be used', () {
      expect(QuoteStatus.pending, isNotNull);
      expect(QuoteStatus.accepted, isNotNull);
      expect(QuoteStatus.rejected, isNotNull);
      expect(QuoteStatus.expired, isNotNull);
      expect(QuoteStatus.countered, isNotNull);
    });
  });
}
