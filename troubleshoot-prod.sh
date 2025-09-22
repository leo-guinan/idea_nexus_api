#!/bin/bash

# Production troubleshooting script
# Run this on the production server to diagnose issues

echo "======================================"
echo "Mastra API Production Troubleshooting"
echo "======================================"
echo ""

# Get container ID
CONTAINER_ID=$(docker ps --filter "ancestor=ghcr.io/leo-guinan/idea_nexus_api:latest" -q)
echo "Container ID: $CONTAINER_ID"
echo ""

# 1. Check container health
echo "1. Container Health Status:"
docker inspect $CONTAINER_ID --format='{{json .State.Health}}' | jq '.'
echo ""

# 2. Test API from inside container
echo "2. Testing API from inside container:"
docker exec $CONTAINER_ID curl -s http://localhost:4112/api || echo "Failed to connect from inside container"
echo ""

# 3. Test health endpoint
echo "3. Testing health endpoint:"
docker exec $CONTAINER_ID curl -s http://localhost:4112/api/health || echo "Health endpoint not found (404)"
echo ""

# 4. Check if container can reach the API port
echo "4. Checking port 4112 inside container:"
docker exec $CONTAINER_ID sh -c "netstat -tuln | grep 4112 || ss -tuln | grep 4112" 2>/dev/null || echo "Port check failed"
echo ""

# 5. Check Traefik labels
echo "5. Traefik Labels on container:"
docker inspect $CONTAINER_ID --format='{{json .Config.Labels}}' | jq '. | to_entries[] | select(.key | startswith("traefik"))'
echo ""

# 6. Test from host to container
echo "6. Testing API from host to container:"
CONTAINER_IP=$(docker inspect $CONTAINER_ID --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "Container IP: $CONTAINER_IP"
curl -s http://$CONTAINER_IP:4112/api || echo "Failed to connect from host"
echo ""

# 7. Check container logs for errors
echo "7. Recent container logs:"
docker logs $CONTAINER_ID --tail 20
echo ""

# 8. Check environment variables
echo "8. Environment variables:"
docker exec $CONTAINER_ID env | grep -E "(PORT|NODE_ENV|ROUTER|SITE_HOST)" | sort
echo ""

# 9. Check Traefik routing
echo "9. Traefik routing status:"
curl -s http://localhost:8080/api/http/routers | jq '.[] | select(.name | contains("mastra"))' 2>/dev/null || echo "Traefik API not accessible or no mastra routes"
echo ""

# 10. Network connectivity
echo "10. Container networks:"
docker inspect $CONTAINER_ID --format='{{json .NetworkSettings.Networks}}' | jq 'keys'
echo ""

echo "======================================"
echo "Quick Fixes to Try:"
echo "======================================"
echo ""
echo "1. If health check is failing on /api/health (404):"
echo "   Update docker-compose.yml health check to use /api instead:"
echo "   test: [\"CMD-SHELL\", \"curl -f http://localhost:4112/api || exit 1\"]"
echo ""
echo "2. If Traefik labels are missing:"
echo "   Check that docker-compose.yml has the correct labels"
echo ""
echo "3. To bypass health check temporarily:"
echo "   docker exec $CONTAINER_ID touch /tmp/healthy"
echo "   Then update healthcheck to: test: [\"CMD-SHELL\", \"test -f /tmp/healthy\"]"
echo ""
echo "4. To test manually from outside:"
echo "   curl -H \"Host: api.ideanexusventures.com\" http://localhost/api"
echo ""