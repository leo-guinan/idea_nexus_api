#!/bin/bash

# Production test script for Mastra API

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROD_URL="https://api.ideanexusventures.com"

echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Production API Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Testing: ${GREEN}$PROD_URL${NC}"
echo ""

# Test with curl options for production
CURL_OPTS="-k -s --connect-timeout 5 --max-time 30"

# Test 1: Basic connectivity
echo -e "${YELLOW}1. Testing API Connectivity...${NC}"
if curl $CURL_OPTS -f "$PROD_URL/api" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API is accessible${NC}"
    RESPONSE=$(curl $CURL_OPTS "$PROD_URL/api")
    echo "   Response: $RESPONSE"
else
    echo -e "${RED}✗ API is not accessible${NC}"
    echo "   Checking DNS..."
    nslookup api.ideanexusventures.com | grep -A2 "Name:"
    echo ""
    echo "   Trying with -k flag (ignore SSL)..."
    curl -k -v "$PROD_URL/api" 2>&1 | grep -E "(HTTP|SSL|Connected)"
    exit 1
fi
echo ""

# Test 2: List agents
echo -e "${YELLOW}2. Listing Available Agents...${NC}"
AGENTS=$(curl $CURL_OPTS "$PROD_URL/api/agents" | jq -r 'keys[]' 2>/dev/null)
if [ -n "$AGENTS" ]; then
    echo -e "${GREEN}✓ Agents found:${NC}"
    echo "$AGENTS" | sed 's/^/   - /'
else
    echo -e "${RED}✗ Could not list agents${NC}"
fi
echo ""

# Test 3: Weather Agent Test
echo -e "${YELLOW}3. Testing Weather Agent...${NC}"
WEATHER_RESPONSE=$(curl $CURL_OPTS -X POST "$PROD_URL/api/agents/weatherAgent/generate" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Weather in London?"}]}' \
  | jq -r '.text' 2>/dev/null | head -5)

if [ -n "$WEATHER_RESPONSE" ]; then
    echo -e "${GREEN}✓ Weather agent responded:${NC}"
    echo "$WEATHER_RESPONSE" | sed 's/^/   /'
else
    echo -e "${RED}✗ Weather agent did not respond${NC}"
fi
echo ""

# Test 4: Skippy Agent Test
echo -e "${YELLOW}4. Testing Skippy Agent...${NC}"
SKIPPY_RESPONSE=$(curl $CURL_OPTS -X POST "$PROD_URL/api/agents/skippyAgent/generate" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"I want to invest in your program"}]}' \
  | jq -r '.text' 2>/dev/null | head -5)

if [ -n "$SKIPPY_RESPONSE" ]; then
    echo -e "${GREEN}✓ Skippy agent responded:${NC}"
    echo "$SKIPPY_RESPONSE" | sed 's/^/   /'
else
    echo -e "${RED}✗ Skippy agent did not respond${NC}"
fi
echo ""

# Test 5: Health check
echo -e "${YELLOW}5. Testing Health Endpoint...${NC}"
HTTP_CODE=$(curl $CURL_OPTS -o /dev/null -w "%{http_code}" "$PROD_URL/api/health")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Health check passed (HTTP $HTTP_CODE)${NC}"
elif [ "$HTTP_CODE" = "404" ]; then
    echo -e "${YELLOW}⚠ Health endpoint not found (HTTP 404) - API may still be working${NC}"
else
    echo -e "${RED}✗ Health check failed (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"

# For local testing comparison
echo ""
echo -e "${YELLOW}To test locally, run:${NC}"
echo "  ./test-agent.sh"
echo ""
echo -e "${YELLOW}To test a custom URL:${NC}"
echo "  ./test-agent.sh https://your-api-url.com"