#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/migrate.sh <railway-url> <user> <pass> <ns> <db> [file]
# Default file: db/init.surql

URL=${1:-}
USER=${2:-root}
PASS=${3:-}
NS=${4:-app}
DB=${5:-app}
FILE=${6:-db/init.surql}

if [[ -z "$URL" || -z "$PASS" ]]; then
  echo "Usage: $0 <railway-url> <user> <pass> <ns> <db> [file]" >&2
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Migration file not found: $FILE" >&2
  exit 1
fi

echo "Applying migrations from $FILE to ns=$NS db=$DB on $URL ..."
curl -fsSL -X POST "$URL/sql" \
  -H "Content-Type: application/json" \
  -u "$USER:$PASS" \
  --data-binary @<(jq -Rs --arg ns "$NS" --arg db "$DB" '{sql:("USE NS " + $ns + "; USE DB " + $db + "; " + .)}' "$FILE") \
  > /dev/null

echo "Migrations applied."

