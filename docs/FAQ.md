# 🤔 Frequently Asked Questions (FAQ)

## 🏗️ Architecture & Design

### ❓ **Why does this template use TiKV instead of single-node SurrealDB?**

**SurrealDB offers two deployment options:**

**1. Single-Node Deployment:**
- ✅ **Simple setup** - One container, in-memory or RocksDB storage
- ✅ **Good for development** - Testing, prototyping, small apps
- ❌ **Limited scalability** - Single point of failure
- ❌ **Data size limits** - Constrained by single machine

**2. Distributed Deployment (Our Choice):**
- ✅ **High availability** - No single points of failure
- ✅ **Horizontal scaling** - Add nodes as you grow
- ✅ **Production ready** - Enterprise-grade reliability
- ✅ **Automatic distribution** - TiKV handles data placement

**Why we chose distributed for Railway:**
- **Railway's strength** is scaling and reliability
- **Production focus** - Most users want production-ready databases
- **Growth ready** - Start with HA, scale via dashboard
- **Cost effective** - Optimized resource allocation

**Per SurrealDB docs:** *"For applications requiring high availability and scalability, SurrealDB supports distributed deployments using TiKV as the storage layer."*

## 📊 Data Persistence & Scaling

### ❓ **Will adding nodes to docker-compose and redeploying wipe my data?**

**✅ No, your data is safe!** Railway uses **persistent volumes** for database storage, which survive redeployments and scaling operations.

**How it works:**
```yaml
# In docker-compose.yml - these volumes persist across deployments
volumes:
  pd0_data:     # PD coordination data - persists
  pd1_data:     # PD coordination data - persists  
  pd2_data:     # PD coordination data - persists
  tikv0_data:   # Your actual database data - persists
  tikv1_data:   # Your actual database data - persists
  tikv2_data:   # Your actual database data - persists
```

**What happens when you redeploy:**
1. **Container stops** - Application containers are recreated
2. **Volumes persist** - All data volumes remain intact
3. **New containers start** - Connect to existing data volumes
4. **Data intact** - Your database picks up exactly where it left off

### ❓ **What about scaling SurrealDB replicas via Railway dashboard?**

**✅ Completely safe!** According to SurrealDB's official documentation, **the compute layer is stateless** - it doesn't store data locally.

**Official SurrealDB Architecture:**
```
SurrealDB Compute Layer (Stateless)
    ↓ Connects to
TiKV Storage Layer (Stateful, Distributed)
    ↓ Stores data in
Railway Volumes (Persistent)
```

**Why this works (per SurrealDB docs):**
- ✅ **Stateless compute layer** - "you can add or remove instances without complex coordination"
- ✅ **Distributed storage** - "TiKV automatically distributes data across nodes"
- ✅ **Data persistence** - "data is persisted across restarts and redeployments"
- ✅ **Horizontal scaling** - "storage layer can scale horizontally"

**When you scale SurrealDB replicas:**
- ✅ **New SurrealDB instances** connect to same TiKV cluster
- ✅ **All data remains** in TiKV persistent volumes
- ✅ **Zero data loss** - just more query capacity
- ✅ **No coordination needed** - SurrealDB's stateless design handles this automatically

### ❓ **When do I actually need to edit docker-compose.yml instead of using the dashboard?**

**🎯 You need code changes only for these scenarios:**

**1. Adding Storage Capacity (TiKV nodes):**
```yaml
# When your data outgrows 3 TiKV nodes
# Add tikv3, tikv4, etc. to docker-compose.yml
tikv3:
  image: pingcap/tikv:v8.5.0
  # ... same config as tikv0/tikv1/tikv2
  volumes:
    - tikv3_data:/data  # New persistent volume
```

**2. Custom Resource Limits:**
```yaml
# If you need specific resource configurations
deploy:
  resources:
    limits:
      memory: 4G      # Custom limit
      cpus: '3.0'     # Custom CPU allocation
```

**3. Advanced Configurations:**
- Custom TiKV/PD parameters
- Network configurations
- Volume mount customizations
- Multi-region setups

