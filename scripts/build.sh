#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/chromium.version"
# shellcheck source=/dev/null
source "$ROOT/app.version"

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

if [[ ! "$DELETE_VERSION_CODE" =~ ^[0-9]+$ ]] || (( DELETE_VERSION_CODE < 1 )); then
  echo "DELETE_VERSION_CODE must be a positive integer." >&2
  exit 1
fi

GN_ARGS="$(cat "$ROOT/build/args.arm64.gn")"
GN_ARGS+=$'\nandroid_override_version_name = "'"$DELETE_VERSION_NAME"$'"'
GN_ARGS+=$'\nandroid_override_version_code = "'"$DELETE_VERSION_CODE"$'"'

cd "$SRC"
gn gen "$OUT" --args="$GN_ARGS"
autoninja -C "$OUT" chrome_public_apk

# chrome_public_apk also produces a raw unsigned APK before Chromium's
# development signing/finalization step. Library wants this exact boundary.
APK="$OUT/gen/chrome/android/chrome_public_apk/chrome_public_apk_unsigned.apk"
if [[ ! -f "$APK" ]]; then
  mapfile -t candidates < <(find "$OUT/gen/chrome/android/chrome_public_apk" -type f -name '*_unsigned.apk' -print 2>/dev/null | sort)
  if (( ${#candidates[@]} != 1 )); then
    echo "Expected one raw unsigned APK; found ${#candidates[@]}." >&2
    printf '%s\n' "${candidates[@]:-}" >&2
    exit 1
  fi
  APK="${candidates[0]}"
fi

rm -rf "$ARTIFACTS"
mkdir -p "$ARTIFACTS"
DEST="$ARTIFACTS/Delete-${DELETE_VERSION_NAME}-chromium-${CHROMIUM_VERSION}-arm64-unsigned.apk"
cp "$APK" "$DEST"
sha256sum "$DEST" > "$DEST.sha256"

echo "Built unsigned APK: $DEST"
