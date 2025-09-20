#!/bin/bash
set -e

# Default values
SURREAL_USER=${SURREAL_USER:-root}
SURREAL_PASS=${SURREAL_PASS:-root}
SURREAL_LOG_LEVEL=${SURREAL_LOG_LEVEL:-info}
PORT=${PORT:-8000}

# Check if we're running in Railway (has RAILWAY_STATIC_URL)
if [ -n "$RAILWAY_STATIC_URL" ]; then
    echo "🚂 Detected Railway deployment"
    
    # For Railway, we'll use a simplified single-node setup
    # since Railway doesn't support multi-container deployments well
    echo "🗄️  Starting SurrealDB in single-node mode for Railway..."
    
    exec /usr/local/bin/surreal start \
        --log="$SURREAL_LOG_LEVEL" \
        --user="$SURREAL_USER" \
        --pass="$SURREAL_PASS" \
        --bind="0.0.0.0:$PORT" \
        file:/data/database.db
else
    echo "🐳 Detected local/Docker deployment"
    echo "💡 Use docker-compose for full cluster setup"
    
    # For local development, also use single-node
    exec /usr/local/bin/surreal start \
        --log="$SURREAL_LOG_LEVEL" \
        --user="$SURREAL_USER" \
        --pass="$SURREAL_PASS" \
        --bind="0.0.0.0:$PORT" \
        file:/data/database.db
fi
