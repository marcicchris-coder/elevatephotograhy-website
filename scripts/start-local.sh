#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_DIR="$ROOT_DIR/.pids"
LOG_DIR="$ROOT_DIR/logs"
API_PID_FILE="$PID_DIR/api.pid"
ENV_FILE="$ROOT_DIR/api/.env"

read_env_value() {
  local key="$1"
  local file="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi

  awk -F= -v k="$key" '
    $0 !~ /^[[:space:]]*#/ && $1 ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*$/ {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
      if ($1 == k) {
        sub(/^[^=]*=/, "", $0)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0
      }
    }
  ' "$file" | tail -n 1
}

ENV_HOST="$(read_env_value HOST "$ENV_FILE")"
ENV_PORT="$(read_env_value PORT "$ENV_FILE")"
API_HOST="${HOST:-${ENV_HOST:-127.0.0.1}}"
API_PORT="${PORT:-${ENV_PORT:-8788}}"

mkdir -p "$PID_DIR" "$LOG_DIR"

is_running() {
  local pid_file="$1"
  if [[ -f "$pid_file" ]]; then
    local pid
    pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

start_api() {
  if is_running "$API_PID_FILE"; then
    echo "API already running (PID $(cat "$API_PID_FILE"))."
  else
    (
      cd "$ROOT_DIR"
      HOST="$API_HOST" PORT="$API_PORT" nohup node api/server.js >> "$LOG_DIR/api.log" 2>&1 < /dev/null &
      echo "$!" > "$API_PID_FILE"
    )

    local pid
    pid="$(cat "$API_PID_FILE")"
    sleep 0.5
    if kill -0 "$pid" 2>/dev/null; then
      echo "Started API on http://$API_HOST:$API_PORT (PID $pid)."
    else
      echo "API failed to start. Check $LOG_DIR/api.log"
      rm -f "$API_PID_FILE"
      return 1
    fi
  fi
}

start_api

echo ""
echo "Main site: http://$API_HOST:$API_PORT"
echo "Portfolio: http://$API_HOST:$API_PORT/portfolio.html"
echo "Order: http://$API_HOST:$API_PORT/order.html"
echo ""
echo "Logs:"
echo "- $LOG_DIR/api.log"
