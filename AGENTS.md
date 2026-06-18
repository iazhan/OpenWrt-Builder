# Repository Guidelines

## Project Structure & Module Organization
This repository is a build wrapper for `LiBwrt/openwrt-6.x`, not the OpenWrt source tree itself. The main areas are:

- `configs/`: paired build inputs such as `*.config` and `*.cfg`
- `scripts/`: pre-build helpers, including `customize.sh`, `prepare-openwrt.sh`, and `diy-*.sh`
- `.github/workflows/`: CI, manual build, schedule, and validation pipelines
- `docs/`: supporting reference material

Keep new device support in matching `configs/<name>.config` and `configs/<name>.cfg` files, and keep custom build steps in numbered `scripts/diy-<n>-<name>.sh` files.

## Build, Test, and Development Commands
This repo is driven primarily through GitHub Actions. Local checks are lightweight:

- `bash -n scripts/*.sh` - syntax-check shell scripts
- `bash scripts/prepare-openwrt.sh <stage>` - run the same wrapper logic used by CI stages such as `pre-feeds`, `load-config`, or `run-diy-scripts`
- `git log --oneline -n 12` - review recent commit style before contributing

For full firmware builds, use the upstream OpenWrt workspace and the workflow logic in `.github/workflows/build-openwrt.yml` or `manual-build.yml`.

## Coding Style & Naming Conventions
Use POSIX-friendly shell where practical, `set -euo pipefail` for new scripts, and consistent two-space indentation inside YAML. Shell files should remain executable and readable on Ubuntu runners. Prefer descriptive lowercase names with hyphens or underscores. Follow the existing `diy-<number>-<description>.sh` pattern so `prepare-openwrt.sh` can discover scripts in order.

## Testing Guidelines
Validation is mostly configuration and shell safety checks. Before opening a PR, verify:

- shell syntax passes with `bash -n`
- every `configs/*.config` has a matching `configs/*.cfg` where required by the workflow
- new `diy-*.sh` files match the naming rule used by `validate-configs.yml`

There is no standalone unit test suite in this repository.

## Commit & Pull Request Guidelines
Recent history uses Conventional Commits style, e.g. `feat: ...` and `chore: ... [skip ci]`. Keep commit messages short, scoped, and factual. PRs should explain what changed, which device or workflow it affects, and whether config files, scripts, or Actions behavior changed. Include logs or screenshots only when they help explain a build result.

## Security & Configuration Tips
Do not commit secrets, private release tokens, or machine-specific paths. Treat `scripts/third-party-sources.sh` and `configs/*.cfg` as shared configuration sources and review them carefully when changing upstream revisions or release metadata.
