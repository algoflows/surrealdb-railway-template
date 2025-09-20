#!/usr/bin/env bash
set -euo pipefail

# Reports PD/TiKV volume usage with 80%/90% warnings

threshold_warn=80
threshold_crit=90

check() {
  local name=$1 path=$2
  if [[ -d "$path" ]]; then
    local used total pct
    used=$(du -sh "$path" 2>/dev/null | awk '{print $1}')
    total=$(df -h "$path" 2>/dev/null | awk 'NR==2{print $2}')
    pct=$(df -h "$path" 2>/dev/null | awk 'NR==2{gsub("%","",$5); print $5}')
    echo "$name: used=$used total=$total (${pct}%) path=$path"
    if (( pct >= threshold_crit )); then
      echo "CRITICAL: $name at ${pct}%" >&2
    elif (( pct >= threshold_warn )); then
      echo "WARNING: $name at ${pct}%" >&2
    fi
  else
    echo "$name: path not found ($path)"
  fi
}

# Default local paths for docker-compose.local; adjust for Railway shell usage
check pd0_data ./pd0_data
check pd1_data ./pd1_data
check pd2_data ./pd2_data
check tikv0_data ./tikv0_data
check tikv1_data ./tikv1_data
check tikv2_data ./tikv2_data

echo "Tip: On Railway, run per service with 'railway shell' and check mount points."

