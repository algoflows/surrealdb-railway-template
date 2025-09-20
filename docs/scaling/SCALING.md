# 📈 SurrealDB Cluster Scaling Guide

## 🏗️ Architecture Explained

### Node Types & Roles

**🎯 PD Nodes (Placement Driver)**
- **Purpose**: Cluster coordination, metadata management, load balancing
- **Count**: 3 nodes (pd0, pd1, pd2) for high availability
- **Resources**: 512MB RAM, 0.5 CPU each
- **Role**: "Brain" of the cluster - decides where data goes, manages cluster topology

**💾 TiKV Nodes (Storage)**
- **Purpose**: Distributed storage backend with Raft consensus
- **Count**: 3 nodes (tikv0, tikv1, tikv2) for data replication
- **Resources**: 1GB RAM, 1.0 CPU each
- **Role**: "Muscle" of the cluster - stores data, handles replication, ensures ACID

**🔍 SurrealDB Node (Query Engine)**
- **Purpose**: SQL/NoSQL query processing, API endpoints, client connections
- **Count**: 1 node (horizontally scalable)
- **Resources**: 2GB RAM, 2.0 CPU
- **Role**: "Interface" of the cluster - processes queries, manages connections

### Why This Architecture?

```
Client Request → SurrealDB → TiKV (via PD coordination) → Data Storage
     ↑              ↑           ↑                           ↑
   API Layer    Query Engine  Storage Layer            Persistence
```

- **Separation of Concerns**: Query processing vs storage vs coordination
- **Independent Scaling**: Scale query capacity without affecting storage
- **High Availability**: Any single node can fail without data loss
- **ACID Compliance**: Distributed transactions across the cluster

## 📊 Scaling Performance Numbers

### Current Template Configuration

| Component | Count | Resources | Total |
|-----------|-------|-----------|-------|
| PD Nodes | 3 | 512MB, 0.5 CPU | 1.5GB, 1.5 CPU |
| TiKV Nodes | 3 | 1GB, 1.0 CPU | 3GB, 3.0 CPU |
| SurrealDB | 1 | 2GB, 2.0 CPU | 2GB, 2.0 CPU |
| **Total** | **7** | | **6.5GB, 6.5 CPU** |

### Estimated Performance (Current Config)

**Concurrent Connections:**
- **Light queries**: ~1,000-2,000 concurrent connections
- **Mixed workload**: ~500-1,000 concurrent connections  
- **Heavy analytics**: ~100-500 concurrent connections

**Throughput:**
- **Simple reads**: ~10,000-20,000 QPS
- **Simple writes**: ~5,000-10,000 QPS
- **Complex queries**: ~1,000-5,000 QPS
- **Graph traversals**: ~500-2,000 QPS

**Data Capacity:**
- **Storage**: ~100GB-1TB (depends on Railway volume limits)
- **Memory cache**: ~6GB effective caching
- **Replication**: 3x redundancy (data stored on all TiKV nodes)

## 🚀 Scaling Strategies

### 1. Vertical Scaling (Scale Up)

**SurrealDB Query Engine Scaling:**
```yaml
# Edit docker-compose.yml
surrealdb:
  deploy:
    resources:
      limits:
        memory: 8G      # 4x increase
        cpus: '8.0'     # 4x increase
```

**Expected Performance Increase:**
- **Concurrent connections**: 4,000-8,000
- **Query throughput**: 40,000-80,000 QPS (simple reads)
- **Complex query performance**: 3-4x improvement

**TiKV Storage Scaling:**
```yaml
tikv0, tikv1, tikv2:
  deploy:
    resources:
      limits:
        memory: 4G      # 4x increase
        cpus: '4.0'     # 4x increase
```

**Expected Storage Performance:**
- **Write throughput**: 20,000-40,000 QPS
- **Storage capacity**: 1TB-10TB
- **Cache hit ratio**: Significant improvement

### 2. Horizontal Scaling (Scale Out)

**Add More SurrealDB Query Engines:**
```yaml
# Railway Dashboard: Increase replicas to 3
services:
  surrealdb:
    replicas: 3  # 3x query processing power
```

**Performance with 3 SurrealDB Replicas:**
- **Total concurrent connections**: 3,000-6,000
- **Aggregate throughput**: 30,000-60,000 QPS
- **Load distribution**: Railway auto-balances requests

**Add More TiKV Storage Nodes:**
```yaml
# Add tikv3, tikv4, tikv5 for 6-node storage cluster
tikv3:
  image: pingcap/tikv:v8.5.0
  # Same config as tikv0-2
```

**Performance with 6 TiKV Nodes:**
- **Storage capacity**: 2x increase
- **Read performance**: ~50% improvement (more replicas)
- **Write performance**: ~30% improvement (more distribution)

