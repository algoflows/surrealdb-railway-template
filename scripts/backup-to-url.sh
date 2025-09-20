#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/backup-to-url.sh <railway-url> <user> <pass> <ns> <db> <presigned_url>
# Exports DB and uploads to a pre-signed URL (S3/GCS/Blob) via HTTP PUT

URL=${1:-}
USER=${2:-root}
PASS=${3:-}
NS=${4:-app}
DB=${5:-app}
DEST=${6:-}

if [[ -z "$URL" || -z "$PASS" || -z "$DEST" ]]; then
  echo "Usage: $0 <railway-url> <user> <pass> <ns> <db> <presigned_url>" >&2
  exit 1
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

echo "Exporting SurrealDB ns=$NS db=$DB from $URL ..."
curl -fsSL -X POST "$URL/sql" \
  -H "Content-Type: application/json" \
  -u "$USER:$PASS" \
  -d "{\"sql\": \"USE NS ${NS}; USE DB ${DB}; EXPORT FOR DB;\"}" \
  > "$TMP"

echo "Uploading backup to destination ..."
curl -fsSL -X PUT -H "Content-Type: application/octet-stream" --upload-file "$TMP" "$DEST"

echo "Backup uploaded successfully."

