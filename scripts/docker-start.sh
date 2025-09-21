#!/bin/bash

# Docker Compose startup script for Skippy Mastra

set -e

echo "🚀 Starting Skippy Mastra Docker Environment"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.example to .env and configure your environment variables."
    exit 1
fi

# Check for required environment variables
if ! grep -q "OPENAI_API_KEY" .env || grep -q "your_openai_api_key_here" .env; then
    echo "⚠️  Warning: OPENAI_API_KEY not configured in .env file"
    echo "Please add your OpenAI API key to continue."
    exit 1
fi

# Parse command line arguments
PROFILE=""
BUILD_FLAG=""
DETACHED=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --prod|--production)
            PROFILE="--profile production"
            echo "📦 Running in production mode"
            shift
            ;;
        --build)
            BUILD_FLAG="--build"
            echo "🔨 Forcing rebuild of images"
            shift
            ;;
        -d|--detach)
            DETACHED="-d"
            echo "🔄 Running in detached mode"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --prod, --production  Run with production profile"
            echo "  --build              Force rebuild of Docker images"
            echo "  -d, --detach         Run in detached mode"
            echo "  --help               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Pull latest images
echo "📥 Pulling latest images..."
docker-compose pull chroma

# Build and start services
if [ -n "$PROFILE" ]; then
    # Production mode with both compose files
    echo "🚀 Starting services in production mode..."
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up $BUILD_FLAG $DETACHED $PROFILE
else
    # Development mode
    echo "🚀 Starting services in development mode..."
    docker-compose up $BUILD_FLAG $DETACHED
fi

if [ -z "$DETACHED" ]; then
    echo "✅ Services are running. Press Ctrl+C to stop."
else
    echo "✅ Services started in background."
    echo ""
    echo "📊 Service URLs:"
    echo "  - Mastra Playground: http://localhost:4112/"
    echo "  - Mastra API: http://localhost:4112/api"
    echo "  - ChromaDB: http://localhost:8000"
    echo ""
    echo "📝 Useful commands:"
    echo "  - View logs: docker-compose logs -f"
    echo "  - Stop services: docker-compose down"
    echo "  - View status: docker-compose ps"
fi