# SurrealDB Railway Deployment Template

This template provides multiple deployment options for SurrealDB on Railway, from simple single-node to full cluster setups.

## 🚀 Quick Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/surrealdb-cluster)

## 📋 Deployment Options

### Option 1: Single-Node (Recommended for Railway)

**Best for**: Development, testing, small applications

```bash
# Deploy using Dockerfile
railway up --dockerfile Dockerfile
```

**Features**:
- ✅ Single container deployment
- ✅ Persistent file storage
- ✅ Railway-optimized
- ✅ Auto-scaling support
- ❌ No high availability

### Option 2: Multi-Service Cluster

**Best for**: Production, high availability requirements

```bash
# Deploy using railway.yml
railway up --config railway.yml
```

**Features**:
- ✅ High availability (3 PD + 3 TiKV nodes)
- ✅ Distributed storage
- ✅ ACID transactions
- ❌ Higher resource usage
- ❌ More complex setup

## 🔧 Configuration

### Environment Variables

Set these in your Railway service:

```bash
# Required
SURREAL_USER=root
SURREAL_PASS=your_secure_password

# Optional
PORT=8000
SURREAL_LOG_LEVEL=info
```

### Railway Template Variables

When deploying via template, you'll be prompted for:

- `SURREAL_PASS`: Database password (auto-generated if not provided)
- `DEPLOYMENT_TYPE`: `single` or `cluster`

## 📦 Template Structure

```
surrealdb/
├── Dockerfile              # Single-node Railway deployment
├── railway.yml            # Multi-service cluster config
├── railway.json           # Railway service configuration
├── start.sh               # Smart startup script
├── compose.yml            # Local cluster development
├── compose-simple.yml     # Local single-node development
├── env.example           # Environment variables template
├── README.md             # Local development docs
└── RAILWAY.md            # This file
```

## 🛠️ Local Development

### Single-Node Development
```bash
# Quick start
docker compose -f compose-simple.yml up -d

# Or using the Railway-compatible setup
docker build -t surrealdb-local .
docker run -p 8000:8000 -e SURREAL_USER=root -e SURREAL_PASS=root surrealdb-local
```

### Full Cluster Development
```bash
# Start full cluster
docker compose up --pull always -d

# Check cluster health
docker compose ps
docker compose logs surrealdb
```

## 🔗 Connection Details

### Railway Deployment
- **URL**: `https://your-service.railway.app`
- **Port**: Automatically assigned by Railway
- **WebSocket**: `wss://your-service.railway.app/rpc`

### Local Development
- **URL**: `http://localhost:8000`
- **WebSocket**: `ws://localhost:8000/rpc`

### Authentication
```bash
# HTTP API
curl -X POST https://your-service.railway.app/sql \
  -H "Content-Type: application/json" \
  -u "root:your_password" \
  -d '{"sql": "INFO FOR DB;"}'

# WebSocket (connect first)
{
  "id": 1,
  "method": "signin",
  "params": {
    "user": "root",
    "pass": "your_password"
  }
}
```

## 📊 Monitoring & Health

### Health Endpoints
- **Health Check**: `GET /health`
- **Status**: `GET /status`

### Railway Metrics
Railway automatically provides:
- CPU/Memory usage
- Request metrics
- Error rates
- Response times

### Cluster Monitoring (Multi-Service Only)
```bash
# Check PD cluster status
railway logs pd0 | grep health

# Check TiKV status
railway logs tikv0 | grep "server is ready"

# Check SurrealDB connectivity
curl https://your-service.railway.app/health
```

## 🚨 Troubleshooting

### Common Issues

**1. Service Won't Start**
```bash
# Check logs
railway logs

# Verify environment variables
railway variables
```

**2. Connection Refused**
- Ensure `PORT` environment variable is set correctly
- Check Railway service URL in dashboard

**3. Cluster Services Not Communicating**
- Verify all services are healthy: `railway ps`
- Check inter-service networking in Railway dashboard

**4. Data Loss on Restart**
- Single-node: Data persists automatically with Railway volumes
- Cluster: Ensure TiKV volumes are properly configured

### Performance Tuning

**Single-Node Optimization**:
```bash
# Increase memory allocation
SURREAL_MEMORY_LIMIT=512MB

# Adjust log level
SURREAL_LOG_LEVEL=warn
```

**Cluster Optimization**:
- Scale TiKV replicas based on data size
- Monitor PD leader election
- Adjust Railway service resources

## 🔄 Migration & Backup

### Export Data
```bash
# Connect to Railway service
surreal export --conn https://your-service.railway.app \
  --user root --pass your_password \
  --ns production --db main backup.sql
```

### Import Data
```bash
# Import to Railway service
surreal import --conn https://your-service.railway.app \
  --user root --pass your_password \
  --ns production --db main backup.sql
```

## 📚 Additional Resources

- [SurrealDB Documentation](https://surrealdb.com/docs)
- [Railway Documentation](https://docs.railway.app)
- [TiKV Documentation](https://tikv.org/docs) (for cluster deployments)
- [PingCAP PD Documentation](https://docs.pingcap.com/tidb/stable/pd-overview)
