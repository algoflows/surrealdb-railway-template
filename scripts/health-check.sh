#!/bin/bash
set -e

# SurrealDB Cluster Health Check Script
# This script checks the health of all cluster components

echo "🏥 SurrealDB Cluster Health Check"
echo "=================================="

# Configuration
SURREALDB_URL=${SURREALDB_URL:-"http://localhost:8000"}
SURREAL_USER=${SURREAL_USER:-"root"}
SURREAL_PASS=${SURREAL_PASS:-"root"}
PD_ENDPOINTS=${PD_ENDPOINTS:-"pd0:2379,pd1:2379,pd2:2379"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Health check functions
check_surrealdb() {
    echo -n "🔍 Checking SurrealDB... "
    
    if curl -sf "$SURREALDB_URL/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Healthy${NC}"
        
        # Check database connectivity
        echo -n "🔗 Testing database connection... "
        response=$(curl -s -X POST "$SURREALDB_URL/sql" \
            -H "Content-Type: application/json" \
            -u "$SURREAL_USER:$SURREAL_PASS" \
            -d '{"sql": "INFO FOR DB;"}' 2>/dev/null)
        
        if echo "$response" | grep -q "result"; then
            echo -e "${GREEN}✅ Connected${NC}"
            return 0
        else
            echo -e "${RED}❌ Connection failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Unhealthy${NC}"
        return 1
    fi
}

check_pd_cluster() {
    echo -n "🎯 Checking PD cluster... "
    
    # Try to connect to each PD node
    healthy_nodes=0
    total_nodes=3
    
    for pd in pd0 pd1 pd2; do
        if command -v docker >/dev/null 2>&1; then
            # If running in Docker environment
            if docker compose exec -T "$pd" /pd-ctl cluster status >/dev/null 2>&1; then
                ((healthy_nodes++))
            fi
        else
            # If running in Railway or other environment
            if curl -sf "http://$pd:2379/health" >/dev/null 2>&1; then
                ((healthy_nodes++))
            fi
        fi
    done
    
    if [ $healthy_nodes -eq $total_nodes ]; then
        echo -e "${GREEN}✅ All nodes healthy ($healthy_nodes/$total_nodes)${NC}"
        return 0
    elif [ $healthy_nodes -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Partial cluster ($healthy_nodes/$total_nodes)${NC}"
        return 1
    else
        echo -e "${RED}❌ Cluster down${NC}"
        return 1
    fi
}

check_tikv_cluster() {
    echo -n "💾 Checking TiKV cluster... "
    
    # Try to connect to each TiKV node
    healthy_nodes=0
    total_nodes=3
    
    for tikv in tikv0 tikv1 tikv2; do
        if command -v docker >/dev/null 2>&1; then
            # If running in Docker environment
            if docker compose exec -T "$tikv" /tikv-ctl --host "$tikv:20160" cluster >/dev/null 2>&1; then
                ((healthy_nodes++))
            fi
        else
            # If running in Railway or other environment
            if curl -sf "http://$tikv:20180/metrics" >/dev/null 2>&1; then
                ((healthy_nodes++))
            fi
        fi
    done
    
    if [ $healthy_nodes -eq $total_nodes ]; then
        echo -e "${GREEN}✅ All nodes healthy ($healthy_nodes/$total_nodes)${NC}"
        return 0
    elif [ $healthy_nodes -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Partial cluster ($healthy_nodes/$total_nodes)${NC}"
        return 1
    else
        echo -e "${RED}❌ Cluster down${NC}"
        return 1
    fi
}

get_cluster_metrics() {
    echo "📊 Cluster Metrics"
    echo "=================="
    
    # SurrealDB metrics
    echo -n "🔢 Database info: "
    db_info=$(curl -s -X POST "$SURREALDB_URL/sql" \
        -H "Content-Type: application/json" \
        -u "$SURREAL_USER:$SURREAL_PASS" \
        -d '{"sql": "INFO FOR DB;"}' 2>/dev/null)
    
    if echo "$db_info" | grep -q "result"; then
        echo -e "${GREEN}Available${NC}"
    else
        echo -e "${RED}Unavailable${NC}"
    fi
    
    # Memory and CPU usage (if available)
    if command -v docker >/dev/null 2>&1; then
        echo "🖥️  Container resource usage:"
        docker compose ps --format "table {{.Service}}\t{{.Status}}" 2>/dev/null || true
    fi
}

# Main health check
main() {
    local exit_code=0
    
    # Check all components
    check_surrealdb || exit_code=1
    check_pd_cluster || exit_code=1
    check_tikv_cluster || exit_code=1
    
    echo ""
    get_cluster_metrics
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}🎉 Overall Status: Healthy${NC}"
    else
        echo -e "${RED}⚠️  Overall Status: Issues Detected${NC}"
    fi
    
    echo "=================================="
    echo "Health check completed at $(date)"
    
    exit $exit_code
}

# Run health check
main "$@"
