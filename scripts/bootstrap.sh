#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
work="$root/work"
repo="${1:-https://github.com/7ka-Hiira/fcitx5-hazkey.git}"

mkdir -p "$work"
rm -rf "$work/upstream"
git clone --depth 1 --recurse-submodules "$repo" "$work/upstream"
git -C "$work/upstream" rev-parse HEAD > "$work/upstream.sha"
