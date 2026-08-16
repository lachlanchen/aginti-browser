#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SESSION="${AGENTIC_VDESKTOP_SESSION:-agentic-browser-vdesktop}"
MODE="${AGENTIC_VDESKTOP_MODE:-xephyr}"
DISPLAY_ID="${AGENTIC_VDESKTOP_DISPLAY:-:78}"
GEOMETRY="${AGENTIC_VDESKTOP_GEOMETRY:-1600x1000}"
XEPHYR_DEPTH="${AGENTIC_VDESKTOP_XEPHYR_DEPTH:-24}"
XEPHYR_FALLBACK_DEPTH="${AGENTIC_VDESKTOP_XEPHYR_FALLBACK_DEPTH:-16/16}"
XEPHYR_EXTRA_ARGS="${AGENTIC_VDESKTOP_XEPHYR_EXTRA_ARGS:--glamor}"
GUI_PORT="${AGENTIC_VDESKTOP_GUI_PORT:-8794}"
BROWSER_PORT="${AGENTIC_VDESKTOP_BROWSER_PORT:-9344}"
VNC_PORT="${AGENTIC_VDESKTOP_VNC_PORT:-}"
NOVNC_PORT="${AGENTIC_VDESKTOP_NOVNC_PORT:-}"
NOVNC_WEB="${AGENTIC_VDESKTOP_NOVNC_WEB:-/usr/share/novnc}"
PROFILE_DIR="${AGENTIC_VDESKTOP_PROFILE:-$HOME/.cache/agentic-browser-vdesktop-chrome}"
MODEL="${AGENTIC_VDESKTOP_MODEL:-gpt-5.4-mini}"
REASONING="${AGENTIC_VDESKTOP_REASONING:-low}"
LOG_DIR="$ROOT/library/agentic-browser-vdesktop"
STATE_FILE="$LOG_DIR/${SESSION}.state"

usage() {
  cat <<EOF
Usage: $0 {start|stop|status|logs|daemon}

Starts the embedded agentic browser in an isolated virtual display/session.

Environment overrides:
  AGENTIC_VDESKTOP_MODE=auto|xvfb|xephyr|headless
  AGENTIC_VDESKTOP_SESSION=$SESSION
  AGENTIC_VDESKTOP_DISPLAY=$DISPLAY_ID
  AGENTIC_VDESKTOP_GEOMETRY=$GEOMETRY
  AGENTIC_VDESKTOP_XEPHYR_DEPTH=$XEPHYR_DEPTH
  AGENTIC_VDESKTOP_XEPHYR_FALLBACK_DEPTH=$XEPHYR_FALLBACK_DEPTH
  AGENTIC_VDESKTOP_XEPHYR_EXTRA_ARGS=$XEPHYR_EXTRA_ARGS
  AGENTIC_VDESKTOP_GUI_PORT=$GUI_PORT
  AGENTIC_VDESKTOP_BROWSER_PORT=$BROWSER_PORT
  AGENTIC_VDESKTOP_VNC_PORT=PORT
  AGENTIC_VDESKTOP_NOVNC_PORT=PORT
  AGENTIC_VDESKTOP_NOVNC_WEB=$NOVNC_WEB
  AGENTIC_VDESKTOP_PROFILE=$PROFILE_DIR
  AGENTIC_VDESKTOP_MODEL=$MODEL
  AGENTIC_VDESKTOP_REASONING=$REASONING

Set both VNC and noVNC ports to expose a localhost-only visible viewer.
EOF
}

have() {
  command -v "$1" >/dev/null 2>&1
}

write_state() {
  mkdir -p "$LOG_DIR"
  {
    printf 'SESSION=%q\n' "$SESSION"
    printf 'MODE=%q\n' "$MODE"
    printf 'DISPLAY_ID=%q\n' "$DISPLAY_ID"
    printf 'GEOMETRY=%q\n' "$GEOMETRY"
    printf 'XEPHYR_DEPTH=%q\n' "$XEPHYR_DEPTH"
    printf 'XEPHYR_FALLBACK_DEPTH=%q\n' "$XEPHYR_FALLBACK_DEPTH"
    printf 'XEPHYR_EXTRA_ARGS=%q\n' "$XEPHYR_EXTRA_ARGS"
    printf 'GUI_PORT=%q\n' "$GUI_PORT"
    printf 'BROWSER_PORT=%q\n' "$BROWSER_PORT"
    printf 'VNC_PORT=%q\n' "$VNC_PORT"
    printf 'NOVNC_PORT=%q\n' "$NOVNC_PORT"
    printf 'NOVNC_WEB=%q\n' "$NOVNC_WEB"
    printf 'PROFILE_DIR=%q\n' "$PROFILE_DIR"
    printf 'MODEL=%q\n' "$MODEL"
    printf 'REASONING=%q\n' "$REASONING"
    printf 'LOG_DIR=%q\n' "$LOG_DIR"
  } > "$STATE_FILE"
}

