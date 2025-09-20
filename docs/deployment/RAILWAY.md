# ⚙️ Railway Advanced Configuration

Advanced Railway configuration and customization options for the SurrealDB cluster template.

> **Quick Deploy**: Use **[DEPLOY.md](./DEPLOY.md)** for standard deployment

## 🏗️ Architecture Deep Dive

### Cluster Components
```
Railway Project
├── pd0, pd1, pd2      (PD Coordination)
├── tikv0, tikv1, tikv2 (Distributed Storage)  
└── surrealdb          (Query Engine)
```

### Resource Allocation
| Service | Memory | CPU | Purpose |
|---------|--------|-----|---------|
| **PD Nodes** | 512MB | 0.5 | Cluster coordination & metadata |
| **TiKV Nodes** | 1GB | 1.0 | Distributed storage & replication |
| **SurrealDB** | 2GB | 2.0 | Query processing & API |
| **Total** | 5.5GB | 6.5 | Full cluster resources |

## 🔧 Advanced Configuration

### Environment Variables

| Variable | Default | Description | Tuning |
|----------|---------|-------------|---------|
| `SURREAL_LOG_LEVEL` | `info` | SurrealDB logging | `trace`, `debug`, `info`, `warn`, `error` |
| `PD_LOG_LEVEL` | `info` | PD cluster logging | Same as above |
| `TIKV_LOG_LEVEL` | `info` | TiKV storage logging | Same as above |
| `SURREAL_USER` | `root` | Database username | Custom username |
| `SURREAL_PASS` | Auto-gen | Database password | 32-char hex (auto) |

### Performance Tuning

**Query Optimization:**
```bash
# Set via Railway dashboard
SURREAL_QUERY_TIMEOUT=30s
SURREAL_TRANSACTION_TIMEOUT=10s
```

**TiKV Tuning:**
```bash
# Advanced TiKV settings (edit docker-compose.yml)
TIKV_GRPC_CONCURRENCY=4
TIKV_GRPC_CONCURRENT_STREAM=1024
```

## 📊 Railway Native Monitoring

### Built-in Features
- ✅ **Structured JSON logs** from all 7 services
- ✅ **Real-time metrics** (CPU, Memory, Network)
- ✅ **Health checks** with automatic alerts
- ✅ **Performance insights** and query analytics

### Logging Configuration

**Default (Railway Optimized):**
- Structured JSON logging → Railway dashboards
- No file volumes needed
- Optimal for Railway deployments

**File-based Logging (Optional):**
```yaml
# Uncomment in docker-compose.yml
volumes:
  - pd0_logs:/logs
command:
  - --log-file=/logs/pd0.log
```

**Monitoring Commands:**
```bash
# View all logs
railway logs --follow

# Service-specific logs  
railway logs --service surrealdb
railway logs --service pd0

# Filter by level
railway logs --filter "level=error"
```

## 🔧 Custom Configuration

### Fork & Customize
```bash
# 1. Fork the template repository
git clone https://github.com/your-username/surrealdb-railway-template.git

# 2. Edit docker-compose.yml for custom settings
# 3. Update railway.toml for environment variables
# 4. Deploy your custom version
railway up
```

### Resource Scaling
```yaml
# Edit docker-compose.yml
services:
  surrealdb:
    deploy:
      resources:
        limits:
          memory: 4G    # Scale up for heavy workloads
          cpus: '3.0'
```

## 🚨 Troubleshooting

### Quick Diagnostics
```bash
# Check all services
railway ps

# View logs
railway logs --service surrealdb

# Test connectivity
curl https://your-app.railway.app/health

# Check environment
railway variables
```

### Common Issues
- **Services not starting**: Check Railway logs for startup errors
- **Connection refused**: Verify Railway URL and credentials
- **Performance issues**: Monitor Railway metrics dashboard
- **Data persistence**: Ensure volumes are properly configured

## 📚 Resources

- **[🚀 Quick Deploy](./DEPLOY.md)** - Standard deployment guide
- **[💻 Local Development](./docs/LOCAL.md)** - Development setup
- **[📖 SurrealDB Docs](https://surrealdb.com/docs)** - Database documentation
- **[🚂 Railway Docs](https://docs.railway.app)** - Platform documentation

---

**💡 For standard deployment, use [DEPLOY.md](./DEPLOY.md). This guide is for advanced customization.**
