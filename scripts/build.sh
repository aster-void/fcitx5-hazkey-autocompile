#!/usr/bin/env bash
set -euo pipefail
root="$(git rev-parse --show-toplevel)"; work="$root/work"; upstream="$work/upstream"
build="$work/build"; dest="$work/workdir"; packs="$work/packages"; pkg="$packs/fcitx5-hazkey.tar.gz"
mkdir -p "$build" "$dest" "$packs"
sudo apt-get update -y
sudo apt-get install -y build-essential cmake gettext fakeroot protobuf-compiler \
  libprotobuf-dev libprotoc-dev libabsl-dev libabsl20210324 libfcitx5core-dev \
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

for comp in hazkey-server hazkey-settings fcitx5-hazkey; do
  cmake -S "$upstream/$comp" -B "$build/$comp" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -G Ninja
  ninja -C "$build/$comp" -j"$(nproc)"
  DESTDIR="$dest" ninja -C "$build/$comp" install
done

tar -czf "$pkg" -C "$dest" usr
