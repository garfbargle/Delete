#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/chromium.version"

WORKDIR="${DELETE_WORKDIR:-$HOME/.cache/delete-chromium}"
DEPOT_TOOLS="$WORKDIR/depot_tools"
SRC="$WORKDIR/checkout/src"
OUT="$SRC/out/Delete"
ARTIFACTS="$ROOT/artifacts"

export PATH="$DEPOT_TOOLS:$PATH"

if [[ ! -d "$SRC/.git" ]]; then
  echo "Chromium checkout not found. Run scripts/bootstrap.sh first." >&2
  exit 1
fi

cd "$SRC"
gn gen "$OUT" --args="$(cat "$ROOT/build/args.arm64.gn")"
autoninja -C "$OUT" chrome_public_apk

APK="$OUT/apks/ChromePublic.apk"
if [[ ! -f "$APK" ]]; then
  echo "Expected APK not found at $APK" >&2
  find "$OUT" -maxdepth 3 -type f -name '*.apk' -print >&2 || true
  exit 1
fi

mkdir -p "$ARTIFACTS"
DEST="$ARTIFACTS/Delete-${CHROMIUM_VERSION}-arm64.apk"
cp "$APK" "$DEST"
sha256sum "$DEST" > "$DEST.sha256"

echo "Built $DEST"
