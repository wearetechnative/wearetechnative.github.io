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

# Install the Playwright test dependencies (browsers come from the flake).
test-install:
    nix develop -c npm --prefix tests ci

# Run the Playwright e2e smoke suite against the built public/ (must `just build` first).
test:
    nix develop -c npm --prefix tests test

# Link-check the built site. --root-dir resolves the site's root-relative
# (/fonts, /img, /css) links the way GitHub Pages serves them.
linkcheck:
    nix develop -c lychee --no-progress --root-dir "{{justfile_directory()}}/public" public

# Full verification: flake check + link-check + e2e smoke tests.
# Builds first so public/ exists for the checks.
verify: build test-install
    nix develop -c nix flake check
    just linkcheck
    just test

# Measure the Lighthouse budget (Performance >= 90, Accessibility >= 95).
# Requires a Chromium; uses the flake's Playwright browser. Serves public/ first.
lighthouse:
    @echo "Run: nix develop -c npx --prefix tests lighthouse http://localhost:4173 --preset=desktop"
    @echo "(serve public/ with 'nix develop -c node tests/serve.mjs' in another shell)"
