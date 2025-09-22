# Deployment Instructions for Mastra API with indie-agent

This guide explains how to deploy the Mastra API using indie-agent with Traefik reverse proxy and GitHub Actions for building Docker images.

## Architecture

- **GitHub Actions**: Builds Docker images automatically on push to main
- **GitHub Container Registry (ghcr.io)**: Stores pre-built Docker images
- **indie-agent**: Manages deployments and auto-updates
- **Traefik**: Handles SSL/TLS and reverse proxy

## Prerequisites

1. A server with Docker and Docker Compose installed (minimum 1GB RAM)
2. indie-agent CLI installed on the server
3. Traefik reverse proxy running (typically managed by indie-agent)
4. A domain name pointed to your server
5. GitHub repository with Actions enabled

## Initial Setup

### 1. GitHub Actions Setup

The GitHub Action is already configured in `.github/workflows/docker-build.yml`. It will:
- Trigger on push to main branch
- Build multi-platform Docker images (amd64 and arm64)
- Push to GitHub Container Registry (ghcr.io)
- Tag images with branch name and SHA

No additional setup needed - it uses the built-in GITHUB_TOKEN.

### 2. First Build

Push your code to trigger the first build:

```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

Monitor the build at: https://github.com/leo-guinan/idea_nexus_api/actions

### 3. Server Setup

#### Install indie-agent CLI

```bash
# Install the indie-agent CLI wrapper to /usr/local/bin
curl -L https://github.com/indie-agent/indie-agent/releases/latest/download/indie-agent -o /usr/local/bin/indie-agent
chmod +x /usr/local/bin/indie-agent
```

#### Configure Environment Variables

Create `.env` file on the server:

```bash
# Required: Your OpenAI API key
OPENAI_API_KEY=your_openai_api_key_here

# Required: Traefik routing configuration
ROUTER_NAME=mastra-api
SITE_HOST=api.ideanexusventures.com

# Optional: Mastra configuration
MASTRA_LOG_LEVEL=info
```

### 4. Register with indie-agent

Register your Mastra API:

```bash
sudo indie-agent register mastra-api \
  git@github.com:leo-guinan/idea_nexus_api.git \
  https://api.ideanexusventures.com/api \
  main true
```

### 5. Initial Deployment

Since images are built in GitHub Actions, the server only needs to pull and run:

```bash
# Pull the latest image (public repository, no auth needed)
docker pull ghcr.io/leo-guinan/idea_nexus_api:latest

# Deploy using indie-agent
sudo indie-agent deploy mastra-api
```

Or use the provided deploy script:

```bash
./deploy.sh
```

## Continuous Deployment Workflow

1. **Development**: Make changes locally
2. **Push**: `git push origin main`
3. **Build**: GitHub Actions builds and pushes image (~2-3 minutes)
4. **Deploy**: indie-agent automatically pulls and deploys (runs every 5 minutes)

To force immediate deployment after build:

```bash
sudo indie-agent deploy mastra-api
```

## Docker Compose Configuration

The `docker-compose.yml` now uses pre-built images:

```yaml
services:
  mastra-api:
    image: ghcr.io/leo-guinan/idea_nexus_api:latest
    # ... rest of configuration
```

Benefits:
- ✅ No building on server (saves resources)
- ✅ Consistent builds across environments
- ✅ Faster deployments (just pull and run)
- ✅ Build cache optimization in GitHub Actions

## Monitoring

### Check Deployment Status

```bash
# View container status
docker ps | grep mastra-api

# Check container health
docker inspect mastra-api --format='{{.State.Health.Status}}'

# View logs
docker logs mastra-api --tail 100 -f

# Test API
curl https://api.ideanexusventures.com/api
```

### GitHub Actions Status

Monitor builds at: https://github.com/leo-guinan/idea_nexus_api/actions

## Troubleshooting

### Image Pull Issues

If the repository is private, you'll need to authenticate:

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Or use a Personal Access Token (PAT)
docker login ghcr.io -u USERNAME -p YOUR_PAT
```

### Container Won't Start

1. Check image was pulled: `docker images | grep idea_nexus_api`
2. Check logs: `docker logs mastra-api`
3. Verify environment variables in `.env`
4. Check health endpoint: `curl http://localhost:4112/api`

### Build Failures in GitHub Actions

1. Check Actions tab in GitHub repository
2. Review build logs for errors
3. Ensure Dockerfile.simple is correct
4. Verify multi-platform build compatibility

## Manual Deployment (Without indie-agent)

If you need to deploy manually:

```bash
# Pull latest image
docker pull ghcr.io/leo-guinan/idea_nexus_api:latest

# Stop existing container
docker compose down

# Start new container
docker compose up -d

# Check status
docker ps
```

## Rollback

To rollback to a previous version:

```bash
# List available tags
docker images ghcr.io/leo-guinan/idea_nexus_api

# Pull specific version (using git SHA)
docker pull ghcr.io/leo-guinan/idea_nexus_api:main-abc123

# Update docker-compose.yml to use specific tag
# Then restart
docker compose up -d
```

## Security Notes

- GitHub Actions uses repository secrets automatically
- Images in ghcr.io inherit repository visibility (public/private)
- Never commit `.env` file with secrets
- Use environment-specific configurations
- Monitor resource usage to prevent server overload

## Resource Requirements

Minimum server requirements:
- **RAM**: 1GB (512MB for container + system overhead)
- **CPU**: 1 core
- **Disk**: 5GB (for Docker images and logs)
- **Network**: Stable connection for pulling images

## Cost Optimization

- GitHub Actions: 2,000 minutes/month free for public repos
- GitHub Container Registry: Free for public repos
- Build time: ~2-3 minutes per build
- Image size: ~200MB compressed