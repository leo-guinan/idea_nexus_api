# Deployment Instructions for Mastra API with indie-agent

This guide explains how to deploy the Mastra API using indie-agent with Traefik reverse proxy.

## Prerequisites

1. A server with Docker and Docker Compose installed
2. indie-agent CLI installed
3. Traefik reverse proxy running (typically managed by indie-agent)
4. A domain name pointed to your server

## Setup Steps

### 1. Install indie-agent CLI

```bash
# Install the indie-agent CLI wrapper to /usr/local/bin
curl -L https://github.com/indie-agent/indie-agent/releases/latest/download/indie-agent -o /usr/local/bin/indie-agent
chmod +x /usr/local/bin/indie-agent
```

### 2. Configure Environment Variables

Update the `.env` file with your configuration:

```bash
# Required: Your OpenAI API key
OPENAI_API_KEY=your_openai_api_key_here

# Required: Traefik routing configuration
ROUTER_NAME=mastra-api           # Name for the Traefik router
SITE_HOST=api.yourdomain.com     # Your domain for the API

# Optional: Mastra configuration
MASTRA_LOG_LEVEL=info            # Log level (debug, info, warn, error)
```

### 3. Register the Application with indie-agent

Register your Mastra API with indie-agent:

```bash
sudo indie-agent register mastra-api \
  git@github.com:yourusername/inv-api.git \
  https://api.yourdomain.com/api \
  main true
```

Parameters:
- `mastra-api` - Application name
- `git@github.com:yourusername/inv-api.git` - Your Git repository URL
- `https://api.yourdomain.com/api` - Health check URL
- `main` - Git branch to deploy (default: main)
- `true` - Enable automatic image updates (optional)

### 4. Deploy the Application

The indie-agent timer runs every 5 minutes, but you can force an immediate deployment:

```bash
sudo indie-agent deploy mastra-api
```

### 5. Verify Deployment

Check that your API is running:

```bash
# Check container status
docker ps | grep mastra-api

# Test the API endpoint
curl https://api.yourdomain.com/api

# Check available agents
curl https://api.yourdomain.com/api/agents
```

## Docker Compose Configuration

The `docker-compose.prod.yml` file includes:

- **Traefik labels** for automatic SSL/TLS certificate management
- **Health checks** for monitoring
- **Resource limits** for production stability
- **Log rotation** to prevent disk space issues

## File Structure

```
inv-api/
├── docker-compose.prod.yml  # Production Docker Compose with Traefik labels
├── Dockerfile.simple        # Simplified Dockerfile without databases
├── .env                     # Environment variables (not in Git)
├── .env.example            # Example environment file (in Git)
└── src/                    # Application source code
```

## Monitoring and Logs

View application logs:

```bash
# View container logs
docker logs mastra-api

# Follow logs in real-time
docker logs -f mastra-api

# View last 100 lines
docker logs --tail 100 mastra-api
```

## Troubleshooting

### Container won't start
- Check environment variables in `.env`
- Verify OpenAI API key is valid
- Check Docker logs: `docker logs mastra-api`

### SSL certificate issues
- Ensure domain is properly pointed to server
- Check Traefik logs: `docker logs traefik`
- Verify Traefik labels in `docker-compose.prod.yml`

### API not accessible
- Check if container is running: `docker ps`
- Verify health check: `docker inspect mastra-api | grep -i health`
- Test locally: `docker exec mastra-api curl http://localhost:4112/api`

## Updates

To update the application:

1. Push changes to your Git repository
2. Wait for indie-agent timer (5 minutes) or force update:
   ```bash
   sudo indie-agent deploy mastra-api
   ```

The deployment will:
1. Pull latest code from Git
2. Build new Docker image
3. Recreate container with zero-downtime deployment
4. Automatic rollback on failure

## Security Notes

- Never commit `.env` file to Git
- Keep OpenAI API key secure
- Use environment-specific configuration
- Enable rate limiting in production
- Monitor API usage and costs