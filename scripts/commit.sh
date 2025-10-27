#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
sha="$(cat "$root/work/upstream.sha")"
cd "$root"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

if git diff --quiet -- dist; then
  echo "no artifact changes; skipping commit"
  exit 0
fi

git add dist
git commit -m "chore: update fcitx5-hazkey build ($sha)"
git push
