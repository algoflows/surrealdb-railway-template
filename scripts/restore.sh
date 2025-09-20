#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/restore.sh <railway-url> <user> <pass> <ns> <db> <backup_file>

URL=${1:-}
USER=${2:-root}
PASS=${3:-}
NS=${4:-app}
DB=${5:-app}
BACKUP=${6:-}

if [[ -z "$URL" || -z "$PASS" || -z "$BACKUP" ]]; then
  echo "Usage: $0 <railway-url> <user> <pass> <ns> <db> <backup_file>" >&2
  exit 1
fi

echo "Restoring $BACKUP to ns=$NS db=$DB on $URL ..."
curl -fsSL -X POST "$URL/sql" \
  -H "Content-Type: application/json" \
  -u "$USER:$PASS" \
  --data-binary @<(jq -Rs --arg ns "$NS" --arg db "$DB" '{sql:("USE NS " + $ns + "; USE DB " + $db + "; " + .)}' "$BACKUP") \
  >/dev/null

echo "Restore completed."