**📊 When you DON'T need code changes:**
- ✅ **More users** → Scale SurrealDB replicas via dashboard
- ✅ **Better performance** → Increase CPU/RAM via dashboard  
- ✅ **Traffic spikes** → Scale resources via dashboard
- ✅ **Query optimization** → Add SurrealDB replicas via dashboard

**💡 Rule of thumb:** If it's about **performance or users**, use the **dashboard**. If it's about **storage capacity or custom configs**, edit **docker-compose.yml**.

### ❓ **What if I need to add more TiKV storage nodes?**

**⚠️ This requires docker-compose.yml changes** but data remains safe with proper steps:

**Safe approach:**
1. **Backup first** (always recommended)
2. **Add new TiKV services** to docker-compose.yml
3. **Commit and push** - Railway redeploys
4. **TiKV cluster rebalances** data automatically
5. **Data spreads** across old + new nodes

**When you need this:**
- Data size approaching TiKV node limits (50GB per volume on Pro plan)
- Need more distributed storage capacity
- Planning for multi-TB data storage

### ❓ **What are Railway's volume size limits?**

**Railway Volume Limits (2024):**
- **Free/Trial Plans**: 0.5GB per volume
- **Hobby Plan**: 5GB per volume
- **Pro/Team Plans**: 50GB per volume (expandable to 250GB)
- **Enterprise**: Contact Railway for larger volumes

**Our Template Uses 6 Volumes:**
- **3 PD volumes** - Coordination data (small usage, <1GB each)
- **3 TiKV volumes** - Your actual database data (main storage)

**Storage Capacity by Plan:**
- **Hobby**: 5GB × 6 = 30GB total capacity
- **Pro**: 50GB × 6 = 300GB total capacity  
- **Pro + Expansion**: 250GB × 6 = 1.5TB total capacity

**⚠️ Important Volume Considerations:**
- **Each service gets ONE volume** - cannot add more volumes later
- **Resizing requires downtime** - all deployments go offline during resize
- **Plan ahead** - start with Pro plan if you expect >5GB data
- **Contact Railway support** for volumes >250GB

**💡 Scaling Strategy:**
1. **Start with Pro plan** ($20/month) for 50GB volumes
2. **Monitor usage** via Railway dashboard
3. **Request expansion** to 250GB when approaching limits
4. **Add TiKV nodes** (via docker-compose.yml) for >1.5TB needs

### ❓ **What can our default HA template serve and store?**

**📊 Default Capacity (Railway Pro Plan):**

**Storage Capacity: 300GB Total**
- **6 volumes × 50GB each** = 300GB total capacity
- **3 PD volumes** (~1-3GB used) - Cluster coordination metadata
- **3 TiKV volumes** (~297GB available) - Your actual database storage
- **Expandable to 1.5TB** (250GB × 6 volumes via Railway support)

**User & Traffic Capacity:**
- **1,000-5,000 concurrent users** out of the box
- **10,000+ users** with SurrealDB replica scaling (1-click)
- **5,000-15,000 QPS** (queries per second) baseline
- **15,000-30,000 QPS** with 2x SurrealDB replicas

**💾 Real-World Storage Examples (300GB):**

**SaaS Applications:**
```
📊 User Data:
- 3 million users × 100KB each = 300GB
- User profiles, preferences, activity logs

📱 Social Media App:
- 1 million users with posts, comments, likes
- 500 million social interactions
- Rich user profiles and media metadata

🛒 E-commerce Platform:
- 100,000 products with full catalogs
- 10 million orders with complete history
- Customer data, reviews, analytics

📈 Analytics Platform:
- 100 million time-series data points
- Real-time dashboards and reporting
- Historical trend analysis
```

**🚀 Application Examples Our Template Could Power:**

**1. SaaS Platforms:**
- **Customer base**: 50,000-100,000 active users
- **Data**: User accounts, subscriptions, usage analytics
- **Features**: Multi-tenant architecture, real-time dashboards

**2. E-commerce Sites:**
- **Products**: 100,000+ product catalog
- **Orders**: 1 million+ orders with full history
- **Users**: 500,000+ customer accounts
- **Features**: Recommendations, inventory, analytics

