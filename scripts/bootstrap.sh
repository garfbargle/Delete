#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT/chromium.version"

WORKDIR="${DELETE_WORKDIR:-$HOME/.cache/delete-chromium}"
DEPOT_TOOLS="$WORKDIR/depot_tools"
CHECKOUT="$WORKDIR/checkout"

mkdir -p "$WORKDIR"

if [[ ! -d "$DEPOT_TOOLS/.git" ]]; then
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "$DEPOT_TOOLS"
else
  git -C "$DEPOT_TOOLS" pull --ff-only
fi
export PATH="$DEPOT_TOOLS:$PATH"

mkdir -p "$CHECKOUT"
if [[ ! -d "$CHECKOUT/src/.git" ]]; then
  (
    cd "$CHECKOUT"
    fetch --nohooks --no-history android
  )
fi

cd "$CHECKOUT/src"
git fetch --force origin "refs/tags/$CHROMIUM_VERSION:refs/tags/$CHROMIUM_VERSION"

actual_revision="$(git rev-list -n 1 "$CHROMIUM_VERSION")"
if [[ "$actual_revision" != "$CHROMIUM_REVISION" ]]; then
  echo "Pinned tag mismatch: $CHROMIUM_VERSION resolved to $actual_revision" >&2
  exit 1
fi

git reset --hard "$CHROMIUM_REVISION"
git clean -ffd

gclient sync \
  -D \
  --force \
  --reset \
  --nohooks \
  --revision "src@$CHROMIUM_REVISION"

if [[ "${INSTALL_BUILD_DEPS:-0}" == "1" ]]; then
  ./build/install-build-deps.sh --android
fi

gclient runhooks

echo "Chromium $CHROMIUM_VERSION ready at $CHROMIUM_REVISION"
