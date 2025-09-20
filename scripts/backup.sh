#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/backup.sh <railway-url> <user> <pass> <ns> <db> [outdir]
# Example: ./scripts/backup.sh https://your-app.up.railway.app root "$SURREAL_PASS" app app ./backups

URL=${1:-}
USER=${2:-root}
PASS=${3:-}
NS=${4:-app}
DB=${5:-app}
OUTDIR=${6:-./backups}

if [[ -z "$URL" || -z "$PASS" ]]; then
  echo "Usage: $0 <railway-url> <user> <pass> <ns> <db> [outdir]" >&2
  exit 1
fi

mkdir -p "$OUTDIR"
STAMP=$(date +%Y%m%d-%H%M%S)
OUTFILE="$OUTDIR/backup-${NS}-${DB}-${STAMP}.surql"

echo "Exporting SurrealDB ns=$NS db=$DB from $URL ..."
curl -fsSL -X POST "$URL/sql" \
  -H "Content-Type: application/json" \
  -u "$USER:$PASS" \
  -d "{\"sql\": \"USE NS ${NS}; USE DB ${DB}; EXPORT FOR DB;\"}" \
  > "$OUTFILE"

echo "Backup written to $OUTFILE"