load_state() {
  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
  fi
}

choose_mode() {
  if [[ "$MODE" != "auto" ]]; then
    printf '%s\n' "$MODE"
    return
  fi
  if have Xephyr; then
    printf 'xephyr\n'
  elif have Xvfb; then
    printf 'xvfb\n'
  else
    printf 'headless\n'
  fi
}

start_window_manager() {
  if have openbox; then
    openbox >>"$LOG_DIR/window-manager.log" 2>&1 &
  elif have fluxbox; then
    fluxbox >>"$LOG_DIR/window-manager.log" 2>&1 &
  elif have xfwm4; then
    xfwm4 >>"$LOG_DIR/window-manager.log" 2>&1 &
  elif have matchbox-window-manager; then
    matchbox-window-manager >>"$LOG_DIR/window-manager.log" 2>&1 &
  fi
}

kill_profile_processes() {
  local pids
  pids="$(pgrep -af "$PROFILE_DIR" | awk -v self="$$" '$1 != self {print $1}' || true)"
  if [[ -n "$pids" ]]; then
    # shellcheck disable=SC2086
    kill $pids >/dev/null 2>&1 || true
    sleep 1
    # shellcheck disable=SC2086
    kill -9 $pids >/dev/null 2>&1 || true
  fi
}

kill_display_processes() {
  local display="$1"
  local display_num="${display#:}"
  local pids
  pids="$(pgrep -af "(Xephyr|Xvfb) ${display}( |$)" | awk -v self="$$" '$1 != self {print $1}' || true)"
  if [[ -n "$pids" ]]; then
    # shellcheck disable=SC2086
    kill $pids >/dev/null 2>&1 || true
    sleep 1
    # shellcheck disable=SC2086
    kill -9 $pids >/dev/null 2>&1 || true
  fi
  if [[ -n "$display_num" ]]; then
    rm -f "/tmp/.X${display_num}-lock" "/tmp/.X11-unix/X${display_num}" >/dev/null 2>&1 || true
  fi
}

remote_viewer_enabled() {
  [[ -n "$VNC_PORT" && -n "$NOVNC_PORT" ]]
}

novnc_url() {
  printf 'http://127.0.0.1:%s/vnc.html?host=127.0.0.1&port=%s&autoconnect=1&resize=scale&view_only=0&shared=0&reconnect=0\n' \
    "$NOVNC_PORT" "$NOVNC_PORT"
}

start_remote_viewer() {
  if [[ -z "$VNC_PORT" && -z "$NOVNC_PORT" ]]; then
    return 0
  fi
  if ! remote_viewer_enabled; then
    echo "Set both AGENTIC_VDESKTOP_VNC_PORT and AGENTIC_VDESKTOP_NOVNC_PORT." >&2
    return 1
  fi
  if [[ "$MODE" == "headless" ]]; then
    echo "noVNC requires xvfb or xephyr mode, not headless." >&2
    return 1
  fi
  if [[ "$VNC_PORT" == "$NOVNC_PORT" ]]; then
    echo "VNC and noVNC ports must be different." >&2
    return 1
  fi
  if ! have x11vnc || ! have websockify; then
    echo "x11vnc and websockify are required for noVNC mode." >&2
    return 1
  fi
  if ss -ltn | awk '{print $4}' | grep -Eq "(^|:)${VNC_PORT}$|(^|:)${NOVNC_PORT}$"; then
    echo "Configured VNC/noVNC port is already in use." >&2
    return 1
  fi

  x11vnc \
    -display "$DISPLAY_ID" \
    -localhost \
    -nopw \
    -forever \
    -nevershared \
    -rfbport "$VNC_PORT" \
    >>"$LOG_DIR/x11vnc.log" 2>&1 &
  vnc_pid="$!"

  websockify \
    --web="$NOVNC_WEB" \
    "127.0.0.1:$NOVNC_PORT" \
    "127.0.0.1:$VNC_PORT" \
    >>"$LOG_DIR/novnc.log" 2>&1 &
  novnc_pid="$!"

  local viewer_url
  viewer_url="$(novnc_url)"
  for _ in $(seq 1 30); do
    if curl -fsS -o /dev/null "$viewer_url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.25
  done
  echo "noVNC did not become ready: $viewer_url" >&2
  return 1
}