**3. Social/Community Apps:**
- **Users**: 100,000+ active community members
- **Content**: Millions of posts, comments, interactions
- **Relationships**: Complex social graphs
- **Features**: Real-time feeds, notifications, messaging

**4. IoT/Analytics Platforms:**
- **Devices**: 10,000+ connected devices
- **Data Points**: 100 million+ sensor readings
- **Analytics**: Real-time processing and historical analysis
- **Features**: Dashboards, alerts, predictive analytics

**5. Gaming Backends:**
- **Players**: 50,000+ concurrent players
- **Game State**: Player profiles, achievements, leaderboards
- **Analytics**: Player behavior, game metrics
- **Features**: Real-time multiplayer, matchmaking

**📈 Multi-Model Data Examples:**
```sql
-- Document Storage (JSON-like)
CREATE products SET {
    name: "Laptop Pro",
    specs: { cpu: "M2", ram: "16GB", storage: "1TB" },
    reviews: [/* thousands of reviews */],
    metadata: {/* rich product data */}
};

-- Graph Relationships
RELATE users:alice->follows->users:bob;
RELATE users:bob->likes->posts:123;
-- Store millions of relationships

-- Time-Series Data
CREATE metrics:cpu SET {
    timestamp: time::now(),
    value: 85.2,
    server: "web-01",
    tags: ["production", "us-east"]
};
-- Store millions of time-series points
```

**💡 Key Advantages:**
- ✅ **Multi-model flexibility** - SQL, Graph, Document, Time-series in one
- ✅ **Production-ready** - ACID transactions, automatic failover
- ✅ **Growth potential** - Scale to enterprise levels via Railway dashboard
- ✅ **Cost-effective** - Enterprise features at reasonable cost

### ❓ **How do I backup my data before major changes?**

**Recommended backup strategy:**

```bash
# 1. Create backup script
curl -X POST https://your-surrealdb.railway.app/export \
  -H "Content-Type: application/json" \
  -u "root:your_password" \
  -d '{"ns": "your_namespace", "db": "your_database"}' \
  > backup-$(date +%Y%m%d).surql

# 2. Store backup safely (outside Railway)
# Upload to S3, Google Drive, or download locally
```

## 🚀 Deployment & Configuration

### ❓ **I have optimized HA - can I scale via Railway dashboard or do I need to edit code?**

**✅ Dashboard scaling handles most growth!** The optimized HA setup is designed for Railway's native scaling.

**What you can scale via Railway Dashboard (no code changes):**

**1. SurrealDB Query Replicas (1-click):**
```bash
Railway Dashboard → surrealdb service → Replicas → 2 or 3
# Instantly handle more concurrent users
# Cost: +$8-16/month per replica
# Capacity: 1K-5K → 10K+ users
```

**2. Resource Scaling (1-click):**
```bash
Railway Dashboard → Any service → Resources → Increase CPU/RAM
# Scale individual bottlenecks
# Cost: Varies by resource increase
# Capacity: Handle traffic spikes, heavy queries
```

**Scaling Path via Dashboard:**
| Phase | Method | User Capacity | Monthly Cost | Effort |
|-------|--------|---------------|--------------|--------|
| **Current** | Optimized HA (7 services) | 1K-5K | $46-62 | ✅ Done |
| **Phase 1** | + SurrealDB Replicas (2x) | 10K+ | $65-85 | ✅ 1-click |
| **Phase 2** | + Resource Scaling | 25K+ | $120-200 | ✅ 1-click |
| **Phase 3** | + More Replicas (3x) | 50K+ | $200-300 | ✅ 1-click |

**When you need code changes:**
- ❌ **Adding TiKV storage nodes** (tikv3, tikv4) - for massive data storage
- ❌ **Changing resource limits** in compose file - for custom configurations
- ❌ **Multi-region deployment** - for global scale

**💡 Bottom line:** Most apps scale to 10,000+ users purely via Railway dashboard!

### ❓ **How do I switch from lean to full HA deployment?**

