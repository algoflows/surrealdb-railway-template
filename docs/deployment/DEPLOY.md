# 🚀 Railway Deployment Guide

Deploy a production-ready SurrealDB cluster on Railway in minutes.

## ⚡ One-Click Deploy

### 1. Deploy from Marketplace
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/surrealdb-cluster)

**→ Click button → Configure → Deploy → Done!**

### 2. What Gets Deployed
```
✅ 3 PD coordination nodes (pd0, pd1, pd2)
✅ 3 TiKV storage nodes (tikv0, tikv1, tikv2)  
✅ 1 SurrealDB query engine (surrealdb)
✅ Auto-generated secure passwords
✅ Railway-native monitoring & logging
✅ Health checks & automatic restarts
```

### 3. Deployment Time
- **Initial Deploy**: 3-5 minutes
- **Service Startup**: 2-3 minutes  
- **Health Checks**: 30 seconds
- **Total Ready Time**: ~6-8 minutes

## 🔧 Configuration Options

### Environment Variables (Auto-Configured)

| Variable | Description | Default | Auto-Generated |
|----------|-------------|---------|----------------|
| `SURREAL_USER` | Database username | `root` | ❌ |
| `SURREAL_PASS` | Database password | - | ✅ (32-char hex) |
| `SURREAL_LOG_LEVEL` | SurrealDB logging | `info` | ❌ |
| `PD_LOG_LEVEL` | PD cluster logging | `info` | ❌ |
| `TIKV_LOG_LEVEL` | TiKV storage logging | `info` | ❌ |
| `PORT` | Service port | `8000` | ❌ |

### Advanced Deployment (Custom Repo)

```bash
# 1. Fork & clone the template
git clone https://github.com/surrealdb/surrealdb-railway-template.git

# 2. Deploy with Railway CLI
npm install -g @railway/cli
railway login
railway up

# 3. Custom environment variables (optional)
railway variables set SURREAL_LOG_LEVEL=debug
```

## 🔗 Connect to Your Database

### 1. Get Your Railway URL
```bash
# From Railway dashboard or CLI
railway domain
# → https://your-app.railway.app
```

### 2. Test Connection
```bash
# Health check
curl https://your-app.railway.app/health

# Test query
curl -X POST https://your-app.railway.app/sql \
  -H "Content-Type: application/json" \
  -u "root:your_password" \
  -d '{"sql": "INFO FOR DB;"}'
```

### 3. Client Connection
```javascript
// JavaScript/TypeScript
import { Surreal } from 'surrealdb.js';
const db = new Surreal();
await db.connect('wss://your-app.railway.app/rpc');
await db.signin({ user: 'root', pass: 'your_password' });
```

```python
# Python
from surrealdb import Surreal
async with Surreal("wss://your-app.railway.app/rpc") as db:
    await db.signin({"user": "root", "pass": "your_password"})
```

## 📊 Monitoring & Logs

### Railway Dashboard (Built-in)
- ✅ **Real-time logs** from all 7 services
- ✅ **Resource metrics** (CPU, Memory, Network)
- ✅ **Health checks** with automatic alerts
- ✅ **Performance insights** and query analytics

### Quick Monitoring
```bash
# View logs
railway logs --follow

# Check specific service
railway logs --service surrealdb

# Health check
curl https://your-app.railway.app/health
```

## 🚨 Troubleshooting

### Common Issues

**Services Not Starting**
```bash
railway logs --service pd0    # Check PD coordination
railway logs --service tikv0  # Check TiKV storage  
railway logs --service surrealdb  # Check SurrealDB
```

**Connection Issues**
```bash
railway domain               # Verify URL
railway variables           # Check credentials
curl https://your-app.railway.app/health  # Test endpoint
```

**Performance Issues**
- Monitor Railway metrics dashboard
- Check resource usage per service
- Review query patterns in logs

## 🔄 Updates & Maintenance

Railway automatically handles:
- ✅ **Template updates** via pull requests
- ✅ **Security patches** and container updates  
- ✅ **Backup management** with persistent volumes
- ✅ **Scaling** based on resource usage

## 🆘 Support

- **[Template Issues](https://github.com/surrealdb/surrealdb-railway-template/issues)** - Bug reports & features
- **[SurrealDB Discord](https://discord.gg/surrealdb)** - Database support
- **[Railway Discord](https://discord.gg/railway)** - Platform support

---

**🎉 Your SurrealDB cluster is now running on Railway!**

**Next Steps:**
1. **Save your credentials** from Railway dashboard
2. **Test the connection** using the examples above  
3. **Start building** with your new database
4. **Join the community** for support and updates
