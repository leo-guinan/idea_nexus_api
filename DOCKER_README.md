# Docker Setup for Skippy Mastra (Innovation Nexus)

This guide provides instructions for running the Skippy Mastra application using Docker Compose with all required services.

## Architecture

The production setup includes:
- **Mastra Server**: The main application server running the Skippy agent
- **ChromaDB**: Vector database for meme storage and embeddings
- **SQLite**: Embedded database for investor data and interactions
- **Nginx**: Reverse proxy (optional, for production)

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- OpenAI API key

## Quick Start

1. **Configure Environment Variables**
   ```bash
   cp .env.example .env
   # Edit .env and add your OPENAI_API_KEY
   ```

2. **Start Services (Development)**
   ```bash
   ./scripts/docker-start.sh
   ```

3. **Start Services (Production)**
   ```bash
   ./scripts/docker-start.sh --prod -d
   ```

## Service URLs

- **Mastra Playground**: http://localhost:4112/
- **Mastra API**: http://localhost:4112/api
- **ChromaDB**: http://localhost:8000

## Docker Commands

### Start Services
```bash
# Development mode
docker-compose up

# Production mode with optimizations
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Rebuild images
docker-compose up --build
```

### Stop Services
```bash
docker-compose down

# Remove volumes (WARNING: Deletes all data)
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f mastra-server
docker-compose logs -f chroma
```

### Service Management
```bash
# Check status
docker-compose ps

# Restart a service
docker-compose restart mastra-server

# Execute commands in container
docker-compose exec mastra-server sh
```

## Data Persistence

- **SQLite Database**: Stored in `sqlite_data` volume at `/app/data/skippy.db`
- **ChromaDB Data**: Stored in `chroma_data` volume at `/chroma/chroma`
- **Logs**: Mounted to `./logs` directory

## Production Deployment

### Using the Production Profile

The production profile includes:
- Resource limits
- Optimized logging
- Nginx reverse proxy
- Health checks

```bash
# Start with production settings
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --profile production
```

### SSL/TLS Configuration

1. Place SSL certificates in `./ssl/` directory
2. Update `nginx.conf` with your domain name
3. Uncomment the HTTPS server block in `nginx.conf`

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENAI_API_KEY` | OpenAI API key for AI operations | Yes |
| `POSTGRES_CONNECTION_STRING` | PostgreSQL URL for Mastra metadata | No |
| `MASTRA_LOG_LEVEL` | Logging level (debug/info/warn/error) | No |
| `NODE_ENV` | Environment (development/production) | No |

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs mastra-server

# Verify environment variables
docker-compose config

# Check for port conflicts
lsof -i :4112
lsof -i :8000
```

### Database Issues
```bash
# Reset database (WARNING: Deletes all data)
docker-compose down -v
docker-compose up --build

# Backup database
docker-compose exec mastra-server cp /app/data/skippy.db /app/data/skippy.db.backup
```

### Memory Issues
Increase Docker Desktop memory allocation to at least 4GB in Docker preferences.

### Build Failures
```bash
# Clean build cache
docker system prune -a
docker-compose build --no-cache
```

## Health Checks

Services include health checks that can be monitored:

```bash
# Check Mastra health
curl http://localhost:4112/api/health

# Check ChromaDB health
curl http://localhost:8000/api/v1
```

## Backup and Restore

### Backup
```bash
# Backup all data
docker-compose exec mastra-server tar -czf /tmp/backup.tar.gz /app/data
docker cp skippy-mastra:/tmp/backup.tar.gz ./backups/

# Backup ChromaDB
docker-compose exec chroma tar -czf /tmp/chroma-backup.tar.gz /chroma/chroma
docker cp skippy-chroma:/tmp/chroma-backup.tar.gz ./backups/
```

### Restore
```bash
# Restore SQLite
docker cp ./backups/backup.tar.gz skippy-mastra:/tmp/
docker-compose exec mastra-server tar -xzf /tmp/backup.tar.gz -C /

# Restore ChromaDB
docker cp ./backups/chroma-backup.tar.gz skippy-chroma:/tmp/
docker-compose exec chroma tar -xzf /tmp/chroma-backup.tar.gz -C /
```

## Development

For development with hot-reload:
```bash
# Run locally with docker-compose for dependencies only
docker-compose up chroma
npm run dev
```

## Support

For issues or questions, check:
- Application logs: `docker-compose logs -f`
- Service status: `docker-compose ps`
- Container shell: `docker-compose exec mastra-server sh`