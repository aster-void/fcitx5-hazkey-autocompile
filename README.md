# fcitx5-hazkey-autocompile

Automated mirror that compiles [fcitx5-hazkey](https://github.com/7ka-Hiira/fcitx5-hazkey) on a 3 hour cadence and commits the resulting tarball when upstream changes.

## Layout

- `scripts/`: workflow helpers for cloning, building, and publishing.
- `dist/`: tracked build artifacts keyed by upstream commit. Populated by CI.

## Usage

Run `Sync Build` workflow manually or wait for the scheduled trigger. The workflow:

1. Clones the upstream repository.
2. Replays its official build pipeline inside CI.
3. Publishes a tarball plus metadata when the upstream commit is new.

All outputs are committed back to the default branch using the GitHub Actions token.
