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

### ⏰ Scheduled Backups (Cron service)

You can add a lightweight "Cron" service on Railway to run daily backups to S3/GCS via pre-signed URL.

1) Create a new service (Cron) with a minimal image (e.g. `curlimages/curl:8.9.1`)

2) Add environment variables:
```
SURR_URL=https://your-app.railway.app
SURR_USER=root
SURR_PASS=your_password
SURR_NS=app
SURR_DB=app
BACKUP_URL=https://<your-presigned-url>
```

3) Set the command:
```
sh -c "apk add --no-cache bash jq >/dev/null 2>&1 || true; \ 
  /bin/sh -lc 'wget -qO /tmp/backup-to-url.sh https://raw.githubusercontent.com/surrealdb/surrealdb-railway-template/main/scripts/backup-to-url.sh && chmod +x /tmp/backup-to-url.sh && /tmp/backup-to-url.sh \"$SURR_URL\" \"$SURR_USER\" \"$SURR_PASS\" \"$SURR_NS\" \"$SURR_DB\" \"$BACKUP_URL\"'"
```

4) Scheduling: In Railway, set the **Deploy Trigger** to run on a schedule (e.g., daily at 02:00 UTC).

Alternatively, build a tiny container that bundles `bash`, `jq`, and our backup script, and use Railway's **Deploy Triggers** scheduler.

## 🗄️ Scheduled Backups via Railway Functions (Bun)

This repo includes an optional Railway Function (`functions/admin.ts`) that supports multiple actions (including backups) behind a single endpoint.

### 1) Create the Function service
- Railway → New Service → Functions → connect this repo
- Runtime: Bun
- Entrypoint: `functions/admin.ts` (default export `handler`)

### 2) Configure environment variables
```
SURR_URL=https://your-app.railway.app
SURR_USER=root
SURR_PASS=your_password
SURR_NS=app
SURR_DB=app
# Optionally, set a pre-signed blob URL to upload:
BACKUP_URL=https://<your-presigned-url>
```

### 3) Test the function manually
```
curl -H "X-Admin-Signature: $ADMIN_SECRET" \
  "https://<your-function-url>?action=backup"
# If BACKUP_URL is set, it uploads; otherwise it returns the .surql
```

### 4) Schedule the function (recommended)
- Railway → Triggers → New → Scheduled HTTP
- Method: `GET`
- URL: `https://<your-function-url>?action=backup`
- Cron: `0 2 * * *` (daily 02:00 UTC)

### 5) Restore flow (for reference)
```
./scripts/restore.sh https://your-app.railway.app root "$SURREAL_PASS" "$SURREAL_NS" "$SURREAL_DB" backups/backup-...surql
```

Notes:
- Function uses web APIs (`fetch`, `btoa`) and Bun runtime. No Node typings required.
- If your backups are large, prefer uploading via `BACKUP_URL` to avoid large HTTP responses.

## 🔧 Admin Function (Bun) - Safe Multi-Action Ops

This repo also includes an optional "admin" Function (`functions/admin.ts`) for safe operations via a single endpoint.

### Actions supported
- `action=health` → returns DB info status
- `action=backup` → performs EXPORT (uploads if `BACKUP_URL` set)
- `action=exportTable&table=users` → returns table rows
- `action=migrate&src=https://.../init.surql` → applies migration SQL (idempotent)

### Security
- Send `X-Admin-Signature: <ADMIN_SECRET>` header (set `ADMIN_SECRET` env on Function)
- Use IP allowlists on Railway if desired
- Keep destructive ops (restore/reset) in a separate function with stricter controls

### Example call
```
curl -H "X-Admin-Signature: $ADMIN_SECRET" \
  "https://<your-admin-function-url>?action=exportTable&table=users"
```

## 🌐 Environment-Scoped Variables (so Functions see DB creds)

Templates set variables per service; Functions won’t auto-inherit SurrealDB vars. After creation, promote shared vars to the Environment scope:

```bash
# Domain for SurrealDB (or set your custom domain)
SURR_URL=https://$(railway domain --service surrealdb)

# Grab the generated root password from the SurrealDB service
SURR_PASS=$(railway variables get SURREAL_PASS --service surrealdb --raw)

# Promote to environment scope so all services (Functions included) inherit
railway variables set --scope environment \
  SURR_URL="$SURR_URL" \
  SURR_USER=root \
  SURR_PASS="$SURR_PASS" \
  SURR_NS=app \
  SURR_DB=app \
  ADMIN_SECRET=$(openssl rand -hex 16)

# Optional: pre-signed upload target for backups
railway variables set --scope environment BACKUP_URL=https://<presigned-url>

# Verify in the Function service
railway shell --service <your-admin-fn> -- printenv SURR_URL SURR_NS SURR_DB ADMIN_SECRET
```

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
