#!/usr/bin/env bash
set -euo pipefail

MIN_DISK_GB="${DELETE_MIN_DISK_GB:-120}"
MIN_RAM_GB="${DELETE_MIN_RAM_GB:-16}"

[[ "$(uname -s)" == "Linux" ]] || { echo "Chromium builder must run on Linux." >&2; exit 1; }
[[ "$(uname -m)" == "x86_64" ]] || { echo "Chromium builder host must be x86_64." >&2; exit 1; }

for tool in git python3 curl; do
  command -v "$tool" >/dev/null || { echo "Missing required tool: $tool" >&2; exit 1; }
done

workdir="${DELETE_WORKDIR:-$HOME/.cache/delete-chromium}"
mkdir -p "$workdir"

disk_kb="$(df -Pk "$workdir" | awk 'NR==2 {print $4}')"
disk_gb=$((disk_kb / 1024 / 1024))
ram_kb="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
ram_gb=$((ram_kb / 1024 / 1024))

if (( disk_gb < MIN_DISK_GB )); then
  echo "Need at least ${MIN_DISK_GB} GB free in $workdir; found ${disk_gb} GB." >&2
  exit 1
fi
if (( ram_gb < MIN_RAM_GB )); then
  echo "Need at least ${MIN_RAM_GB} GB RAM; found ${ram_gb} GB." >&2
  exit 1
fi

printf 'Runner ready: %s GB free, %s GB RAM, workdir=%s\n' "$disk_gb" "$ram_gb" "$workdir"
