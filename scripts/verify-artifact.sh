#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/app.version"

WORKDIR="${DELETE_WORKDIR:-$HOME/.cache/delete-chromium}"
SRC="$WORKDIR/checkout/src"

mapfile -t apks < <(find "$ROOT/artifacts" -maxdepth 1 -type f -name '*.apk' -print | sort)
if (( ${#apks[@]} != 1 )); then
  echo "Expected exactly one APK artifact; found ${#apks[@]}." >&2
  exit 1
fi
APK="${apks[0]}"

AAPT2="$(find "$SRC/third_party/android_sdk/public/build-tools" -type f -name aapt2 -print | sort -V | tail -n1)"
APKSIGNER="$(find "$SRC/third_party/android_sdk/public/build-tools" -type f -name apksigner -print | sort -V | tail -n1)"

if [[ -z "$AAPT2" || -z "$APKSIGNER" ]]; then
  echo "Android build tools not found in Chromium checkout." >&2
  exit 1
fi

package_line="$($AAPT2 dump badging "$APK" | grep '^package:' | head -n1)"
[[ "$package_line" == *"name='com.garfbargle.delete'"* ]] || { echo "Wrong package: $package_line" >&2; exit 1; }
[[ "$package_line" == *"versionCode='$DELETE_VERSION_CODE'"* ]] || { echo "Wrong versionCode: $package_line" >&2; exit 1; }
[[ "$package_line" == *"versionName='$DELETE_VERSION_NAME'"* ]] || { echo "Wrong versionName: $package_line" >&2; exit 1; }

if "$APKSIGNER" verify --print-certs "$APK" >/dev/null 2>&1; then
  echo "APK is already signed; Library requires an unsigned APK." >&2
  exit 1
fi

echo "Verified unsigned Library artifact: $package_line"
