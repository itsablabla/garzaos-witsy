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

NOVNC_WEB=/tmp/witsy-online/novnc-web
mkdir -p "$WITSY_HOME" "$HOME" "$NOVNC_WEB"
cp -a /usr/share/novnc/. "$NOVNC_WEB"/
cat >"$NOVNC_WEB/index.html" <<'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Witsy Online</title>
    <meta http-equiv="refresh" content="0; url=/vnc.html?autoconnect=true&resize=scale">
    <script>window.location.replace('/vnc.html?autoconnect=true&resize=scale')</script>
  </head>
  <body>
    <a href="/vnc.html?autoconnect=true&resize=scale">Open Witsy Online</a>
  </body>
</html>
HTML

if [[ -z "${VNC_PASSWORD:-}" ]]; then
  VNC_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24)"
  export VNC_PASSWORD
  echo "VNC_PASSWORD was not set; generated temporary noVNC password: ${VNC_PASSWORD}"
fi

VNC_AUTH_FILE=/tmp/witsy-online/x11vnc.pass
x11vnc -storepasswd "$VNC_PASSWORD" "$VNC_AUTH_FILE" >/dev/null
chmod 600 "$VNC_AUTH_FILE"

pids=()
cleanup() {
  for pid in "${pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

start_service() {
  local name="$1"
  local log_file="$2"
  shift 2

  echo "Starting ${name}; logging to ${log_file}"
  "$@" >"${log_file}" 2>&1 &
  local pid=$!
  pids+=("$pid")
  sleep 1

  if ! kill -0 "$pid" 2>/dev/null; then
    echo "${name} failed to start. Last log lines:"
    tail -n 80 "$log_file" 2>/dev/null || true
    exit 1
  fi

  echo "${name} started with pid ${pid}"
}

wait_for_port() {
  local host="$1"
  local port="$2"
  local name="$3"

  for _ in $(seq 1 30); do
    if (echo >"/dev/tcp/${host}/${port}") >/dev/null 2>&1; then
      echo "${name} is listening on ${host}:${port}"
      return 0
    fi
    sleep 1
  done

  echo "${name} did not start listening on ${host}:${port}"
  tail -n 80 /tmp/x11vnc.log 2>/dev/null || true
  tail -n 80 /tmp/novnc.log 2>/dev/null || true
  exit 1
}

start_service "Xvfb" /tmp/xvfb.log \
  Xvfb "$DISPLAY" -screen 0 "${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_DEPTH}" -nolisten tcp

start_service "fluxbox" /tmp/fluxbox.log \
  fluxbox

start_service "x11vnc" /tmp/x11vnc.log \
  x11vnc -display "$DISPLAY" -rfbport "$VNC_PORT" -forever -shared -rfbauth "$VNC_AUTH_FILE" -localhost

wait_for_port 127.0.0.1 "$VNC_PORT" "x11vnc"

start_service "noVNC/websockify" /tmp/novnc.log \
  websockify --web="$NOVNC_WEB" "0.0.0.0:${NOVNC_PORT}" "127.0.0.1:${VNC_PORT}"

wait_for_port 127.0.0.1 "$NOVNC_PORT" "noVNC/websockify"

echo "Witsy online desktop is ready at /vnc.html on port ${NOVNC_PORT}"
echo "noVNC requires the configured VNC_PASSWORD."

npm run start:online &
electron_pid=$!
pids+=("$electron_pid")

echo "Witsy Electron process started with pid ${electron_pid}"
wait "$electron_pid"
