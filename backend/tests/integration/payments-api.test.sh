#!/bin/bash

# AfriGo Payment System Integration Tests
# Tests payment creation, confirmation, refunds, and webhook handling

set -e

BASE_URL="http://localhost:3000/api"
STRIPE_WEBHOOK_SECRET="whsec_test_secret"
AUTH_HEADER="Authorization: Bearer test_jwt_token_user_123"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run test
run_test() {
  local test_name=$1
  local method=$2
  local endpoint=$3
  local data=$4
  local expected_status=$5

  TESTS_RUN=$((TESTS_RUN + 1))
  echo -e "\n${YELLOW}[Test $TESTS_RUN] $test_name${NC}"

  if [ -z "$data" ]; then
    response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
      -H "Content-Type: application/json" \
      -H "$AUTH_HEADER")
  else
    response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
      -H "Content-Type: application/json" \
      -H "$AUTH_HEADER" \
      -d "$data")
  fi

  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | head -n-1)

  if [ "$http_code" -eq "$expected_status" ]; then
    echo -e "${GREEN}✓ PASSED${NC} (HTTP $http_code)"
    echo "Response: $body" | head -c 100
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗ FAILED${NC} (Expected $expected_status, got $http_code)"
    echo "Response: $body"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

echo "=========================================="
echo "AfriGo Payment Integration Tests"
echo "=========================================="

# Test 1: Get Stripe publishable key
run_test "Get Stripe publishable key" \
  "GET" \
  "/payments/config/publishable-key" \
  "" \
  200

# Test 2: Get user payment history (empty)
run_test "Get user payment history (empty)" \
  "GET" \
  "/payments?page=1&limit=20" \
  "" \
  200

# Test 3: Create payment with invalid order ID
run_test "Create payment - invalid order" \
  "POST" \
  "/payments" \
  '{
    "orderId": "invalid-order",
    "amount": 100,
    "currency": "USD",
    "paymentMethodId": "pm_test_123",
    "description": "Test payment"
  }' \
  404

# Test 4: Create payment without required fields
run_test "Create payment - missing fields" \
  "POST" \
  "/payments" \
  '{
    "amount": 100,
    "currency": "USD"
  }' \
  400

# Test 5: Create payment with negative amount
run_test "Create payment - negative amount" \
  "POST" \
  "/payments" \
  '{
    "orderId": "order-123",
    "amount": -50,
    "currency": "USD",
    "paymentMethodId": "pm_test_123"
  }' \
  400

# Test 6: Create payment with invalid currency
run_test "Create payment - invalid currency" \
  "POST" \
  "/payments" \
  '{
    "orderId": "order-123",
    "amount": 100,
    "currency": "INVALID",
    "paymentMethodId": "pm_test_123"
  }' \
  400

# Test 7: Get non-existent payment
run_test "Get non-existent payment" \
  "GET" \
  "/payments/nonexistent-payment" \
  "" \
  404

# Test 8: Confirm non-existent payment
run_test "Confirm non-existent payment" \
  "POST" \
  "/payments/nonexistent/confirm" \
  '{
    "paymentIntentId": "pi_test_123",
    "paymentMethodId": "pm_test_123"
  }' \
  404

# Test 9: Confirm payment - missing fields
run_test "Confirm payment - missing fields" \
  "POST" \
  "/payments/payment-123/confirm" \
  '{
    "paymentIntentId": "pi_test_123"
  }' \
  400

# Test 10: Refund non-existent payment
run_test "Refund non-existent payment" \
  "POST" \
  "/payments/nonexistent/refund" \
  '{
    "reason": "Customer request"
  }' \
  404

# Test 11: Refund payment - missing reason
run_test "Refund payment - missing reason" \
  "POST" \
  "/payments/payment-123/refund" \
  '{
    "amount": 50
  }' \
  400

# Test 12: Get order payment - invalid order
run_test "Get order payment - invalid order" \
  "GET" \
  "/payments/order/invalid-order" \
  "" \
  404

# Test 13: Release escrow - non-existent payment
run_test "Release escrow - non-existent payment" \
  "POST" \
  "/payments/nonexistent/release-escrow" \
  "" \
  404

# Test 14: Webhook - missing signature
run_test "Webhook - missing signature" \
  "POST" \
  "/webhooks/stripe" \
  '{
    "type": "payment_intent.succeeded",
    "data": {}
  }' \
  400

# Test 15: Webhook - invalid signature
run_test "Webhook - invalid signature" \
  "POST" \
  "/webhooks/stripe" \
  '{"type": "payment_intent.succeeded"}' \
  400

echo ""
echo "=========================================="
echo "Load Test: Rapid Payment Operations"
echo "=========================================="

# Simulate rapid payment operations (no actual Stripe calls)
echo "Executing 50 concurrent payment history requests..."
for i in {1..50}; do
  curl -s -X GET "$BASE_URL/payments?page=1&limit=5" \
    -H "Content-Type: application/json" \
    -H "$AUTH_HEADER" > /dev/null &
done
wait

echo -e "${GREEN}✓ All 50 requests completed${NC}"

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "Success Rate: $(echo "scale=2; ($TESTS_PASSED / $TESTS_RUN) * 100" | bc)%"
echo "=========================================="

# Exit with error if any test failed
if [ $TESTS_FAILED -gt 0 ]; then
  exit 1
fi
