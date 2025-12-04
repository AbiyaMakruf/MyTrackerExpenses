#!/usr/bin/env bash
set -euo pipefail

# Location setup
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
ENV_FILE="${ENV_FILE:-"$ROOT_DIR/.env"}"
BACKUP_DIR="$ROOT_DIR/backup-db"

# Ensure pg_dump is available
if ! command -v pg_dump >/dev/null 2>&1; then
  echo "Error: pg_dump not found. Install PostgreSQL client tools first." >&2
  exit 1
fi

# Load database config
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: environment file not found at $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

PG_URI="${DB_URL:-}"
if [[ -z "$PG_URI" ]]; then
  DB_USER="${DB_USERNAME:-postgres}"
  DB_PASS="${DB_PASSWORD:-}"
  DB_HOST="${DB_HOST:-localhost}"
  DB_PORT="${DB_PORT:-5432}"
  DB_NAME="${DB_DATABASE:-postgres}"
  PG_URI="postgresql://${DB_USER}${DB_PASS:+:${DB_PASS}}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
fi

mkdir -p "$BACKUP_DIR"

TIMESTAMP="$(date +"%Y%m%d%H%M%S")"
BACKUP_FILE="$BACKUP_DIR/dump-${DB_DATABASE:-database}-${TIMESTAMP}.sql"

if [[ -e "$BACKUP_FILE" ]]; then
  echo "Refusing to overwrite existing backup at $BACKUP_FILE" >&2
  exit 1
fi

PGSSLMODE_VALUE="${PGSSLMODE:-require}"

PGSSLMODE="$PGSSLMODE_VALUE" pg_dump --no-owner --no-privileges "$PG_URI" > "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"