kill_remote_viewer_processes() {
  local pids=""
  if [[ -n "$VNC_PORT" ]]; then
    pids+=" $(pgrep -f "x11vnc.*-rfbport ${VNC_PORT}( |$)" || true)"
  fi
  if [[ -n "$NOVNC_PORT" && -n "$VNC_PORT" ]]; then
    pids+=" $(pgrep -f "websockify.*127\\.0\\.0\\.1:${NOVNC_PORT}.*127\\.0\\.0\\.1:${VNC_PORT}" || true)"
  fi
  pids="$(printf '%s\n' "$pids" | xargs)"
  if [[ -n "$pids" ]]; then
    # shellcheck disable=SC2086
    kill $pids >/dev/null 2>&1 || true
  fi
}

wait_for_service() {
  local url="http://127.0.0.1:$GUI_PORT/api/status"
  if ! have curl; then
    sleep 2
    return 0
  fi
  for _ in $(seq 1 40); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.5
  done
  echo "Service did not become ready: $url" >&2
  "$0" logs >&2 || true
  return 1
}

start_xephyr() {
  local depth="$1"
  shift
  local -a extra_args=("$@")
  Xephyr "$DISPLAY_ID" \
    -screen "${GEOMETRY}x${depth}" \
    "${extra_args[@]}" \
    -resizeable \
    -title "Agentic Browser Virtual Desktop" \
    -nolisten tcp \
    >>"$LOG_DIR/xserver.log" 2>&1 &
  x_pid="$!"
  sleep 1
  if ps -p "$x_pid" >/dev/null 2>&1; then
    return 0
  fi
  wait "$x_pid" >/dev/null 2>&1 || true
  x_pid=""
  return 1
}

daemon() {
  mkdir -p "$LOG_DIR"
  local selected_mode
  selected_mode="$(choose_mode)"
  MODE="$selected_mode"
  write_state
  local x_pid=""
  local server_pid=""
  local fit_guard_pid=""
  local vnc_pid=""
  local novnc_pid=""

  echo "Agentic browser virtual desktop"
  echo "Mode: $selected_mode"
  echo "GUI: http://127.0.0.1:$GUI_PORT"
  echo "CDP: http://127.0.0.1:$BROWSER_PORT"
  echo "Profile: $PROFILE_DIR"
  if remote_viewer_enabled; then
    echo "noVNC: $(novnc_url)"
  fi
  echo "Logs: $LOG_DIR"

  case "$selected_mode" in
    xvfb)
      if ! have Xvfb; then
        echo "Xvfb is not installed. Install it or use AGENTIC_VDESKTOP_MODE=xephyr/headless." >&2
        exit 1
      fi
      kill_display_processes "$DISPLAY_ID"
      Xvfb "$DISPLAY_ID" -screen 0 "${GEOMETRY}x24" -nolisten tcp >>"$LOG_DIR/xserver.log" 2>&1 &
      x_pid="$!"
      export DISPLAY="$DISPLAY_ID"
      sleep 1
      start_window_manager
      ;;
    xephyr)
      if ! have Xephyr; then
        echo "Xephyr is not installed. Install it or use AGENTIC_VDESKTOP_MODE=headless." >&2
        exit 1
      fi
      kill_display_processes "$DISPLAY_ID"
      # 24-bit Xephyr needs glamor in some XRDP/Xvnc sessions. Fall back to the
      # older 16-bit mode only if the high-color launch fails.
      # shellcheck disable=SC2206
      local xephyr_extra_args=( $XEPHYR_EXTRA_ARGS )
      if ! start_xephyr "$XEPHYR_DEPTH" "${xephyr_extra_args[@]}"; then
        echo "Xephyr ${GEOMETRY}x${XEPHYR_DEPTH} failed; retrying ${GEOMETRY}x${XEPHYR_FALLBACK_DEPTH}" >>"$LOG_DIR/xserver.log"
        kill_display_processes "$DISPLAY_ID"
        start_xephyr "$XEPHYR_FALLBACK_DEPTH" || {
          echo "Xephyr failed to start. See $LOG_DIR/xserver.log" >&2
          exit 1
        }
      fi
      export DISPLAY="$DISPLAY_ID"
      start_window_manager
      ;;
    headless)
      unset DISPLAY
      local width="${GEOMETRY%x*}"
      local height="${GEOMETRY#*x}"
      export EMBEDDED_AGENTIC_CHROME_ARGS="${EMBEDDED_AGENTIC_CHROME_ARGS:-} --headless=new --window-size=${width},${height}"
      ;;
    *)
      echo "Unknown AGENTIC_VDESKTOP_MODE: $selected_mode" >&2
      exit 1
      ;;
  esac

  cleanup() {
    if [[ -n "$server_pid" ]]; then
      kill "$server_pid" >/dev/null 2>&1 || true
    fi
    if [[ -n "$fit_guard_pid" ]]; then
      kill "$fit_guard_pid" >/dev/null 2>&1 || true
    fi
    if [[ -n "$novnc_pid" ]]; then
      kill "$novnc_pid" >/dev/null 2>&1 || true
    fi
    if [[ -n "$vnc_pid" ]]; then
      kill "$vnc_pid" >/dev/null 2>&1 || true
    fi
    kill_profile_processes
    if [[ -n "$x_pid" ]]; then
      kill "$x_pid" >/dev/null 2>&1 || true
    fi
  }
  trap cleanup EXIT INT TERM

  start_remote_viewer

  export EMBEDDED_AGENTIC_HOST=127.0.0.1
  export EMBEDDED_AGENTIC_PORT="$GUI_PORT"
  export EMBEDDED_AGENTIC_BROWSER_PORT="$BROWSER_PORT"
  export EMBEDDED_AGENTIC_PROFILE="$PROFILE_DIR"
  export EMBEDDED_AGENTIC_MODEL="$MODEL"
  export EMBEDDED_AGENTIC_REASONING="$REASONING"

  ./embedded_agentic_browser/run.sh &
  server_pid="$!"
  if [[ "$selected_mode" != "headless" ]] && command -v xdotool >/dev/null 2>&1; then
    ./scripts/autofit_chrome_window.sh \
      --display "$DISPLAY_ID" \
      --profile-dir "$PROFILE_DIR" \
      >>"$LOG_DIR/window-fit.log" 2>&1 &
    fit_guard_pid="$!"
  fi
  wait "$server_pid"
}

