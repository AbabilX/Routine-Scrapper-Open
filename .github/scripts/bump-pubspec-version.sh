#!/usr/bin/env bash
# Bump Flutter pubspec version: patch (0.1.0 → 0.1.1) and +build number.
# Usage: bump-pubspec-version.sh [min-build-number]
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
pubspec="$root/pubspec.yaml"
min_code="${1:-0}"

line="$(grep -E '^version:' "$pubspec" | head -n1)"
raw="$(awk '{print $2}' <<<"$line")"
name="${raw%%+*}"
code="${raw#*+}"
if [[ "$code" == "$raw" ]]; then
  code=0
fi

IFS='.' read -r major minor patch <<<"$name"
if [[ -z "${major:-}" || -z "${minor:-}" || -z "${patch:-}" ]]; then
  echo "Could not parse version name from: $raw" >&2
  exit 1
fi

patch=$((patch + 1))
new_name="${major}.${minor}.${patch}"
new_code=$((code + 1))
if (( new_code < min_code )); then
  new_code="$min_code"
fi
new_version="${new_name}+${new_code}"

tmp="$(mktemp)"
awk -v ver="$new_version" '
  BEGIN { done = 0 }
  /^version:/ && !done { print "version: " ver; done = 1; next }
  { print }
' "$pubspec" >"$tmp"
mv "$tmp" "$pubspec"

echo "Bumped $raw → $new_version"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "previous=$raw"
    echo "name=$new_name"
    echo "code=$new_code"
    echo "version=$new_version"
  } >>"$GITHUB_OUTPUT"
fi