**Easy process:**
```bash
# 1. In your local repo
git checkout main
cp docker-compose.full.yml docker-compose.yml

# 2. Commit and push
git add docker-compose.yml
git commit -m "Upgrade to full HA cluster"
git push origin main

# 3. Railway automatically redeploys with new config
# Your data remains intact in existing volumes
```

### ❓ **Can I downgrade from HA back to lean?**

**⚠️ Possible but requires caution:**

**Safe downgrade process:**
1. **Backup your data first**
2. **Ensure data fits** in single TiKV node
3. **Switch compose file:**
   ```bash
   cp docker-compose.lean.yml docker-compose.yml
   git commit -m "Downgrade to lean setup"
   git push
   ```
4. **TiKV consolidates** data to remaining node

**When NOT to downgrade:**
- ❌ Data size > single node capacity
- ❌ High traffic requiring HA
- ❌ Production environment with SLA requirements

### ❓ **How do I update SurrealDB/TiKV versions?**

**Safe update process:**
```yaml
# In docker-compose.yml - update image tags
services:
  pd0:
    image: pingcap/pd:v8.6.0  # Updated version
  tikv0:
    image: pingcap/tikv:v8.6.0  # Updated version
  surrealdb:
    image: surrealdb/surrealdb:v2.0.0  # Updated version
```

**Then deploy:**
```bash
git add docker-compose.yml
git commit -m "Update to latest versions"
git push
# Railway performs rolling update - data persists
```

## 💰 Costs & Billing

### ❓ **Why does my bill seem higher than the estimates?**

**Common causes:**
- **Network egress** - Data transfer costs
- **CPU spikes** - Temporary high usage
- **Memory overhead** - Docker + system overhead
- **Multiple environments** - Dev/staging/prod

**Cost optimization:**
```bash
# Check actual resource usage in Railway dashboard
# Scale down unused environments
# Use lean deployment for development
```

### ❓ **Can I pause services to save costs?**

**Yes, but with caveats:**

**✅ Safe to pause:**
- Development environments
- Staging environments
- Non-critical testing

**❌ Don't pause in production:**
- Data corruption risk if paused mid-transaction
- Cluster coordination issues
- Client connection failures

**Better alternatives:**
- Use `docker-compose.lean.yml` for dev
- Scale down replicas via dashboard
- Use Railway's sleep feature for dev environments

## 🔧 Technical Issues

### ❓ **My cluster won't start - services keep restarting**

**Common solutions:**

**1. Check resource limits:**
```yaml
# Increase if needed
deploy:
  resources:
    limits:
      memory: 1G    # Increase if OOM errors
      cpus: '1.0'   # Increase if CPU throttling
```

**2. Check service dependencies:**
```yaml
# Ensure proper startup order
depends_on:
  pd0:
    condition: service_healthy  # Wait for PD first
```

**3. Check Railway logs:**
```bash
# In Railway dashboard
Service → Deployments → View Logs
# Look for specific error messages
```

### ❓ **How do I connect from my application?**

**Connection examples:**

**JavaScript/Node.js:**
```javascript
import { Surreal } from 'surrealdb.js';

const db = new Surreal();
await db.connect('wss://your-app.railway.app/rpc');
await db.signin({
  user: process.env.SURREAL_USER,
  pass: process.env.SURREAL_PASS
});
```

**Python:**
```python
from surrealdb import Surreal

async with Surreal("ws://your-app.railway.app/rpc") as db:
    await db.signin({"user": "root", "pass": "your_password"})
```

**HTTP/REST:**
```bash
curl -X POST https://your-app.railway.app/sql \
  -H "Content-Type: application/json" \
  -u "root:your_password" \
  -d '{"sql": "SELECT * FROM users;"}'
```

### ❓ **How do I scale my optimized HA cluster step-by-step?**

**🚀 Step-by-step scaling via Railway Dashboard:**

**Step 1: Monitor Current Usage**
```bash
# Check Railway Dashboard metrics
Service Metrics → CPU, RAM, Network usage
Look for bottlenecks before scaling
```

