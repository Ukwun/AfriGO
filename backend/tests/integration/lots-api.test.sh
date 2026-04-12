#!/bin/bash

# AfriGo Lots Module - Integration Tests
# Test all Lots API endpoints

BASE_URL="http://localhost:3000"
JWT_TOKEN="your_jwt_token_here"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "================================="
echo "AFRIGO LOTS MODULE - INTEGRATION TESTS"
echo "================================="
echo ""

# Test 1: Create a lot (POST /api/lots)
echo "Test 1: Create a new lot"
curl -X POST "$BASE_URL/api/lots" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "productName": "Premium Maize",
    "quantity": 1000,
    "quantityUnit": "kg",
    "pricePerUnit": 0.75,
    "description": "High quality maize, fresh from the farm",
    "images": ["https://example.com/image1.jpg"],
    "pickupLocation": "Central Market, Nairobi",
    "latitude": -1.2865,
    "longitude": 36.8172,
    "category": "Grains",
    "certifications": ["Organic"]
  }' | jq .
echo ""

# Test 2: Get all lots (GET /api/lots)
echo "Test 2: Get all lots with pagination"
curl -X GET "$BASE_URL/api/lots?page=1&limit=20&sortBy=newest" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 3: Search lots by product name (GET /api/lots?productName=Maize)
echo "Test 3: Search lots by product name"
curl -X GET "$BASE_URL/api/lots?productName=Maize" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 4: Filter lots by price range
echo "Test 4: Filter lots by price range"
curl -X GET "$BASE_URL/api/lots?minPrice=0.5&maxPrice=1.0" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 5: Get single lot by ID
echo "Test 5: Get single lot by ID"
LOT_ID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" # Replace with real lot ID
curl -X GET "$BASE_URL/api/lots/$LOT_ID" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 6: Get lot by QR code
echo "Test 6: Get lot by QR code"
QR_CODE="abc123def456" # Replace with real QR code
curl -X GET "$BASE_URL/api/lots/qr/$QR_CODE" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 7: Update lot (PUT /api/lots/:id)
echo "Test 7: Update lot (seller only)"
curl -X PUT "$BASE_URL/api/lots/$LOT_ID" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 800,
    "pricePerUnit": 0.80,
    "description": "Updated description"
  }' | jq .
echo ""

# Test 8: Search lots by full-text search
echo "Test 8: Full-text search"
curl -X GET "$BASE_URL/api/lots/search/maize?limit=20" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 9: Get lots by location
echo "Test 9: Get lots by geographic location"
curl -X GET "$BASE_URL/api/lots/location/-1.2865/36.8172?radius=50" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 10: Get seller's lots
echo "Test 10: Get current seller's lots"
curl -X GET "$BASE_URL/api/lots/seller/me?page=1&limit=20" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 11: Verify lot (admin only)
echo "Test 11: Verify lot (admin only)"
curl -X POST "$BASE_URL/api/lots/$LOT_ID/verify" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"approved": true}' | jq .
echo ""

# Test 12: Delete lot (soft delete)
echo "Test 12: Delete lot"
curl -X DELETE "$BASE_URL/api/lots/$LOT_ID" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 13: Error handling - Lot not found
echo "Test 13: Error handling - Lot not found"
curl -X GET "$BASE_URL/api/lots/non-existent-id" \
  -H "Content-Type: application/json" | jq .
echo ""

# Test 14: Error handling - Unauthorized (missing JWT)
echo "Test 14: Error handling - Unauthorized (missing JWT)"
curl -X POST "$BASE_URL/api/lots" \
  -H "Content-Type: application/json" \
  -d '{"productName": "Test"}' | jq .
echo ""

# Test 15: Error handling - Invalid data validation
echo "Test 15: Error handling - Invalid data validation"
curl -X POST "$BASE_URL/api/lots" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"productName": ""}' | jq .
echo ""

# Test 16: Performance - Load test (multiple requests)
echo "Test 16: Performance - Load test"
for i in {1..10}; do
  curl -s -X GET "$BASE_URL/api/lots?page=1&limit=10" \
    -H "Content-Type: application/json" | jq '.total' &
done
wait
echo "Load test complete"
echo ""

echo "================================="
echo "All tests completed!"
echo "================================="
