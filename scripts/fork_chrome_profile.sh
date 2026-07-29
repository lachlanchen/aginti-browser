#!/usr/bin/env bash
set -euo pipefail

SOURCE=""
TARGET=""
ALLOW_LIVE_SOURCE="0"

usage() {
  cat <<'EOF'
Usage:
  fork_chrome_profile.sh --source DIR --target DIR [--allow-live-source]

Creates an independent Chrome user-data snapshot. The target must not already
exist. Volatile locks, caches, crash data, and multi-gigabyte downloadable
browser models are excluded; profiles, cookies, history, extensions, local
storage, and preferences are retained.

Copying a running profile is a best-effort snapshot. Use --allow-live-source
only when stopping the source browser would disrupt active work.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --allow-live-source) ALLOW_LIVE_SOURCE="1"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$SOURCE" || -z "$TARGET" ]]; then
  usage >&2
  exit 2
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "Missing required command: rsync" >&2
  exit 3
fi

SOURCE="$(realpath -e "$SOURCE")"
TARGET="$(realpath -m "$TARGET")"

if [[ "$SOURCE" == "$TARGET" ]]; then
  echo "Source and target profiles must be different." >&2
  exit 4
fi

if [[ -e "$TARGET" ]]; then
  echo "Target already exists; refusing to merge or overwrite: $TARGET" >&2
  exit 5
fi

if pgrep -af -- "--user-data-dir=$TARGET" >/dev/null 2>&1; then
  echo "Target profile is already in use: $TARGET" >&2
  exit 6
fi

if pgrep -af -- "--user-data-dir=$SOURCE" >/dev/null 2>&1; then
  if [[ "$ALLOW_LIVE_SOURCE" != "1" ]]; then
    echo "Source profile is active. Stop it or pass --allow-live-source." >&2
    exit 7
  fi
  echo "Warning: creating a best-effort snapshot of an active profile." >&2
fi

mkdir -p "$(dirname "$TARGET")"
TEMP_TARGET="$(mktemp -d "${TARGET}.partial.XXXXXX")"

cleanup() {
  if [[ -n "${TEMP_TARGET:-}" && -d "$TEMP_TARGET" ]]; then
    rm -rf -- "$TEMP_TARGET"
  fi
}
trap cleanup EXIT

rsync \
  --archive \
  --safe-links \
  --exclude='Singleton*' \
  --exclude='DevToolsActivePort' \
  --exclude='Cache/' \
  --exclude='Code Cache/' \
  --exclude='GPUCache/' \
  --exclude='DawnCache/' \
  --exclude='DawnGraphiteCache/' \
  --exclude='GraphiteDawnCache/' \
  --exclude='GrShaderCache/' \
  --exclude='ShaderCache/' \
  --exclude='Crashpad/' \
  --exclude='BrowserMetrics*' \
  --exclude='DeferredBrowserMetrics/' \
  --exclude='CacheStorage/' \
  --exclude='ScriptCache/' \
  --exclude='OptGuideOnDeviceModel/' \
  --exclude='OptGuideOnDeviceClassifierModel/' \
  --exclude='optimization_guide_model_store/' \
  --exclude='component_crx_cache/' \
  --exclude='extensions_crx_cache/' \
  --exclude='Safe Browsing/' \
  "$SOURCE/" "$TEMP_TARGET/"

{
  printf 'source=%s\n' "$SOURCE"
  printf 'created_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'mode=lean-independent-snapshot\n'
} > "$TEMP_TARGET/.aginti-profile-fork"

mv "$TEMP_TARGET" "$TARGET"
TEMP_TARGET=""

echo "Chrome profile fork created"
echo "  source: $SOURCE"
echo "  target: $TARGET"
du -sh "$TARGET"
