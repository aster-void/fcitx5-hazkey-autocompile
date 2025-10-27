#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"; work="$root/work"; dist="$root/dist"
sha="$(cat "$work/upstream.sha")"; pkg="$work/packages/fcitx5-hazkey.tar.gz"
latest="$dist/fcitx5-hazkey.tar.gz"; manifest="$dist/latest.json"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

[[ -f "$pkg" ]] || { echo "package not found: $pkg" >&2; exit 1; }
[[ -f "$dist/.gitkeep" ]] && rm -f "$dist/.gitkeep"

find "$dist" -maxdepth 1 -type f -name 'fcitx5-hazkey-*.tar.gz' -not -name 'fcitx5-hazkey.tar.gz' -delete
[[ ! -f "$latest" || ! cmp -s "$pkg" "$latest" ]] && cp "$pkg" "$latest"

tmp="$manifest.tmp"
cat <<EOF >"$tmp"
{
  "upstream": "$sha",
  "package": "$(basename "$latest")",
  "built_at": "$timestamp"
}
EOF

if [[ -f "$manifest" ]] && cmp -s "$tmp" "$manifest"; then
  rm -f "$tmp"
else
  mv "$tmp" "$manifest"
fi
