#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
OUT_FILE="$ROOT_DIR/ios/Flutter/Maps.xcconfig"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "GOOGLE_MAPS_IOS_KEY=" > "$OUT_FILE"
  echo "Warning: .env not found. Created empty $OUT_FILE"
  exit 0
fi

KEY="$(grep -E '^GOOGLE_MAPS_IOS_KEY=' "$ENV_FILE" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '"' | tr -d "'" || true)"

if [[ -z "$KEY" ]]; then
  echo "GOOGLE_MAPS_IOS_KEY=" > "$OUT_FILE"
  echo "Warning: GOOGLE_MAPS_IOS_KEY missing in .env"
  exit 0
fi

printf 'GOOGLE_MAPS_IOS_KEY=%s\n' "$KEY" > "$OUT_FILE"
echo "Synced GOOGLE_MAPS_IOS_KEY to ios/Flutter/Maps.xcconfig"
