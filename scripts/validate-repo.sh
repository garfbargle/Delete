#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for script in scripts/*.sh; do
  bash -n "$script"
done

python3 - <<'PY'
import json
import pathlib
import re

root = pathlib.Path('.')
meta = json.loads((root / '.library.json').read_text())
assert meta['provenance'] == 'library-managed'
assert meta['managedSigning']['packageName'] == 'com.garfbargle.delete'

values = {}
for line in (root / 'app.version').read_text().splitlines():
    if not line or line.startswith('#'):
        continue
    key, value = line.split('=', 1)
    values[key] = value

assert re.fullmatch(r'\d+\.\d+\.\d+(?:[-+][A-Za-z0-9.-]+)?', values['DELETE_VERSION_NAME'])
assert values['DELETE_VERSION_CODE'].isdigit()
assert int(values['DELETE_VERSION_CODE']) > 0

chromium = {}
for line in (root / 'chromium.version').read_text().splitlines():
    if not line or line.startswith('#'):
        continue
    key, value = line.split('=', 1)
    chromium[key] = value

assert re.fullmatch(r'\d+\.\d+\.\d+\.\d+', chromium['CHROMIUM_VERSION'])
assert re.fullmatch(r'[0-9a-f]{40}', chromium['CHROMIUM_REVISION'])

args = (root / 'build' / 'args.arm64.gn').read_text()
assert 'target_os = "android"' in args
assert 'target_cpu = "arm64"' in args
assert 'is_desktop_android = true' in args
assert 'chrome_public_manifest_package = "com.garfbargle.delete"' in args

print('Repository configuration is valid.')
PY
