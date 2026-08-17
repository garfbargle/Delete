#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKDIR="${DELETE_WORKDIR:-$HOME/.cache/delete-chromium}"
SRC="$WORKDIR/checkout/src"

if [[ ! -d "$SRC/.git" ]]; then
  echo "Chromium checkout not found. Run scripts/bootstrap.sh first." >&2
  exit 1
fi

mapfile -t patches < <(find "$ROOT/patches" -maxdepth 1 -type f -name '*.patch' -print | sort)

if (( ${#patches[@]} == 0 )); then
  echo "No patches yet; building pristine pinned Chromium."
  exit 0
fi

cd "$SRC"
for patch in "${patches[@]}"; do
  echo "Applying $(basename "$patch")"
  git apply --check "$patch"
  git apply "$patch"
done
