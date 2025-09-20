# Local Development Guide

This guide covers running the SurrealDB cluster locally for development and testing.

## Quick Start

### Single-Node (Recommended for Development)
```bash
docker compose -f docker-compose.simple.yml up -d
```

### Full Cluster (Production-like)
```bash
docker compose up -d
```

## Architecture Overview

### Single-Node Setup
- **1 SurrealDB container**: All-in-one database
- **File storage**: Data persisted to local volume
- **Port 8000**: HTTP/WebSocket interface

### Cluster Setup
- **3 PD containers**: Placement Driver coordination
- **3 TiKV containers**: Distributed storage
- **1 SurrealDB container**: Database interface
- **Port 8000**: HTTP/WebSocket interface

## Development Workflow

### 1. Start the Database
```bash
# Development (fast startup)
docker compose -f docker-compose.simple.yml up -d

# Production testing (full cluster)
docker compose up -d
```

### 2. Verify Health
```bash
# Check container status
docker compose ps

# Check logs
docker compose logs surrealdb

# Test connection
curl http://localhost:8000/health
```

### 3. Connect and Develop
```bash
# Install SurrealDB CLI
curl -sSf https://install.surrealdb.com | sh

# Connect to local instance
surreal sql --conn http://localhost:8000 --user root --pass root --ns dev --db test
```

### 4. Stop When Done
```bash
# Stop containers (keep data)
docker compose down

# Stop and remove data
docker compose down -v
```

## Configuration

### Environment Variables
Create a `.env` file:
```bash
SURREAL_USER=root
SURREAL_PASS=development_password
SURREAL_LOG_LEVEL=debug
PORT=8000
```

### Custom Configuration
Edit `docker-compose.yml` or `docker-compose.simple.yml` to customize:
- Port mappings
- Volume mounts
- Resource limits
- Network settings

## Data Management

### Backup Data
```bash
# Export all data
surreal export --conn http://localhost:8000 --user root --pass root --ns dev --db test backup.sql

# Export specific tables
surreal export --conn http://localhost:8000 --user root --pass root --ns dev --db test --table users backup-users.sql
```

### Restore Data
```bash
# Import data
surreal import --conn http://localhost:8000 --user root --pass root --ns dev --db test backup.sql
```

### Reset Database
```bash
# Remove all data and restart
docker compose down -v
docker compose up -d
```

## Performance Tuning

### Resource Limits
Add to your compose file:
```yaml
services:
  surrealdb:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
```

### Storage Optimization
```yaml
volumes:
  surrealdb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/to/fast/storage
```

## Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Check what's using port 8000
lsof -i :8000

# Use different port
PORT=8001 docker compose up -d
```

**Container Won't Start**
```bash
# Check logs
docker compose logs surrealdb

# Check system resources
docker system df
docker system prune
```

**Connection Refused**
```bash
# Verify container is running
docker compose ps

# Check port mapping
docker compose port surrealdb 8000

# Test with curl
curl -v http://localhost:8000/health
```

**Data Loss**
```bash
# Check volume status
docker volume ls
docker volume inspect surrealdb-railway-template_surrealdb_data

# Backup before operations
surreal export --conn http://localhost:8000 --user root --pass root backup.sql
```

## IDE Integration

### VS Code
Install the SurrealDB extension:
```bash
code --install-extension surrealdb.surrealql
```

### Database Clients
- **Surrealist**: Official GUI client
- **DBeaver**: Universal database tool
- **DataGrip**: JetBrains database IDE

## Testing

### Unit Tests
```bash
# Run application tests against local DB
npm test
# or
cargo test
# or  
python -m pytest
```

### Integration Tests
```bash
# Start test database
docker compose -f docker-compose.test.yml up -d

# Run integration tests
npm run test:integration

# Cleanup
docker compose -f docker-compose.test.yml down -v
```

## Next Steps

- [Railway Deployment](../RAILWAY.md)
- [API Examples](../examples/)
- [Production Setup](./PRODUCTION.md)