### 3. Railway-Specific Scaling

**Railway Pro Plan Limits:**
- **Per Service**: Up to 32 vCPU, 32GB RAM
- **Replicas**: Up to 20 per service
- **Multi-region**: Deploy across different regions

**Maximum Theoretical Scale (Railway Pro):**

| Service | Max Resources | Max Replicas | Total Capacity |
|---------|---------------|--------------|----------------|
| SurrealDB | 32 vCPU, 32GB | 20 | 640 vCPU, 640GB |
| TiKV (each) | 32 vCPU, 32GB | 5 | 480 vCPU, 480GB |
| PD (each) | 8 vCPU, 8GB | 3 | 72 vCPU, 72GB |

**Estimated Max Performance:**
- **Concurrent connections**: 50,000-100,000+
- **Query throughput**: 500,000-1,000,000+ QPS
- **Data capacity**: 10TB-100TB+
- **Global latency**: <100ms with multi-region

## ⚙️ Railway Configuration Updates

### What Can Be Updated via Railway Dashboard?

**✅ Can Update After Deployment:**
- **Environment variables** (SURREAL_LOG_LEVEL, etc.)
- **Replica count** (horizontal scaling)
- **Resource limits** (if using Railway's resource controls)
- **Domains and networking**
- **Volume mounts** (add new volumes)

**❌ Cannot Update via Dashboard:**
- **Docker Compose service definitions** (requires redeployment)
- **Container images** (requires redeployment)  
- **Port mappings** (requires redeployment)
- **Command arguments** (requires redeployment)

### How to Update Configuration

**Environment Variables (Easy):**
```bash
# Via Railway Dashboard
Settings → Variables → Add/Edit

# Via Railway CLI
railway variables set SURREAL_LOG_LEVEL=debug
railway variables set TIKV_LOG_LEVEL=trace
```

**Resource Scaling (Easy):**
```bash
# Via Railway Dashboard
Service → Settings → Resources → Adjust CPU/Memory

# Via Railway CLI  
railway service scale --replicas 3
```

**Docker Compose Changes (Requires Redeployment):**
```bash
# 1. Fork the template repository
# 2. Edit docker-compose.yml
# 3. Commit changes
# 4. Railway auto-deploys from Git
# OR manually redeploy:
railway up
```

## 🎯 Scaling Recommendations

### Small Applications (< 1,000 users)
- **Keep default configuration**
- **Monitor Railway metrics**
- **Scale SurrealDB vertically first**

### Medium Applications (1,000-10,000 users)  
- **Scale SurrealDB to 4GB RAM, 4 CPU**
- **Add 1-2 SurrealDB replicas**
- **Monitor TiKV performance**

### Large Applications (10,000+ users)
- **Scale all components vertically**
- **Add multiple SurrealDB replicas**
- **Consider adding more TiKV nodes**
- **Use Railway multi-region deployment**

### Enterprise Applications
- **Contact Railway for Enterprise plan**
- **Custom resource limits**
- **Dedicated infrastructure**
- **Professional support**

## 📊 Monitoring Scaling

### Key Metrics to Watch

**SurrealDB Metrics:**
- Connection count
- Query latency (p95, p99)
- CPU and memory usage
- Error rates

**TiKV Metrics:**
- Storage usage
- Read/write latency
- Raft consensus health
- Disk I/O

**Railway Metrics:**
- Service health
- Resource utilization
- Request distribution
- Regional performance

### Scaling Triggers

**Scale Up When:**
- CPU usage > 70% consistently
- Memory usage > 80%
- Query latency > 100ms p95
- Connection errors increasing

**Scale Out When:**
- Single service at resource limits
- Need geographic distribution
- Require higher availability
- Traffic patterns are distributed

## 🔧 Implementation Example

### Scaling from Default to High-Performance

**Step 1: Vertical Scaling (via Railway Dashboard)**
```bash
# SurrealDB: 2GB → 8GB RAM, 2 → 8 CPU
# TiKV nodes: 1GB → 4GB RAM, 1 → 4 CPU each
# Expected: 4x performance improvement
```

**Step 2: Horizontal Scaling (via Railway Dashboard)**
```bash
# Add 2 more SurrealDB replicas (3 total)
# Expected: 3x query processing capacity
```

**Step 3: Storage Scaling (requires redeployment)**
```yaml
# Add tikv3, tikv4, tikv5 in docker-compose.yml
# Expected: 2x storage capacity, improved read performance
```

**Result: 12x Performance Improvement**
- From: 1,000 concurrent users
- To: 12,000+ concurrent users
- Cost: ~3-4x Railway resource usage

---

**💡 Pro Tip: Start with vertical scaling (easier via Railway dashboard), then move to horizontal scaling as needed. Monitor Railway metrics to make data-driven scaling decisions.**
