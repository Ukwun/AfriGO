#!/bin/bash

# Trading API Integration Tests
# Tests for Orders and Quotes functionality

BASE_URL="http://localhost:3000"
BUYER_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJ1eWVyLTEyMyIsImVtYWlsIjoiYnV5ZXJAZXhhbXBsZS5jb20iLCJyb2xlIjoiYnV5ZXIifQ.test"
SELLER_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InNlbGxlci0xMjMiLCJlbWFpbCI6InNlbGxlckBleGFtcGxlLmNvbSIsInJvbGUiOiJzZWxsZXIifQ.test"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Helper function to run curl requests
run_test() {
  local test_name="$1"
  local method="$2"
  local endpoint="$3"
  local token="$4"
  local data="$5"
  local expected_status="$6"

  echo ""
  echo -e "${YELLOW}Testing: $test_name${NC}"

  local curl_cmd="curl -s -w '\n%{http_code}' -X $method '$BASE_URL$endpoint'"

  if [ -n "$token" ]; then
    curl_cmd="$curl_cmd -H 'Authorization: Bearer $token'"
  fi

  curl_cmd="$curl_cmd -H 'Content-Type: application/json'"

  if [ -n "$data" ]; then
    curl_cmd="$curl_cmd -d '$data'"
  fi

  local response=$(eval $curl_cmd)
  local http_code=$(echo "$response" | tail -n 1)
  local body=$(echo "$response" | sed '$d')

  if [ "$http_code" = "$expected_status" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - HTTP $http_code"
    ((PASSED++))
  else
    echo -e "${RED}✗ FAILED${NC} - Expected $expected_status, got $http_code"
    echo "Response: $body"
    ((FAILED++))
  fi
}

# ============ ORDER CREATION TESTS ============
echo ""
echo "========================================"
echo "ORDER CREATION TESTS"
echo "========================================"

run_test "Create order with valid data" \
  "POST" \
  "/trading/orders" \
  "$BUYER_TOKEN" \
  '{"lotId":"lot-123","quantity":10,"quantityUnit":"kg"}' \
  "201"

run_test "Create order without authentication" \
  "POST" \
  "/trading/orders" \
  "" \
  '{"lotId":"lot-123","quantity":10,"quantityUnit":"kg"}' \
  "401"

run_test "Create order with invalid lot" \
  "POST" \
  "/trading/orders" \
  "$BUYER_TOKEN" \
  '{"lotId":"invalid-lot","quantity":10,"quantityUnit":"kg"}' \
  "404"

run_test "Create order with zero quantity" \
  "POST" \
  "/trading/orders" \
  "$BUYER_TOKEN" \
  '{"lotId":"lot-123","quantity":0,"quantityUnit":"kg"}' \
  "400"

# ============ ORDER RETRIEVAL TESTS ============
echo ""
echo "========================================"
echo "ORDER RETRIEVAL TESTS"
echo "========================================"

run_test "Get buyer's orders" \
  "GET" \
  "/trading/orders/buyer" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Get seller's orders" \
  "GET" \
  "/trading/orders/seller" \
  "$SELLER_TOKEN" \
  "" \
  "200"

run_test "Get specific order by ID" \
  "GET" \
  "/trading/orders/order-123" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Get order - unauthorized user" \
  "GET" \
  "/trading/orders/order-123" \
  "invalid-token" \
  "" \
  "401"

# ============ ORDER STATUS TRANSITIONS ============
echo ""
echo "========================================"
echo "ORDER STATUS TRANSITIONS"
echo "========================================"

run_test "Confirm order (buyer)" \
  "POST" \
  "/trading/orders/order-123/confirm" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Confirm order - non-buyer fails" \
  "POST" \
  "/trading/orders/order-123/confirm" \
  "$SELLER_TOKEN" \
  "" \
  "403"

run_test "Cancel order (buyer)" \
  "POST" \
  "/trading/orders/order-123/cancel" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Ship order (seller)" \
  "POST" \
  "/trading/orders/order-123/ship" \
  "$SELLER_TOKEN" \
  "" \
  "200"

run_test "Deliver order (buyer)" \
  "POST" \
  "/trading/orders/order-123/deliver" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Complete order" \
  "POST" \
  "/trading/orders/order-123/complete" \
  "$BUYER_TOKEN" \
  "" \
  "200"

# ============ QUOTE TESTS ============
echo ""
echo "========================================"
echo "QUOTE TESTS"
echo "========================================"

run_test "Create quote (seller)" \
  "POST" \
  "/trading/quotes" \
  "$SELLER_TOKEN" \
  '{"orderId":"order-123","quotedPrice":9500,"quotedQuantity":10,"quantityUnit":"kg"}' \
  "201"

run_test "Create quote - non-seller fails" \
  "POST" \
  "/trading/quotes" \
  "$BUYER_TOKEN" \
  '{"orderId":"order-123","quotedPrice":9500,"quotedQuantity":10,"quantityUnit":"kg"}' \
  "403"

run_test "Get quotes for order" \
  "GET" \
  "/trading/quotes/orders/order-123" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Get received quotes (buyer)" \
  "GET" \
  "/trading/quotes/received" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Get sent quotes (seller)" \
  "GET" \
  "/trading/quotes/sent" \
  "$SELLER_TOKEN" \
  "" \
  "200"

run_test "Get specific quote" \
  "GET" \
  "/trading/quotes/quote-123" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Accept quote (buyer)" \
  "POST" \
  "/trading/quotes/quote-123/accept" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Reject quote (buyer)" \
  "POST" \
  "/trading/quotes/quote-123/reject" \
  "$BUYER_TOKEN" \
  '{"quoteId":"quote-123","rejectionReason":"Price too high"}' \
  "200"

run_test "Submit counter quote (buyer)" \
  "POST" \
  "/trading/quotes/quote-123/counter" \
  "$BUYER_TOKEN" \
  '{"originalQuoteId":"quote-123","quotedPrice":9000,"quotedQuantity":10,"quantityUnit":"kg"}' \
  "201"

# ============ RATING TESTS ============
echo ""
echo "========================================"
echo "RATING TESTS"
echo "========================================"

run_test "Rate order (buyer rates seller)" \
  "POST" \
  "/trading/orders/order-123/rate" \
  "$BUYER_TOKEN" \
  '{"rating":5,"review":"Excellent seller!"}' \
  "200"

run_test "Rate order (seller rates buyer)" \
  "POST" \
  "/trading/orders/order-123/rate" \
  "$SELLER_TOKEN" \
  '{"rating":4,"review":"Good buyer"}' \
  "200"

run_test "Rate order with invalid rating" \
  "POST" \
  "/trading/orders/order-123/rate" \
  "$BUYER_TOKEN" \
  '{"rating":10,"review":"Invalid rating"}' \
  "400"

# ============ FILTERING AND PAGINATION ============
echo ""
echo "========================================"
echo "FILTERING AND PAGINATION"
echo "========================================"

run_test "Get orders with status filter" \
  "GET" \
  "/trading/orders/buyer?statusEnum=confirmed" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Get orders with sorting" \
  "GET" \
  "/trading/orders/seller?sortBy=createdAt&order=DESC" \
  "$SELLER_TOKEN" \
  "" \
  "200"

run_test "Get orders with pagination" \
  "GET" \
  "/trading/orders/buyer?skip=0&take=10" \
  "$BUYER_TOKEN" \
  "" \
  "200"

run_test "Get quotes with pagination" \
  "GET" \
  "/trading/quotes/received?skip=0&take=20" \
  "$BUYER_TOKEN" \
  "" \
  "200"

# ============ ERROR SCENARIOS ============
echo ""
echo "========================================"
echo "ERROR SCENARIOS"
echo "========================================"

run_test "Get non-existent order" \
  "GET" \
  "/trading/orders/invalid-order" \
  "$BUYER_TOKEN" \
  "" \
  "404"

run_test "Get non-existent quote" \
  "GET" \
  "/trading/quotes/invalid-quote" \
  "$BUYER_TOKEN" \
  "" \
  "404"

run_test "Unauthorized quote access" \
  "GET" \
  "/trading/quotes/quote-123" \
  "invalid-token" \
  "" \
  "401"

run_test "Forbidden order access" \
  "POST" \
  "/trading/orders/order-123/ship" \
  "$BUYER_TOKEN" \
  "" \
  "403"

# ============ TEST SUMMARY ============
echo ""
echo "========================================"
echo "TEST SUMMARY"
echo "========================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
TOTAL=$((PASSED + FAILED))
echo "Total: $TOTAL"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some tests failed!${NC}"
  exit 1
fi
