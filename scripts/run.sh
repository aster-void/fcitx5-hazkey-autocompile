#!/usr/bin/env bash
set -euo pipefail

repo="${1:-https://github.com/7ka-Hiira/fcitx5-hazkey.git}"
root="$(git rev-parse --show-toplevel)"
work="$root/work"
upstream="$work/upstream"
sha_file="$work/upstream.sha"
build_dir="$work/build"
dest_dir="$work/workdir"
pack_dir="$work/packages"
dist="$root/dist"
pkg="$pack_dir/fcitx5-hazkey.tar.gz"
latest="$dist/fcitx5-hazkey.tar.gz"
manifest="$dist/latest.json"

mkdir -p "$work"
rm -rf "$upstream"
git clone --depth 1 --recurse-submodules "$repo" "$upstream"
git -C "$upstream" rev-parse HEAD >"$sha_file"
sha="$(<"$sha_file")"

current=""
if [[ -f "$manifest" ]]; then
  current="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("upstream",""))' <"$manifest")"
fi
echo "Upstream head: $sha"
[[ -n "$current" ]] && echo "Last built : $current"
if [[ -n "$current" && "$current" == "$sha" ]]; then
  echo "No upstream change detected; skipping build."
  exit 0
fi

sudo apt-get update -y
sudo apt-get install -y build-essential cmake gettext fakeroot protobuf-compiler \
  libprotobuf-dev libprotoc-dev libabsl-dev libfcitx5core-dev \
  libfcitx5config-dev libfcitx5utils-dev ninja-build qt6-base-dev qt6-tools-dev \
  qt6-tools-dev-tools libqt6widgets6 libqt6gui6 qt6-l10n-tools libglx-dev \
  libgl1-mesa-dev libxkbcommon-dev wget
if [[ ! -d /usr/share/swift/usr/bin ]]; then
  wget -q https://download.swift.org/swift-6.2-release/ubuntu2204/swift-6.2-RELEASE/swift-6.2-RELEASE-ubuntu22.04.tar.gz
  tar xf swift-6.2-RELEASE-ubuntu22.04.tar.gz
  sudo mv swift-6.2-RELEASE-ubuntu22.04 /usr/share/swift
  rm -f swift-6.2-RELEASE-ubuntu22.04.tar.gz
fi
[[ -n "${GITHUB_ENV:-}" ]] && echo "PATH=/usr/share/swift/usr/bin:$PATH" >>"$GITHUB_ENV"

rm -rf "$build_dir" "$dest_dir"
mkdir -p "$build_dir" "$dest_dir" "$pack_dir"
for comp in hazkey-server hazkey-settings fcitx5-hazkey; do
  cmake -S "$upstream/$comp" -B "$build_dir/$comp" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -G Ninja
  ninja -C "$build_dir/$comp" -j"$(nproc)"
  DESTDIR="$dest_dir" ninja -C "$build_dir/$comp" install
done
tar -czf "$pkg" -C "$dest_dir" usr

mkdir -p "$dist"
find "$dist" -maxdepth 1 -type f -name 'fcitx5-hazkey-*.tar.gz' -not -name 'fcitx5-hazkey.tar.gz' -delete
if [[ ! -f "$latest" ]] || ! cmp -s "$pkg" "$latest"; then
  cp "$pkg" "$latest"
fi
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
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

git -C "$root" config user.name "github-actions[bot]"
git -C "$root" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
if git -C "$root" diff --quiet -- dist; then
  echo "no artifact changes; skipping commit"
  exit 0
fi
git -C "$root" add dist
git -C "$root" commit -m "chore: update fcitx5-hazkey build ($sha)"
git -C "$root" push
