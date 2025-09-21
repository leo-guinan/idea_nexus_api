#!/bin/bash

# Script to register Mastra API with indie-agent
# Update these variables for your deployment

APP_NAME="mastra-api"
GIT_URL="git@github.com:leo-guinan/idea_nexus_api.git"  # Update with your Git repo
HEALTH_URL="https://api.ideanexusventures.com/api"        # Update with your domain
BRANCH="main"
AUTO_UPDATE="true"

echo "Registering $APP_NAME with indie-agent..."
echo ""
echo "Configuration:"
echo "  Name: $APP_NAME"
echo "  Git URL: $GIT_URL"
echo "  Health URL: $HEALTH_URL"
echo "  Branch: $BRANCH"
echo "  Auto Update: $AUTO_UPDATE"
echo ""
echo "To register, run:"
echo ""
echo "sudo indie-agent register $APP_NAME \\"
echo "  $GIT_URL \\"
echo "  $HEALTH_URL \\"
echo "  $BRANCH $AUTO_UPDATE"
echo ""
echo "Before running, make sure to:"
echo "1. Update GIT_URL with your actual repository URL"
echo "2. Update HEALTH_URL with your actual domain"
echo "3. Update .env file with your domain in SITE_HOST"
echo "4. Ensure your domain points to your server"