# 💻 Local Development Guide

Run the SurrealDB cluster locally for development and testing.

## ⚡ Quick Start

```bash
# Clone and start
git clone https://github.com/algoflows/surrealdb-railway-template.git
cd surrealdb-railway-template
docker compose -f docker-compose.local.yml up -d

# Verify cluster health  
docker compose -f docker-compose.local.yml ps
curl http://localhost:8000/health
```

**→ Database ready at `http://localhost:8000`**

## 🔧 Development Commands

### Cluster Management
```bash
# Start cluster
docker compose -f docker-compose.local.yml up -d

# Stop cluster  
docker compose -f docker-compose.local.yml down

# Reset with fresh data
docker compose -f docker-compose.local.yml down -v
docker compose -f docker-compose.local.yml up -d

# View logs
docker compose -f docker-compose.local.yml logs -f surrealdb
```

### Health & Testing
```bash
# Check cluster status
docker compose -f docker-compose.local.yml ps

# Health check
curl http://localhost:8000/health

# Test query
curl -X POST http://localhost:8000/sql \
  -H "Content-Type: application/json" \
  -u "root:root" \
  -d '{"sql": "CREATE users SET name = \"Local User\";"}'
```

## 🛠️ Client Development

### SurrealDB CLI
```bash
# Install CLI
curl -sSf https://install.surrealdb.com | sh

# Connect to local cluster
surreal sql --conn http://localhost:8000 --user root --pass root --ns dev --db test
```

### Client Libraries
```bash
# JavaScript/TypeScript
npm install surrealdb.js

# Python
pip install surrealdb

# Rust  
cargo add surrealdb

# Go
go get github.com/surrealdb/surrealdb.go
```

### Example Connection
```javascript
import { Surreal } from 'surrealdb.js';
const db = new Surreal();
await db.connect('ws://localhost:8000/rpc');
await db.signin({ user: 'root', pass: 'root' });
await db.use({ ns: 'dev', db: 'test' });
```

## 💾 Data Management

```bash
# Export data
surreal export --conn http://localhost:8000 --user root --pass root --ns dev --db test backup.sql

# Import data  
surreal import --conn http://localhost:8000 --user root --pass root --ns dev --db test backup.sql

# Reset database
docker compose -f docker-compose.local.yml down -v
docker compose -f docker-compose.local.yml up -d
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Port 8000 in use
lsof -i :8000

# Services won't start
docker compose -f docker-compose.local.yml logs

# Connection issues
curl -v http://localhost:8000/health
docker compose -f docker-compose.local.yml ps

# Reset everything
docker compose -f docker-compose.local.yml down -v
docker system prune
docker compose -f docker-compose.local.yml up -d
```

## 🔗 Next Steps

- **[🚀 Deploy to Railway](../DEPLOY.md)** - Production deployment
- **[📖 Examples](../examples/)** - Code examples and queries  
- **[⚙️ Railway Config](../RAILWAY.md)** - Advanced Railway setup

---

**💡 Tip: Use `./scripts/health-check.sh` for comprehensive cluster health monitoring**
