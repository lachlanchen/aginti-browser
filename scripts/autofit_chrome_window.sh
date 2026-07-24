#!/usr/bin/env bash
set -euo pipefail

DISPLAY_ID=":98"
PROFILE_DIR=""
INTERVAL="2"
ONCE="0"

usage() {
  cat <<'EOF'
Usage: autofit_chrome_window.sh --display :N --profile-dir DIR [options]

Options:
  --interval SECONDS  Poll interval for the fit guard (default: 2)
  --once              Fit once and exit
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --display) DISPLAY_ID="$2"; shift 2 ;;
    --profile-dir) PROFILE_DIR="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --once) ONCE="1"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$PROFILE_DIR" ]]; then
  echo "--profile-dir is required" >&2
  exit 2
fi

fit_once() {
  local dimensions root_width root_height window pid command geometry x y width height
  dimensions="$(DISPLAY="$DISPLAY_ID" xdotool getdisplaygeometry 2>/dev/null || true)"
  read -r root_width root_height <<< "$dimensions"
  [[ "$root_width" =~ ^[0-9]+$ && "$root_height" =~ ^[0-9]+$ ]] || return 0

  while read -r window; do
    [[ -n "$window" ]] || continue
    pid="$(DISPLAY="$DISPLAY_ID" xdotool getwindowpid "$window" 2>/dev/null || true)"
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    command="$(ps -p "$pid" -o args= 2>/dev/null || true)"
    [[ "$command" == *"--user-data-dir=$PROFILE_DIR"* ]] || continue

    geometry="$(DISPLAY="$DISPLAY_ID" xdotool getwindowgeometry --shell "$window" 2>/dev/null || true)"
    x="$(awk -F= '/^X=/{print $2}' <<< "$geometry")"
    y="$(awk -F= '/^Y=/{print $2}' <<< "$geometry")"
    width="$(awk -F= '/^WIDTH=/{print $2}' <<< "$geometry")"
    height="$(awk -F= '/^HEIGHT=/{print $2}' <<< "$geometry")"
    [[ "$x" =~ ^[0-9]+$ && "$y" =~ ^[0-9]+$ && "$width" =~ ^[0-9]+$ && "$height" =~ ^[0-9]+$ ]] || continue

    # Window-manager decorations can reduce the client frame by one pixel.
    if (( x != 0 || y != 0 || width < root_width - 2 || height < root_height - 2 )); then
      DISPLAY="$DISPLAY_ID" xdotool windowmove --sync "$window" 0 0
      DISPLAY="$DISPLAY_ID" xdotool windowsize --sync "$window" "$root_width" "$root_height"
    fi
  done < <(DISPLAY="$DISPLAY_ID" xdotool search --onlyvisible --class google-chrome 2>/dev/null || true)
}

if [[ "$ONCE" == "1" ]]; then
  fit_once
  exit 0
fi

while true; do
  fit_once
  sleep "$INTERVAL"
done
