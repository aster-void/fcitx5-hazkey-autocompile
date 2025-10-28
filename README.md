# fcitx5-hazkey-autocompile

Automated mirror that tracks [fcitx5-hazkey](https://github.com/7ka-Hiira/fcitx5-hazkey) as the primary payload. Each run installs fcitx5-hazkey and, for convenience, bundles the latest binaries from [llama.cpp](https://github.com/azooKey/llama.cpp) into the same archive.

## Layout

- `scripts/run.sh`: single entrypoint that clones both upstreams, rebuilds, publishes, and commits.
- `dist/`: contains the most recent build artifact and metadata (including both SHAs). Populated by CI.

## Usage

Run `Sync Build` workflow manually or wait for the scheduled trigger. The workflow runs on GitHub's `ubuntu-24.04` image and shells into `scripts/run.sh` to:

1. Clone fcitx5-hazkey (and llama.cpp for the bundled extras) fresh each run.
2. Rebuild only when `dist/latest.json` doesn’t match either upstream SHA.
3. Refresh the tarball and manifest in `dist/`, then commit the results.

If both upstream heads match the revisions recorded in `dist/latest.json`, the workflow exits early without rebuilding.

The latest build is always available as `dist/fcitx5-hazkey.tar.gz`, replacing the previous artifact on each update. The archive contains the installed fcitx5-hazkey tree, plus the llama.cpp executables, headers, and shared libraries placed alongside it for downstream use.

All outputs are committed back to the default branch using the GitHub Actions token.
