# Multi-stage build for SurrealDB cluster deployment
FROM surrealdb/surrealdb:latest as surrealdb

# Use a minimal base image for the final stage
FROM alpine:latest

# Install required dependencies
RUN apk add --no-cache \
    curl \
    jq \
    bash

# Copy SurrealDB binary
COPY --from=surrealdb /surreal /usr/local/bin/surreal

# Create directories for data and logs
RUN mkdir -p /data /logs && \
    chmod 755 /data /logs

# Set working directory
WORKDIR /app

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose SurrealDB port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Use the startup script as entrypoint
ENTRYPOINT ["/app/start.sh"]