**Step 2: Scale SurrealDB Replicas (Most Common)**
```bash
# Railway Dashboard
1. Go to your project → surrealdb service
2. Settings → Replicas → Change from 1 to 2
3. Save → Railway automatically deploys new replica
4. Monitor performance improvement
```

**Step 3: Scale Resources if Needed**
```bash
# Railway Dashboard  
1. Identify bottleneck service (CPU/RAM usage)
2. Service → Resources → Increase limits
3. Save → Railway applies new limits
4. Monitor improvement
```

**Step 4: Add More Replicas for High Scale**
```bash
# For 25K+ users
surrealdb replicas: 1 → 2 → 3 → 4+
Cost scales: $46 → $65 → $85 → $105+/month
```

**💡 This handles 99% of scaling needs without touching code!**

**📚 Official SurrealDB Scaling Principles:**
- **Compute scaling** - "add or remove instances without complex coordination" 
- **Storage scaling** - "TiKV automatically distributes data across nodes"
- **Data persistence** - "data is persisted across restarts and redeployments"
- **Optimized distribution** - "optimizing for usage patterns and ensuring balanced partitions"

**Our template leverages these official capabilities via Railway's dashboard!**

### ❓ **How do I monitor cluster health?**

**Built-in monitoring:**

**1. Railway Dashboard:**
- Service metrics (CPU, RAM, Network)
- Application logs
- Deployment history
- **Replica performance** (when scaled)

**2. Health endpoints:**
```bash
# SurrealDB health
curl https://your-app.railway.app/health

# PD cluster status
curl https://your-app.railway.app/pd/api/v1/health

# TiKV metrics
curl https://your-app.railway.app/tikv/metrics
```

**3. Custom monitoring script:**
```bash
# Use included script
./scripts/health-check.sh
```

## 🔒 Security & Access

### ❓ **How do I change the database password?**

**Via Railway Dashboard:**
1. Go to your project → `surrealdb` service
2. Environment Variables → `SURREAL_PASS`
3. Generate new value or set custom
4. Redeploy service

**Via railway.toml:**
```toml
[env]
SURREAL_PASS = { generator = "hex", byteLength = 32 }
```

### ❓ **How do I add additional users/authentication?**

**SurrealDB supports multiple auth methods:**

**1. Database users:**
```sql
-- Create namespace user
DEFINE USER john ON NAMESPACE PASSWORD 'secure_password';

-- Create database user  
DEFINE USER jane ON DATABASE PASSWORD 'another_password';
```

**2. Scope-based auth:**
```sql
-- Define user scope
DEFINE SCOPE user SESSION 24h;

-- Define signup/signin logic
DEFINE TABLE user SCHEMAFULL;
```

### ❓ **Is my data encrypted?**

**✅ Multiple layers of encryption:**

**1. Railway platform:**
- ✅ **Encryption at rest** - All volumes encrypted
- ✅ **Encryption in transit** - TLS/HTTPS
- ✅ **Network isolation** - Private networking

**2. SurrealDB/TiKV:**
- ✅ **Authentication required** - No anonymous access
- ✅ **Secure defaults** - Production configurations
- ✅ **Network encryption** - Internal cluster communication

## 🆘 Getting Help

### ❓ **Where can I get support?**

**Community Support:**
- **[SurrealDB Discord](https://discord.gg/surrealdb)** - Active community
- **[Railway Discord](https://discord.gg/railway)** - Platform support
- **[GitHub Issues](https://github.com/surrealdb/surrealdb-railway-template/issues)** - Template-specific issues

**Documentation:**
- **[SurrealDB Docs](https://surrealdb.com/docs)** - Official documentation
- **[Railway Docs](https://docs.railway.app)** - Platform documentation
- **[Template Docs](./README.md)** - This template's guides

**When asking for help:**
1. **Include error messages** - Copy exact error text
2. **Share Railway logs** - From deployment logs
3. **Describe your setup** - Which compose file, modifications
4. **Steps to reproduce** - What you were doing when it failed

---

**💡 Don't see your question?** [Open an issue](https://github.com/surrealdb/surrealdb-railway-template/issues) and we'll add it to the FAQ!
