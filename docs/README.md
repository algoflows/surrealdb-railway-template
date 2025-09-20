# 📚 SurrealDB Railway Template Documentation

## 🚀 Quick Links

### Getting Started
- **[🤔 FAQ](./FAQ.md)** - Frequently asked questions and troubleshooting
- **[Local Development](./LOCAL.md)** - Running the cluster locally

### Deployment
- **[Railway Deployment Guide](./deployment/DEPLOY.md)** - Complete Railway deployment walkthrough
- **[Railway Configuration](./deployment/RAILWAY.md)** - Advanced Railway configuration and tuning

### Scaling & Performance
- **[Cost Analysis](./scaling/COST-ANALYSIS.md)** - Detailed cost breakdown and optimization
- **[HA Scaling Guide](./scaling/HA-SCALING.md)** - High availability scaling strategies  
- **[Lean Scaling Guide](./scaling/LEAN-SCALING.md)** - Budget-friendly scaling approach
- **[Performance Scaling](./scaling/SCALING.md)** - Advanced scaling and performance tuning
- **[Cost Breakdown](./scaling/COST-BREAKDOWN.md)** - Monthly cost forecasts

## 📋 Documentation Structure

```
docs/
├── README.md                    # This file - documentation index
├── FAQ.md                       # Frequently asked questions
├── LOCAL.md                     # Local development setup
├── deployment/
│   ├── DEPLOY.md               # Railway deployment guide
│   └── RAILWAY.md              # Railway configuration
└── scaling/
    ├── COST-ANALYSIS.md        # Cost analysis and optimization
    ├── HA-SCALING.md           # High availability scaling
    ├── LEAN-SCALING.md         # Budget-friendly scaling
    ├── SCALING.md              # Performance scaling
    └── COST-BREAKDOWN.md       # Cost forecasts
```

## 🎯 Getting Started

1. **New to SurrealDB?** Start with the [main README](../README.md)
2. **Have questions?** Check the [FAQ](./FAQ.md) first
3. **Ready to deploy?** Follow the [Railway Deployment Guide](./deployment/DEPLOY.md)
4. **Want to develop locally?** Check the [Local Development Guide](./LOCAL.md)
5. **Planning for scale?** Review the [Cost Analysis](./scaling/COST-ANALYSIS.md)

## 💡 Template Configurations

The template includes several deployment options:

| File | Description | Use Case |
|------|-------------|----------|
| `docker-compose.yml` | **Optimized HA (Default)** | Production-ready HA cluster |
| `docker-compose.lean.yml` | **Lean Start** | Budget-friendly single nodes |
| `docker-compose.full.yml` | **Heavy HA** | Maximum resources HA |
| `docker-compose.ha.yml` | **Minimal HA** | Coordinator HA only |
| `docker-compose.local.yml` | **Local Development** | Local development setup |

## 🔧 Quick Reference

### Default Deployment (Optimized HA)
- **Services**: 7 (3 PD + 3 TiKV + 1 SurrealDB)
- **Resources**: 3.25GB RAM, 3.25 CPU
- **Cost**: ~$46-62/month
- **HA Level**: Any single node can fail

### Scaling Options
- **Vertical**: Increase CPU/RAM via Railway dashboard
- **Horizontal**: Add SurrealDB replicas via Railway dashboard
- **Storage**: Switch compose files for more TiKV nodes
- **Global**: Multi-region deployment

### Support
- **Issues**: [GitHub Issues](https://github.com/surrealdb/surrealdb-railway-template/issues)
- **Community**: [SurrealDB Discord](https://discord.gg/surrealdb)
- **Railway**: [Railway Documentation](https://docs.railway.app)
