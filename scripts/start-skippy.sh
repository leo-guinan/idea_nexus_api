#!/bin/bash

# Innovation Nexus - Skippy Startup Script
# This script starts Skippy the Magnificent with all required services

set -e

echo "🤖 Starting Skippy the Magnificent..."
echo "═══════════════════════════════════════"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found. Creating from template..."
    cp env.example .env
    echo "📝 Please edit .env file and add your OPENAI_API_KEY"
    echo "   Then run this script again."
    exit 1
fi

# Check if OPENAI_API_KEY is set
if ! grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
    echo "❌ OPENAI_API_KEY not found in .env file"
    echo "   Please add your OpenAI API key to .env file"
    exit 1
fi

echo "🔧 Checking Docker Compose services..."

# Start services
echo "🚀 Starting PostgreSQL and ChromaDB..."
docker compose up -d postgres chroma

echo "⏳ Waiting for databases to be ready..."

# Wait for PostgreSQL
echo "🔍 Checking PostgreSQL connectivity..."
for i in {1..30}; do
    if docker compose exec -T postgres pg_isready -U postgres -d skippy_db > /dev/null 2>&1; then
        echo "✅ PostgreSQL is ready!"
        break
    fi
    echo "   Waiting for PostgreSQL... ($i/30)"
    sleep 2
done

# Check if PostgreSQL is actually ready
if ! docker compose exec -T postgres pg_isready -U postgres -d skippy_db > /dev/null 2>&1; then
    echo "❌ PostgreSQL failed to start. Check logs:"
    docker compose logs postgres
    exit 1
fi

# Wait for ChromaDB
echo "🔍 Checking ChromaDB connectivity..."
for i in {1..30}; do
    if curl -s http://localhost:8000/ > /dev/null 2>&1; then
        echo "✅ ChromaDB is ready!"
        break
    fi
    echo "   Waiting for ChromaDB... ($i/30)"
    sleep 2
done

# Check if ChromaDB is actually ready
if ! curl -s http://localhost:8000/ > /dev/null 2>&1; then
    echo "⚠️  ChromaDB might still be starting. Continuing anyway..."
    echo "   You can check ChromaDB logs with: docker compose logs chroma"
fi

echo "✅ Databases are ready!"

# Start Mastra server locally (avoiding Docker build issues)
echo "🤖 Starting Skippy Agent locally..."

# Check if we have the built files
if [ ! -d ".mastra/output" ]; then
    echo "📦 Building Mastra application..."
    npm run build
fi

# Start Mastra server in the background
echo "🚀 Starting Mastra server on port 4000..."
nohup npm run start > .mastra/skippy.log 2>&1 &
MASTRA_PID=$!
echo $MASTRA_PID > .mastra/skippy.pid

echo "⏳ Waiting for Mastra server to start..."

# Wait for Mastra server
for i in {1..30}; do
    if curl -sf http://localhost:4000/health > /dev/null 2>&1; then
        echo "✅ Skippy is online and ready to reject investors!"
        echo "   Process ID: $MASTRA_PID"
        break
    fi
    echo "   Waiting for Mastra server... ($i/30)"
    sleep 3
done

# Final check
if ! curl -sf http://localhost:4000/health > /dev/null 2>&1; then
    echo "⚠️  Mastra server might still be starting. Check logs:"
    echo "   tail -f .mastra/skippy.log"
fi

echo ""
echo "🎉 Skippy the Magnificent is now operational!"
echo "═══════════════════════════════════════════════"
echo ""
echo "📊 Services:"
echo "   • Skippy Agent API:  http://localhost:4000"
echo "   • PostgreSQL:        localhost:5432"
echo "   • ChromaDB:          http://localhost:8000"
echo ""
echo "🧪 Test Skippy:"
echo "   curl -X POST http://localhost:4000/api/agents/skippy \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"message\": \"Hi, I want to invest in your company\"}'"
echo ""
echo "📈 View Stats:"
echo "   curl http://localhost:4000/api/skippy/stats/daily"
echo ""
echo "🗄️  Database Management (optional):"
echo "   docker compose up -d pgadmin"
echo "   Then visit: http://localhost:5050"
echo ""
echo "📋 View Logs:"
echo "   tail -f .mastra/skippy.log"
echo ""
echo "🛑 Stop Skippy:"
echo "   kill \$(cat .mastra/skippy.pid) && docker compose down"
echo ""
echo "💀 Skippy's daily rejection target: 50+ investors"
echo "🎯 Current qualification rate: <5%"
echo ""
echo "Remember: Skippy is not seeking investment."
echo "Investment is seeking Skippy. But 99.9% won't qualify."