start() {
  if tmux has-session -t "$SESSION" >/dev/null 2>&1; then
    echo "Session already running: $SESSION"
    "$0" status
    exit 0
  fi
  write_state
  local command
  printf -v command \
    'AGENTIC_VDESKTOP_SESSION=%q AGENTIC_VDESKTOP_MODE=%q AGENTIC_VDESKTOP_DISPLAY=%q AGENTIC_VDESKTOP_GEOMETRY=%q AGENTIC_VDESKTOP_XEPHYR_DEPTH=%q AGENTIC_VDESKTOP_XEPHYR_FALLBACK_DEPTH=%q AGENTIC_VDESKTOP_XEPHYR_EXTRA_ARGS=%q AGENTIC_VDESKTOP_GUI_PORT=%q AGENTIC_VDESKTOP_BROWSER_PORT=%q AGENTIC_VDESKTOP_VNC_PORT=%q AGENTIC_VDESKTOP_NOVNC_PORT=%q AGENTIC_VDESKTOP_NOVNC_WEB=%q AGENTIC_VDESKTOP_PROFILE=%q AGENTIC_VDESKTOP_MODEL=%q AGENTIC_VDESKTOP_REASONING=%q %q daemon' \
    "$SESSION" "$MODE" "$DISPLAY_ID" "$GEOMETRY" "$XEPHYR_DEPTH" "$XEPHYR_FALLBACK_DEPTH" "$XEPHYR_EXTRA_ARGS" "$GUI_PORT" "$BROWSER_PORT" "$VNC_PORT" "$NOVNC_PORT" "$NOVNC_WEB" "$PROFILE_DIR" "$MODEL" "$REASONING" "$0"
  tmux new-session -d -s "$SESSION" "$command"
  wait_for_service
  "$0" status
}

stop() {
  load_state
  tmux kill-session -t "$SESSION" >/dev/null 2>&1 || true
  kill_remote_viewer_processes
  kill_profile_processes
  kill_display_processes "$DISPLAY_ID"
  rm -f "$STATE_FILE"
  echo "Stopped session: $SESSION"
}

status() {
  load_state
  if tmux has-session -t "$SESSION" >/dev/null 2>&1; then
    echo "Session: $SESSION running"
    echo "GUI: http://127.0.0.1:$GUI_PORT"
    echo "CDP: http://127.0.0.1:$BROWSER_PORT"
    echo "Mode: $MODE"
    echo "Display: $DISPLAY_ID"
    if remote_viewer_enabled; then
      echo "VNC: 127.0.0.1:$VNC_PORT"
      echo "noVNC: $(novnc_url)"
    fi
    echo "Logs: $LOG_DIR"
  else
    echo "Session: $SESSION not running"
    exit 1
  fi
}

logs() {
  tmux capture-pane -p -t "$SESSION" -S -120
}

case "${1:-start}" in
  start) start ;;
  stop) stop ;;
  status) status ;;
  logs) logs ;;
  daemon) daemon ;;
  -h|--help|help) usage ;;
  *) usage; exit 1 ;;
esac
