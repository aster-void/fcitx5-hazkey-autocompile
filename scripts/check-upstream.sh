#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
sha="$(cat "$root/work/upstream.sha")"
current=""

if [[ -f "$root/dist/latest.json" ]]; then
  current="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("upstream",""))' <"$root/dist/latest.json")"
fi

changed="true"
if [[ -n "$current" && "$sha" == "$current" ]]; then
  changed="false"
fi

echo "Upstream head: $sha"
[[ -n "$current" ]] && echo "Last built : $current"
[[ "$changed" == "false" ]] && echo "No upstream change detected; skipping build."

[[ -n "${GITHUB_OUTPUT:-}" ]] && echo "changed=$changed" >>"$GITHUB_OUTPUT"
