# wearetechnative.github.io — task runner.
# Every target is a thin wrapper over `nix develop -c ...` so all work is hermetic.

# List available targets.
default:
    @just --list

# Live-preview server with drafts.
dev:
    nix develop -c hugo server --buildDrafts --disableFastRender

# Build the site into public/ (minified, garbage-collected).
build:
    nix develop -c hugo --minify --gc

# Fetch the GitHub repo snapshot into data/repos.json.
fetch:
    nix develop -c scripts/fetch-repos.sh

# Full verification: flake check + link-check + e2e smoke tests.
# Builds first so public/ exists for the checks.
verify: build
    nix develop -c nix flake check
    nix develop -c lychee --no-progress public
    nix develop -c npm --prefix tests test
