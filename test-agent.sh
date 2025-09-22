#!/bin/bash

# Test script for Mastra API agents

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# API endpoint (change to production URL when testing prod)
API_URL="${1:-http://localhost:4111}"

echo -e "${YELLOW}Testing Mastra API at: $API_URL${NC}"
echo ""

# Test 1: API Root
echo -e "${GREEN}Test 1: API Root${NC}"
curl -s "$API_URL/api"
echo -e "\n"

# Test 2: List Agents
echo -e "${GREEN}Test 2: List Available Agents${NC}"
curl -s "$API_URL/api/agents" | jq -r 'keys[]' 2>/dev/null || echo "Failed to list agents"
echo ""

# Test 3: Weather Agent
echo -e "${GREEN}Test 3: Weather Agent - San Francisco Weather${NC}"
curl -s -X POST "$API_URL/api/agents/weatherAgent/generate" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What is the weather in San Francisco?"}]}' \
  | jq -r '.text' 2>/dev/null | head -10 || echo "Weather agent test failed"
echo ""

# Test 4: Skippy Agent
echo -e "${GREEN}Test 4: Skippy Agent - Investor Interaction${NC}"
curl -s -X POST "$API_URL/api/agents/skippyAgent/generate" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hi, I am an investor interested in your accelerator. What is your TAM?"}]}' \
  | jq -r '.text' 2>/dev/null | head -15 || echo "Skippy agent test failed"
echo ""

# Test 5: Stream endpoint
echo -e "${GREEN}Test 5: Weather Agent - Stream Mode${NC}"
echo "Testing stream endpoint (first 500 chars):"
curl -s -X POST "$API_URL/api/agents/weatherAgent/stream" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Tell me about the weather in New York"}]}' \
  | head -c 500
echo -e "\n"

echo -e "${YELLOW}Tests completed!${NC}"