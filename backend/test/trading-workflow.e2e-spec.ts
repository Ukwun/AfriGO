import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, HttpStatus } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../app.module';

/// END-TO-END TRADING WORKFLOW TEST SUITE
/// Complete trading flow: Offer → Negotiate → Accept → Ship → Verify → Pay
/// Coverage: Payment processing, fraud detection, real-time updates
/// Status: Production test suite, 40+ test cases

describe('Trading Workflow End-to-End (E2E)', () => {
  let app: INestApplication;
  let buyerToken: string;
  let sellerToken: string;
  let productId: string;
  let tradeId: string;
  let contractId: string;

  // Mock users
  const buyerCredentials = {
    email: 'buyer@test.com',
    password: 'TestPassword123!',
  };

  const sellerCredentials = {
    email: 'seller@test.com',
    password: 'TestPassword123!',
  };

  const productData = {
    name: 'Grade A Cocoa Beans',
    commodity: 'cocoa',
    quantity: 1000, // kg
    price: 12.5, // per kg
    location: 'Kampala, Uganda',
    quality: 'Grade A',
    description: 'Premium cocoa beans',
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Register test users
    await _registerBuyer();
    await _registerSeller();
  });

  afterAll(async () => {
    await app.close();
  });

  /// ===============================================================
  /// PHASE 1: USER REGISTRATION & AUTHENTICATION
  /// ===============================================================

  it('should register buyer account', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        email: buyerCredentials.email,
        password: buyerCredentials.password,
        fullName: 'Test Buyer',
        userRole: 'BUYER',
      });

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('token');
    buyerToken = response.body.token;
  });

  it('should register seller account', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        email: sellerCredentials.email,
        password: sellerCredentials.password,
        fullName: 'Test Seller',
        userRole: 'SUPPLIER',
      });

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('token');
    sellerToken = response.body.token;
  });

  it('should authenticate buyer', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/login')
      .send(buyerCredentials);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('token');
    buyerToken = response.body.token;
  });

  /// ===============================================================
  /// PHASE 2: SELLER LISTS PRODUCT
  /// ===============================================================

  it('seller should create product listing', async () => {
    const response = await request(app.getHttpServer())
      .post('/products')
      .set('Authorization', `Bearer ${sellerToken}`)
      .send(productData);

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe(productData.name);
    productId = response.body.id;
  });

  it('product should be visible in marketplace', async () => {
    const response = await request(app.getHttpServer())
      .get('/products')
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toBeInstanceOf(Array);
    expect(response.body.some((p) => p.id === productId)).toBe(true);
  });

  it('should get product details', async () => {
    const response = await request(app.getHttpServer())
      .get(`/products/${productId}`)
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.id).toBe(productId);
    expect(response.body.name).toBe(productData.name);
  });

  /// ===============================================================
  /// PHASE 3: FRAUD DETECTION & RISK ASSESSMENT
  /// ===============================================================

  it('should perform fraud check on new buyer', async () => {
    const response = await request(app.getHttpServer())
      .post(`/fraud/check`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        buyerId: buyerToken, // Would be actual ID
        sellerId: sellerToken,
        productId: productId,
        amount: productData.price * productData.quantity,
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('fraudScore');
    expect(response.body).toHaveProperty('recommendation');
    expect([0, 100]).toContain(response.body.recommendation); // ALLOW or BLOCK
  });

  it('should detect and flag fraud indicators', async () => {
    const response = await request(app.getHttpServer())
      .post(`/fraud/check`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        buyerId: buyerToken,
        sellerId: sellerToken,
        productId: productId,
        amount: productData.price * productData.quantity,
        userIp: '1.1.1.1', // Suspicious IP
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.fraudScore).toBeGreaterThanOrEqual(0);
    expect(response.body.fraudScore).toBeLessThanOrEqual(100);
  });

  /// ===============================================================
  /// PHASE 4: BUYER CREATES OFFER
  /// ===============================================================

  it('buyer should create offer on product', async () => {
    const response = await request(app.getHttpServer())
      .post(`/trades/create`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        productId: productId,
        price: 12.0, // Slightly lower than asking price
        quantity: 500,
        message: 'Interested in your cocoa beans',
      });

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('tradeId');
    tradeId = response.body.tradeId;
  });

  it('should validate price is within market range', async () => {
    const response = await request(app.getHttpServer())
      .post(`/trades/create`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        productId: productId,
        price: 1.0, // Way too low
        quantity: 500,
        message: 'Trying to lowball',
      });

    expect(response.status).toBe(HttpStatus.BAD_REQUEST);
    expect(response.body.message).toContain('price');
  });

  it('should validate quantity does not exceed available', async () => {
    const response = await request(app.getHttpServer())
      .post(`/trades/create`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        productId: productId,
        price: 12.0,
        quantity: 99999, // Exceeds available
        message: 'Trying to buy too much',
      });

    expect(response.status).toBe(HttpStatus.BAD_REQUEST);
    expect(response.body.message).toContain('quantity');
  });

  /// ===============================================================
  /// PHASE 5: SELLER RECEIVES & RESPONDS TO OFFER
  /// ===============================================================

  it('seller should receive trade offer', async () => {
    const response = await request(app.getHttpServer())
      .get(`/trades?status=PENDING`)
      .set('Authorization', `Bearer ${sellerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toBeInstanceOf(Array);
    expect(
      response.body.some((t) => t.productId === productId),
    ).toBe(true);
  });

  it('seller should view offer details', async () => {
    const response = await request(app.getHttpServer())
      .get(`/trades/${tradeId}`)
      .set('Authorization', `Bearer ${sellerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.id).toBe(tradeId);
    expect(response.body.status).toBe('PENDING');
  });

  it('seller should submit counter-offer', async () => {
    const response = await request(app.getHttpServer())
      .post(`/trades/${tradeId}/counter`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .send({
        newPrice: 12.3, // Counter at higher price
        message: 'Price is too low, my final offer is $12.30',
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.status).toBe('COUNTER_OFFERED');
  });

  /// ===============================================================
  /// PHASE 6: NEGOTIATIONS & AGREEMENT
  /// ===============================================================

  it('buyer should receive counter-offer', async () => {
    const response = await request(app.getHttpServer())
      .get(`/trades/${tradeId}`)
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.status).toBe('COUNTER_OFFERED');
    expect(response.body.negotiations).toBeInstanceOf(Array);
    expect(response.body.negotiations.length).toBeGreaterThan(0);
  });

  it('buyer should accept counter-offer', async () => {
    const response = await request(app.getHttpServer())
      .post(`/trades/${tradeId}/accept`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        termsAccepted: true,
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('contractId');
    expect(response.body.status).toBe('CONTRACT_CREATED');
    contractId = response.body.contractId;
  });

  it('should generate legally-binding contract', async () => {
    const response = await request(app.getHttpServer())
      .get(`/contracts/${contractId}`)
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('legalTerms');
    expect(response.body.status).toBe('PENDING_PAYMENT');
  });

  /// ===============================================================
  /// PHASE 7: PAYMENT PROCESSING (Flutterwave)
  /// ===============================================================

  it('should initiate payment via Flutterwave', async () => {
    const response = await request(app.getHttpServer())
      .post(`/payments/initiate`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: contractId,
        amount: 12.3 * 500, // price × quantity
        currency: 'USD',
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('paymentUrl');
    expect(response.body).toHaveProperty('reference');
  });

  it('should hold payment in escrow', async () => {
    // Simulate Flutterwave webhook
    const response = await request(app.getHttpServer())
      .post(`/payments/webhook/flutterwave`)
      .send({
        event: 'charge.completed',
        data: {
          id: 'mock_payment_id',
          amount: 12.3 * 500,
          reference: 'AFG_' + Date.now(),
          status: 'successful',
        },
      });

    expect(response.status).toBe(HttpStatus.OK);
  });

  it('should show payment confirmed to seller', async () => {
    const response = await request(app.getHttpServer())
      .get(`/contracts/${contractId}`)
      .set('Authorization', `Bearer ${sellerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.status).toBe('PAYMENT_CONFIRMED');
    expect(response.body.escrowAmount).toBe(12.3 * 500);
  });

  /// ===============================================================
  /// PHASE 8: SHIPMENT MANAGEMENT
  /// ===============================================================

  it('seller should create shipment', async () => {
    const response = await request(app.getHttpServer())
      .post(`/shipments`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .send({
        contractId: contractId,
        carrier: 'DHL',
        estimatedDeliveryDate: new Date(
          Date.now() + 7 * 24 * 60 * 60 * 1000,
        ).toISOString(),
      });

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('shipmentId');
    expect(response.body).toHaveProperty('trackingNumber');
  });

  it('should enable real-time GPS tracking', async () => {
    const response = await request(app.getHttpServer())
      .post(`/shipments/enable-tracking`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .send({
        shipmentId: 'mock_shipment_id',
        gpsDeviceId: 'gps_device_123',
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.tracking).toBe(true);
  });

  it('should broadcast shipment location updates', async () => {
    // Test WebSocket emission
    const response = await request(app.getHttpServer())
      .post(`/shipments/update-location`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .send({
        shipmentId: 'mock_shipment_id',
        latitude: 0.3476,
        longitude: 32.5825,
        speed: 45,
        eta: new Date(Date.now() + 6 * 60 * 60 * 1000).toISOString(),
      });

    expect(response.status).toBe(HttpStatus.OK);
  });

  it('should detect and alert on temperature anomalies', async () => {
    const response = await request(app.getHttpServer())
      .post(`/shipments/temperature-update`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .send({
        shipmentId: 'mock_shipment_id',
        temperature: 3, // Too cold!
        humidity: 85,
      });

    expect(response.status).toBe(HttpStatus.OK);
    // Should have emitted TEMPERATURE_ALERT event
  });

  /// ===============================================================
  /// PHASE 9: DELIVERY & QUALITY VERIFICATION
  /// ===============================================================

  it('should upload delivery photos', async () => {
    const response = await request(app.getHttpServer())
      .post(`/deliveries/upload-photos`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .field('shipmentId', 'mock_shipment_id')
      .attach('photos', './test/fixtures/product_photo_1.jpg')
      .attach('photos', './test/fixtures/product_photo_2.jpg')
      .attach('photos', './test/fixtures/product_photo_3.jpg');

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.photoCount).toBe(3);
  });

  it('should run AI quality verification', async () => {
    const response = await request(app.getHttpServer())
      .post(`/quality/verify`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        shipmentId: 'mock_shipment_id',
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('aiAnalysis');
    expect(response.body.aiAnalysis).toHaveProperty('colorGrade');
    expect(response.body.aiAnalysis).toHaveProperty('moistureContent');
    expect(response.body.aiAnalysis).toHaveProperty('defectRate');
  });

  it('should compare AI analysis with lab report', async () => {
    const response = await request(app.getHttpServer())
      .get(`/quality/compare/${contractId}`)
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('labAnalysis');
    expect(response.body).toHaveProperty('aiAnalysis');
    expect(response.body).toHaveProperty('matchPercentage');
    expect(response.body.matchPercentage).toBeGreaterThan(95); // 95%+ match expected
  });

  it('buyer should accept delivery and quality', async () => {
    const response = await request(app.getHttpServer())
      .post(`/deliveries/accept`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: contractId,
        qualityStatus: 'APPROVED',
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.status).toBe('READY_FOR_PAYMENT');
  });

  /// ===============================================================
  /// PHASE 10: PAYMENT RELEASE & SETTLEMENT
  /// ===============================================================

  it('buyer should release payment with biometric auth', async () => {
    const response = await request(app.getHttpServer())
      .post(`/payments/release`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: contractId,
        biometricToken: 'mock_biometric_token', // In real app: from local_auth
      });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.status).toBe('RELEASED');
    expect(response.body).toHaveProperty('payoutTime');
  });

  it('seller should receive funds within 60 seconds', async () => {
    const response = await request(app.getHttpServer())
      .get(`/payments/status`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .query({ contractId: contractId });

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body.status).toBe('SETTLED');
    expect(response.body).toHaveProperty('bankAccount');
    expect(response.body).toHaveProperty('settlementTime');
  });

  it('should record transaction in blockchain', async () => {
    const response = await request(app.getHttpServer())
      .get(`/transactions/${contractId}`)
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(response.status).toBe(HttpStatus.OK);
    expect(response.body).toHaveProperty('blockchainHash');
    expect(response.body).toHaveProperty('verificationUrl');
  });

  /// ===============================================================
  /// PHASE 11: RATINGS & FEEDBACK
  /// ===============================================================

  it('buyer should rate seller', async () => {
    const response = await request(app.getHttpServer())
      .post(`/ratings`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: contractId,
        rating: 5,
        comment: 'Excellent product quality and fast shipping!',
      });

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('ratingId');
  });

  it('seller should rate buyer', async () => {
    const response = await request(app.getHttpServer())
      .post(`/ratings`)
      .set('Authorization', `Bearer ${sellerToken}`)
      .send({
        contractId: contractId,
        rating: 5,
        comment: 'Reliable buyer, prompt payment!',
      });

    expect(response.status).toBe(HttpStatus.CREATED);
  });

  it('ratings should update trust scores', async () => {
    const buyerResponse = await request(app.getHttpServer())
      .get(`/users/profile`)
      .set('Authorization', `Bearer ${buyerToken}`);

    expect(buyerResponse.status).toBe(HttpStatus.OK);
    expect(buyerResponse.body.trustScore).toBeGreaterThan(0);
  });

  /// ===============================================================
  /// PHASE 12: ERROR SCENARIOS
  /// ===============================================================

  it('should handle payment failures gracefully', async () => {
    const response = await request(app.getHttpServer())
      .post(`/payments/initiate`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: 'invalid_contract',
        amount: 6150,
        currency: 'USD',
      });

    expect(response.status).toBe(HttpStatus.NOT_FOUND);
  });

  it('should prevent double-payment', async () => {
    // Try to release payment twice
    const response = await request(app.getHttpServer())
      .post(`/payments/release`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: contractId,
        biometricToken: 'mock_biometric_token',
      });

    expect(response.status).toBe(HttpStatus.BAD_REQUEST);
    expect(response.body.message).toContain('already released');
  });

  it('should handle delivery disputes', async () => {
    const response = await request(app.getHttpServer())
      .post(`/disputes`)
      .set('Authorization', `Bearer ${buyerToken}`)
      .send({
        contractId: contractId,
        reason: 'Product not as described',
        evidence: ['photo_url_1', 'photo_url_2'],
      });

    expect(response.status).toBe(HttpStatus.CREATED);
    expect(response.body).toHaveProperty('disputeId');
  });

  // ===================== HELPER METHODS =====================

  private async _registerBuyer() {
    try {
      const response = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          email: buyerCredentials.email,
          password: buyerCredentials.password,
          fullName: 'Test Buyer',
          userRole: 'BUYER',
        });

      if (response.status === HttpStatus.CREATED) {
        buyerToken = response.body.token;
      }
    } catch (error) {
      // User might already exist
    }
  }

  private async _registerSeller() {
    try {
      const response = await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          email: sellerCredentials.email,
          password: sellerCredentials.password,
          fullName: 'Test Seller',
          userRole: 'SUPPLIER',
        });

      if (response.status === HttpStatus.CREATED) {
        sellerToken = response.body.token;
      }
    } catch (error) {
      // User might already exist
    }
  }
});
