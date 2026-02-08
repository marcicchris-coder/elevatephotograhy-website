#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_DIR="$ROOT_DIR/.pids"
LOG_DIR="$ROOT_DIR/logs"
API_PID_FILE="$PID_DIR/api.pid"
WEB_PID_FILE="$PID_DIR/web.pid"
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

start_web() {
  if is_running "$WEB_PID_FILE"; then
    echo "Web server already running (PID $(cat "$WEB_PID_FILE"))."
  else
    (
      cd "$ROOT_DIR"
      python3 -m http.server 8000 >> "$LOG_DIR/web.log" 2>&1
    ) &
    echo "$!" > "$WEB_PID_FILE"
    echo "Started web server on http://localhost:8000 (PID $!)."
  fi
}

start_api
start_web

echo ""
echo "Main site: http://localhost:8000"
echo "Portfolio: http://localhost:8000/portfolio.html"
echo "Order: http://localhost:8000/order.html"
echo ""
echo "Logs:"
echo "- $LOG_DIR/api.log"
echo "- $LOG_DIR/web.log"
