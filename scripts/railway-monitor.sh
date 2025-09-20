#!/bin/bash
set -e

# Railway-specific monitoring script
# This script outputs structured logs that Railway can parse and display in dashboards

# Configuration
SURREALDB_URL=${SURREALDB_URL:-"http://localhost:8000"}
SURREAL_USER=${SURREAL_USER:-"root"}
SURREAL_PASS=${SURREAL_PASS:-"root"}

# Structured logging function for Railway
log_metric() {
    local metric_name="$1"
    local metric_value="$2"
    local metric_type="${3:-gauge}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"info\",\"metric\":\"$metric_name\",\"value\":$metric_value,\"type\":\"$metric_type\",\"service\":\"surrealdb-monitor\"}"
}

log_event() {
    local event_type="$1"
    local message="$2"
    local level="${3:-info}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"event\":\"$event_type\",\"message\":\"$message\",\"service\":\"surrealdb-monitor\"}"
}

# Health check functions
check_surrealdb_health() {
    local start_time=$(date +%s%N)
    
    if response=$(curl -sf "$SURREALDB_URL/health" 2>/dev/null); then
        local end_time=$(date +%s%N)
        local response_time=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
        
        log_metric "surrealdb_health_check" 1 "gauge"
        log_metric "surrealdb_response_time_ms" "$response_time" "gauge"
        log_event "health_check" "SurrealDB health check passed" "info"
        return 0
    else
        log_metric "surrealdb_health_check" 0 "gauge"
        log_event "health_check" "SurrealDB health check failed" "error"
        return 1
    fi
}

check_database_connectivity() {
    local start_time=$(date +%s%N)
    
    if response=$(curl -s -X POST "$SURREALDB_URL/sql" \
        -H "Content-Type: application/json" \
        -u "$SURREAL_USER:$SURREAL_PASS" \
        -d '{"sql": "SELECT count() FROM (SELECT 1 as test);"}' 2>/dev/null); then
        
        local end_time=$(date +%s%N)
        local query_time=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
        
        if echo "$response" | grep -q "result"; then
            log_metric "surrealdb_connectivity" 1 "gauge"
            log_metric "surrealdb_query_time_ms" "$query_time" "gauge"
            log_event "connectivity_check" "Database connectivity test passed" "info"
            return 0
        else
            log_metric "surrealdb_connectivity" 0 "gauge"
            log_event "connectivity_check" "Database connectivity test failed - invalid response" "error"
            return 1
        fi
    else
        log_metric "surrealdb_connectivity" 0 "gauge"
        log_event "connectivity_check" "Database connectivity test failed - request failed" "error"
        return 1
    fi
}

get_database_info() {
    if db_info=$(curl -s -X POST "$SURREALDB_URL/sql" \
        -H "Content-Type: application/json" \
        -u "$SURREAL_USER:$SURREAL_PASS" \
        -d '{"sql": "INFO FOR DB;"}' 2>/dev/null); then
        
        if echo "$db_info" | grep -q "result"; then
            # Extract table count (simplified)
            local table_count=$(echo "$db_info" | grep -o '"tb"' | wc -l || echo 0)
            log_metric "surrealdb_table_count" "$table_count" "gauge"
            log_event "database_info" "Retrieved database information successfully" "info"
        else
            log_event "database_info" "Failed to retrieve database information" "warning"
        fi
    else
        log_event "database_info" "Failed to connect for database information" "error"
    fi
}

# Performance monitoring
monitor_performance() {
    # Test query performance with a simple operation
    local start_time=$(date +%s%N)
    
    if response=$(curl -s -X POST "$SURREALDB_URL/sql" \
        -H "Content-Type: application/json" \
        -u "$SURREAL_USER:$SURREAL_PASS" \
        -d '{"sql": "SELECT math::rand() as random_value;"}' 2>/dev/null); then
        
        local end_time=$(date +%s%N)
        local execution_time=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
        
        log_metric "surrealdb_query_performance_ms" "$execution_time" "gauge"
        
        if [ "$execution_time" -gt 1000 ]; then
            log_event "performance_alert" "Query execution time is high: ${execution_time}ms" "warning"
        fi
    fi
}

# Main monitoring loop
main() {
    log_event "monitor_start" "SurrealDB Railway monitoring started" "info"
    
    while true; do
        # Run health checks
        check_surrealdb_health
        check_database_connectivity
        get_database_info
        monitor_performance
        
        # Log system metrics (if available)
        if command -v free >/dev/null 2>&1; then
            local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
            log_metric "system_memory_usage_percent" "$memory_usage" "gauge"
        fi
        
        # Wait before next check
        sleep 30
    done
}

# Handle signals gracefully
trap 'log_event "monitor_stop" "SurrealDB Railway monitoring stopped" "info"; exit 0' SIGTERM SIGINT

# Start monitoring if script is run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
