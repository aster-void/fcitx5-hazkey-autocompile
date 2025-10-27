# fcitx5-hazkey-autocompile

Automated mirror that compiles [fcitx5-hazkey](https://github.com/7ka-Hiira/fcitx5-hazkey) on a 3 hour cadence and commits the resulting tarball when upstream changes.

## Layout

- `scripts/run.sh`: single entrypoint that clones, rebuilds, publishes, and commits.
- `dist/`: contains the most recent build artifact and metadata. Populated by CI.

## Usage

Run `Sync Build` workflow manually or wait for the scheduled trigger. The workflow shells into `scripts/run.sh` to:

1. Clone the upstream repository (fresh each run).
2. Rebuild only when `dist/latest.json` doesn’t match the upstream SHA.
3. Refresh the tarball and manifest in `dist/`, then commit the results.

If the upstream head matches the revision recorded in `dist/latest.json`, the workflow exits early without rebuilding.

The latest build is always available as `dist/fcitx5-hazkey.tar.gz`, replacing the previous artifact on each update.

All outputs are committed back to the default branch using the GitHub Actions token.
