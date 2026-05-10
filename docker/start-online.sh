#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:99}"
export WITSY_HOME="${WITSY_HOME:-/data/witsy}"
export HOME="${HOME:-/data/home}"
export NOVNC_PORT="${NOVNC_PORT:-8080}"
export VNC_PORT="${VNC_PORT:-5900}"
export SCREEN_WIDTH="${SCREEN_WIDTH:-1440}"
export SCREEN_HEIGHT="${SCREEN_HEIGHT:-900}"
export SCREEN_DEPTH="${SCREEN_DEPTH:-24}"

mkdir -p "$WITSY_HOME" "$HOME"

cleanup() {
  jobs -pr | xargs -r kill 2>/dev/null || true
}
trap cleanup EXIT INT TERM

Xvfb "$DISPLAY" -screen 0 "${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}" -nolisten tcp &
fluxbox >/tmp/fluxbox.log 2>&1 &
x11vnc -display "$DISPLAY" -rfbport "$VNC_PORT" -forever -shared -nopw -quiet >/tmp/x11vnc.log 2>&1 &
websockify --web=/usr/share/novnc "0.0.0.0:${NOVNC_PORT}" "localhost:${VNC_PORT}" >/tmp/novnc.log 2>&1 &

npm run start:online &

wait -n
