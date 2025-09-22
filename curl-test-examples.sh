#!/bin/bash

# Curl examples for testing Mastra API agents
# Use these commands to test the API once deployed

echo "================================"
echo "Mastra API - Curl Test Examples"
echo "================================"
echo ""
echo "Replace API_URL with your actual API endpoint:"
echo "  Local:      http://localhost:4111"
echo "  Production: https://api.ideanexusventures.com"
echo ""

# Set this to your API URL
API_URL="${1:-http://localhost:4111}"

echo "Testing against: $API_URL"
echo ""
echo "================================"
echo ""

# 1. Simple API test
echo "1. Test if API is running:"
echo "curl $API_URL/api"
curl -s "$API_URL/api"
echo -e "\n"

# 2. List all agents
echo "2. List available agents:"
echo "curl $API_URL/api/agents | jq 'keys'"
curl -s "$API_URL/api/agents" | jq 'keys' 2>/dev/null || echo "(install jq for pretty output)"
echo -e "\n"

# 3. Weather Agent - Simple query
echo "3. Weather Agent - Simple Query:"
cat << 'EOF'
curl -X POST $API_URL/api/agents/weatherAgent/generate \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What is the weather in Paris?"}]}'
EOF
echo ""
echo "Response:"
curl -s -X POST "$API_URL/api/agents/weatherAgent/generate" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"What is the weather in Paris?"}]}' \
  | jq '.text' 2>/dev/null | head -10
echo -e "\n"

# 4. Skippy Agent - Investor screening
echo "4. Skippy Agent - Investor Screening:"
cat << 'EOF'
curl -X POST $API_URL/api/agents/skippyAgent/generate \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hi, I am looking to invest. What is your business model?"}]}'
EOF
echo ""
echo "Response:"
curl -s -X POST "$API_URL/api/agents/skippyAgent/generate" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hi, I am looking to invest. What is your business model?"}]}' \
  | jq '.text' 2>/dev/null | head -10
echo -e "\n"

# 5. Stream example (for real-time responses)
echo "5. Streaming Response Example:"
cat << 'EOF'
curl -X POST $API_URL/api/agents/weatherAgent/stream \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Give me a detailed weather report for Tokyo"}]}'
EOF
echo ""
echo "(Streaming responses will show real-time text generation)"
echo ""

# 6. Multi-turn conversation
echo "6. Multi-turn Conversation Example:"
cat << 'EOF'
curl -X POST $API_URL/api/agents/skippyAgent/generate \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "I want to learn about Innovation Nexus"},
      {"role": "assistant", "content": "Oh great, another tourist..."},
      {"role": "user", "content": "No, I understand consciousness transfer"}
    ]
  }'
EOF
echo ""

echo "================================"
echo "Production-specific curl options:"
echo "================================"
echo ""
echo "If SSL certificate issues (use -k to bypass):"
echo "curl -k https://api.ideanexusventures.com/api"
echo ""
echo "With timeout settings:"
echo "curl --connect-timeout 5 --max-time 30 $API_URL/api"
echo ""
echo "With verbose output for debugging:"
echo "curl -v $API_URL/api"
echo ""
echo "Save response to file:"
echo "curl -o response.json $API_URL/api/agents"
echo ""
echo "Follow redirects:"
echo "curl -L $API_URL/api"
echo ""