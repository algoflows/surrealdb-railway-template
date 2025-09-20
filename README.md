# SurrealDB Railway Template 🚂

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/surrealdb-cluster)

A production-ready SurrealDB cluster template optimized for Railway deployment with TiKV backend for high availability and scalability.

## ✨ Features

- 🚀 **One-click Railway deployment**
- 🔒 **Auto-generated secure passwords**
- 💾 **Persistent storage with TiKV cluster**
- 🏥 **Health checks and monitoring**
- 📈 **Horizontally scalable**
- 🔄 **High availability (3-node cluster)**
- 🐳 **Local development support**

## 🚀 Quick Deploy

### Railway (Production)
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/surrealdb-cluster)

### Local Development
```bash
# Clone the template
git clone https://github.com/your-username/surrealdb-railway-template.git
cd surrealdb-railway-template

# Single-node development
docker compose -f docker-compose.simple.yml up -d

# Full cluster development  
docker compose up -d
```

## 🏗️ Architecture

### Railway Deployment (Single-Node)
- **SurrealDB**: Main database service
- **Storage**: Persistent Railway volumes
- **Networking**: Automatic Railway networking

### Local Cluster Development
- **3 PD nodes**: Placement Driver for coordination
- **3 TiKV nodes**: Distributed storage backend
- **1 SurrealDB node**: Database interface

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `SURREAL_USER` | Database username | `root` | ✅ |
| `SURREAL_PASS` | Database password | Auto-generated | ✅ |
| `SURREAL_LOG_LEVEL` | Log level | `info` | ❌ |
| `PORT` | Service port | `8000` | ❌ |

### Railway Setup
1. Click the deploy button above
2. Configure environment variables (password auto-generated)
3. Wait for deployment to complete
4. Connect using the provided Railway URL

## 📡 Connection

### Railway Production
```bash
# HTTP API
curl -X POST https://your-service.railway.app/sql \
  -H "Content-Type: application/json" \
  -u "root:your_password" \
  -d '{"sql": "INFO FOR DB;"}'

# WebSocket
wss://your-service.railway.app/rpc
```

### Local Development
```bash
# HTTP API
curl -X POST http://localhost:8000/sql \
  -H "Content-Type: application/json" \
  -u "root:root" \
  -d '{"sql": "INFO FOR DB;"}'

# WebSocket  
ws://localhost:8000/rpc
```

## 📚 Documentation

- [Railway Deployment Guide](./RAILWAY.md) - Complete Railway setup
- [Local Development](./docs/LOCAL.md) - Local cluster setup
- [API Examples](./examples/) - Connection examples
- [Troubleshooting](./docs/TROUBLESHOOTING.md) - Common issues

## 🛠️ Development

### Prerequisites
- Docker & Docker Compose
- Railway CLI (for deployment)

### Local Setup
```bash
# Start development cluster
docker compose up -d

# Check cluster health
docker compose ps
docker compose logs surrealdb

# Stop cluster
docker compose down
```

### Testing
```bash
# Test single-node deployment
docker compose -f docker-compose.simple.yml up -d

# Test Railway-style deployment
docker build -t surrealdb-test .
docker run -p 8000:8000 -e SURREAL_USER=root -e SURREAL_PASS=test surrealdb-test
```

## 🚀 Deployment Options

| Option | Use Case | Complexity | Availability |
|--------|----------|------------|--------------|
| Railway Template | Production | Low | High |
| Railway Manual | Custom setup | Medium | High |
| Docker Compose | Development | Low | Medium |
| Kubernetes | Enterprise | High | Very High |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Links

- [SurrealDB Documentation](https://surrealdb.com/docs)
- [Railway Documentation](https://docs.railway.app)
- [TiKV Documentation](https://tikv.org/docs)
- [Template Issues](https://github.com/your-username/surrealdb-railway-template/issues)

---

**Made with ❤️ for the SurrealDB and Railway communities**