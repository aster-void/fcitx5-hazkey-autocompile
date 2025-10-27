#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"; work="$root/work"; dist="$root/dist"
sha="$(cat "$work/upstream.sha")"; pkg="$work/packages/fcitx5-hazkey-$sha-x86_64.tar.gz"
target="$dist/$(basename "$pkg")"; manifest="$dist/latest.json"; timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

[[ -f "$pkg" ]] || { echo "package not found: $pkg" >&2; exit 1; }
[[ -f "$dist/.gitkeep" ]] && rm -f "$dist/.gitkeep"

if [[ ! -f "$target" ]] || ! cmp -s "$pkg" "$target"; then
  cp "$pkg" "$target"
fi

tmp="$manifest.tmp"
cat <<EOF >"$tmp"
{
  "upstream": "$sha",
  "package": "$(basename "$pkg")",
  "built_at": "$timestamp"
}
EOF

if [[ -f "$manifest" ]] && cmp -s "$tmp" "$manifest"; then
  rm -f "$tmp"
else
  mv "$tmp" "$manifest"
fi
