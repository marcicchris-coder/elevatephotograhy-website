#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_DIR="$ROOT_DIR/.pids"
LOG_DIR="$ROOT_DIR/logs"
API_PID_FILE="$PID_DIR/api.pid"
API_HOST="${HOST:-127.0.0.1}"
API_PORT="${PORT:-8788}"

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
      node api/server.js >> "$LOG_DIR/api.log" 2>&1
    ) &
    echo "$!" > "$API_PID_FILE"
    echo "Started API on http://$API_HOST:$API_PORT (PID $!)."
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
