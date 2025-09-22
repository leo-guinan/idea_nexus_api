#!/bin/bash

# Deployment script for Mastra API
# This script pulls the latest image and restarts the container

set -e

echo "🚀 Deploying Mastra API..."

# Pull the latest image from GitHub Container Registry
echo "📦 Pulling latest image..."
docker pull ghcr.io/leo-guinan/idea_nexus_api:latest

# Stop and remove existing container if it exists
echo "🛑 Stopping existing container..."
docker compose down || true

# Start the new container
echo "🔄 Starting new container..."
docker compose up -d

# Wait for health check
echo "⏳ Waiting for health check..."
sleep 10

# Check if container is running
if docker ps | grep -q mastra-api; then
    echo "✅ Deployment successful!"
    echo "🔍 Container status:"
    docker ps | grep mastra-api

    # Test the API
    echo "🧪 Testing API endpoint..."
    if curl -s -f http://localhost:4112/api > /dev/null; then
        echo "✅ API is responding!"
    else
        echo "❌ API is not responding. Check logs with: docker logs mastra-api"
    fi
else
    echo "❌ Deployment failed! Container is not running."
    echo "Check logs with: docker compose logs"
    exit 1
fi