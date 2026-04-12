#!/bin/bash

# Messaging API Integration Tests
# Tests core messaging endpoints with realistic scenarios

BASE_URL="http://localhost:3000/api"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Mock tokens (in real tests, use actual JWT tokens from auth)
USER1_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
USER2_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

test_endpoint() {
  local name=$1
  local method=$2
  local endpoint=$3
  local token=$4
  local data=$5
  local expected_code=$6

  echo -e "${YELLOW}Testing: $name${NC}"

  if [ "$method" == "GET" ]; then
    response=$(curl -s -w "\n%{http_code}" \
      -X GET "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $token" \
      -H "Content-Type: application/json")
  elif [ "$method" == "POST" ]; then
    response=$(curl -s -w "\n%{http_code}" \
      -X POST "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $token" \
      -H "Content-Type: application/json" \
      -d "$data")
  elif [ "$method" == "PUT" ]; then
    response=$(curl -s -w "\n%{http_code}" \
      -X PUT "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $token" \
      -H "Content-Type: application/json" \
      -d "$data")
  elif [ "$method" == "DELETE" ]; then
    response=$(curl -s -w "\n%{http_code}" \
      -X DELETE "$BASE_URL$endpoint" \
      -H "Authorization: Bearer $token" \
      -H "Content-Type: application/json")
  fi

  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')

  if [ "$http_code" == "$expected_code" ]; then
    echo -e "${GREEN}✓ PASSED${NC} (HTTP $http_code)"
    ((PASSED++))
  else
    echo -e "${RED}✗ FAILED${NC} (Expected $expected_code, got $http_code)"
    echo "Response: $body"
    ((FAILED++))
  fi
  echo ""
}

# ==================== TEST CASES ====================

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}MESSAGING API INTEGRATION TESTS${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# 1. Send a message
test_endpoint \
  "Send message to another user" \
  "POST" \
  "/messages" \
  "$USER1_TOKEN" \
  '{
    "recipientId": "user-2",
    "content": "Hello, how are you?"
  }' \
  "201"

# 2. Get conversations
test_endpoint \
  "Get all conversations for user" \
  "GET" \
  "/messages/conversations?page=1&limit=20" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 3. Get conversation messages
test_endpoint \
  "Get messages with specific user (mark as read)" \
  "GET" \
  "/messages/conversations/user-2?page=1&limit=50" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 4. Send message with order context
test_endpoint \
  "Send message related to an order" \
  "POST" \
  "/messages" \
  "$USER1_TOKEN" \
  '{
    "recipientId": "user-2",
    "orderId": "order-1",
    "content": "Can we expedite this order?",
    "messageType": "text"
  }' \
  "201"

# 5. Get conversation by order ID
test_endpoint \
  "Get conversation for specific order" \
  "GET" \
  "/messages/orders/order-1" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 6. Mark messages as read
test_endpoint \
  "Mark multiple messages as read" \
  "POST" \
  "/messages/read/mark" \
  "$USER1_TOKEN" \
  '{
    "messageIds": ["msg-1", "msg-2", "msg-3"]
  }' \
  "200"

# 7. Mark conversation as read
test_endpoint \
  "Mark entire conversation as read" \
  "POST" \
  "/messages/conversations/user-2/read" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 8. Get unread count
test_endpoint \
  "Get unread message count" \
  "GET" \
  "/messages/unread/count" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 9. Update message (within 5 minutes)
test_endpoint \
  "Update message content" \
  "PUT" \
  "/messages/msg-1" \
  "$USER1_TOKEN" \
  '{
    "content": "Updated: Hello, how are you doing?"
  }' \
  "200"

# 10. Delete message
test_endpoint \
  "Delete/soft delete a message" \
  "DELETE" \
  "/messages/msg-1" \
  "$USER1_TOKEN" \
  "" \
  "204"

# 11. Search messages in conversation
test_endpoint \
  "Search messages in conversation" \
  "GET" \
  "/messages/conversations/user-2/search?q=hello&limit=20" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 12. Get conversation message count
test_endpoint \
  "Get total message count for conversation" \
  "GET" \
  "/messages/conversations/user-2/count" \
  "$USER1_TOKEN" \
  "" \
  "200"

# 13. Security test - try to message yourself (should fail)
test_endpoint \
  "Security: Cannot message yourself" \
  "POST" \
  "/messages" \
  "$USER1_TOKEN" \
  '{
    "recipientId": "user-1",
    "content": "Message to myself"
  }' \
  "400"

# 14. Security test - try to access unauthorized order
test_endpoint \
  "Security: Cannot access unauthorized order" \
  "GET" \
  "/messages/orders/unauthorized-order" \
  "$USER1_TOKEN" \
  "" \
  "403"

# 15. Paginated conversations
test_endpoint \
  "Get conversations with pagination" \
  "GET" \
  "/messages/conversations?page=2&limit=10" \
  "$USER1_TOKEN" \
  "" \
  "200"

# ==================== LOAD TESTING ====================

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}LOAD TESTING - Bulk message sending${NC}"
echo -e "${YELLOW}========================================${NC}\n"

echo "Sending 50 messages in rapid succession..."
load_test_start=$(date +%s%N | cut -b1-13)

for i in {1..50}; do
  curl -s -X POST "$BASE_URL/messages" \
    -H "Authorization: Bearer $USER1_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"recipientId\": \"user-2\",
      \"content\": \"Load test message $i\"
    }" > /dev/null
  
  if [ $((i % 10)) -eq 0 ]; then
    echo "  $i messages sent..."
  fi
done

load_test_end=$(date +%s%N | cut -b1-13)
load_test_duration=$((load_test_end - load_test_start))

echo -e "${GREEN}Load test completed in ${load_test_duration}ms${NC}"
echo ""

# ==================== TEST SUMMARY ====================

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}TEST SUMMARY${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo -e "Total: $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
fi
