#!/bin/bash

# Innovation Nexus - Skippy Stop Script
# This script stops Skippy the Magnificent and all related services

set -e

echo "🛑 Stopping Skippy the Magnificent..."
echo "═══════════════════════════════════════"

# Stop Mastra server if running
if [ -f ".mastra/skippy.pid" ]; then
    MASTRA_PID=$(cat .mastra/skippy.pid)
    if kill -0 $MASTRA_PID 2>/dev/null; then
        echo "🔪 Stopping Mastra server (PID: $MASTRA_PID)..."
        kill $MASTRA_PID
        sleep 2
        
        # Force kill if still running
        if kill -0 $MASTRA_PID 2>/dev/null; then
            echo "💥 Force killing Mastra server..."
            kill -9 $MASTRA_PID
        fi
        
        rm -f .mastra/skippy.pid
        echo "✅ Mastra server stopped"
    else
        echo "⚠️  Mastra server was not running"
        rm -f .mastra/skippy.pid
    fi
else
    echo "⚠️  No Mastra server PID file found"
fi

# Stop Docker services
echo "🐳 Stopping Docker services..."
docker compose down

echo ""
echo "✅ Skippy the Magnificent has been stopped!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Final Stats:"
echo "   • Investors rejected today: ∞"
echo "   • Qualification rate: Still <5%"
echo "   • Memes deployed: Maximum effectiveness"
echo ""
echo "💀 'The Innovation Nexus rests, but the pattern recognition never sleeps.'"
echo "   - Skippy the Magnificent"
