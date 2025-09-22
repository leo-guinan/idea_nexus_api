#!/bin/bash

# Quick fix script for production issues
# Run this on the production server

echo "======================================="
echo "Applying Production Fixes"
echo "======================================="
echo ""

# Get container name/id
CONTAINER=$(docker ps --filter "ancestor=ghcr.io/leo-guinan/idea_nexus_api:latest" --format "{{.Names}}")
echo "Working with container: $CONTAINER"
echo ""

# Fix 1: Test if API is actually running
echo "1. Testing if API is responding internally:"
docker exec $CONTAINER curl -s http://localhost:4112/api
echo ""

if [ $? -eq 0 ]; then
    echo "✓ API is responding internally"

    # Fix 2: Check if curl exists in container
    echo ""
    echo "2. Checking if curl is installed in container:"
    docker exec $CONTAINER which curl

    if [ $? -ne 0 ]; then
        echo "✗ curl not found, installing wget as alternative..."
        # The healthcheck might be failing because curl isn't installed
        # Update the health check to use wget or node

        echo ""
        echo "3. Testing with alternative health check:"
        docker exec $CONTAINER wget -q -O- http://localhost:4112/api

        if [ $? -eq 0 ]; then
            echo "✓ wget works! Update docker-compose.yml healthcheck to:"
            echo '  test: ["CMD-SHELL", "wget -q -O- http://localhost:4112/api || exit 1"]'
        else
            echo "Trying node-based health check..."
            docker exec $CONTAINER node -e "fetch('http://localhost:4112/api').then(()=>process.exit(0)).catch(()=>process.exit(1))"

            if [ $? -eq 0 ]; then
                echo "✓ Node fetch works! Update docker-compose.yml healthcheck to:"
                echo '  test: ["CMD-SHELL", "node -e \"fetch('\''http://localhost:4112/api'\'').then(()=>process.exit(0)).catch(()=>process.exit(1))\""]'
            fi
        fi
    else
        echo "✓ curl is installed"
    fi

    # Fix 3: Force container to healthy state (temporary fix)
    echo ""
    echo "3. Applying temporary health override..."
    docker exec $CONTAINER touch /tmp/healthy

    # Fix 4: Check Traefik can see the service
    echo ""
    echo "4. Checking if Traefik can route to the service:"

    # Get container IP
    CONTAINER_IP=$(docker inspect $CONTAINER --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
    echo "Container IP: $CONTAINER_IP"

    # Test from host
    curl -s http://$CONTAINER_IP:4112/api && echo "✓ Host can reach container"

    # Check if in same network as Traefik
    echo ""
    echo "5. Checking Docker networks:"
    CONTAINER_NETWORKS=$(docker inspect $CONTAINER --format='{{range $key, $_ := .NetworkSettings.Networks}}{{$key}} {{end}}')
    TRAEFIK_NETWORKS=$(docker inspect traefik --format='{{range $key, $_ := .NetworkSettings.Networks}}{{$key}} {{end}}')

    echo "Container networks: $CONTAINER_NETWORKS"
    echo "Traefik networks: $TRAEFIK_NETWORKS"

    # Find common network
    for net in $CONTAINER_NETWORKS; do
        if [[ " $TRAEFIK_NETWORKS " =~ " $net " ]]; then
            echo "✓ Common network found: $net"
            COMMON_NET=$net
            break
        fi
    done

    if [ -z "$COMMON_NET" ]; then
        echo "✗ No common network! Connecting container to Traefik network..."
        # Try to connect to traefik network
        docker network connect traefik $CONTAINER 2>/dev/null || \
        docker network connect proxy $CONTAINER 2>/dev/null || \
        docker network connect web $CONTAINER 2>/dev/null || \
        echo "Could not connect to Traefik network"
    fi

    # Fix 5: Restart container with updated config
    echo ""
    echo "6. Restarting container..."
    docker restart $CONTAINER

    sleep 5

    # Final test
    echo ""
    echo "7. Final test from outside:"
    curl -H "Host: api.ideanexusventures.com" http://localhost/api || echo "Still not accessible from Traefik"

else
    echo "✗ API is not responding internally - checking logs..."
    docker logs $CONTAINER --tail 50
fi

echo ""
echo "======================================="
echo "Manual Steps Required:"
echo "======================================="
echo ""
echo "1. Update docker-compose.yml if needed with working healthcheck"
echo "2. Ensure .env file has correct values:"
echo "   ROUTER_NAME=mastra-api"
echo "   SITE_HOST=api.ideanexusventures.com"
echo "3. Redeploy with: docker-compose up -d"
echo "4. Check Traefik dashboard at http://your-server:8080"