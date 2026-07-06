## Why

The site must ship to GitHub Pages automatically and stay fresh without manual
pushes (brief §8). This is the final epic: it composes fetch → build → verify →
deploy into one gated workflow with a daily refresh cron.

## What Changes

- Add `.github/workflows/deploy.yml`:
  - Triggers: `push` to `main`, `schedule` (`cron: "0 6 * * *"` — daily metadata
    refresh), `workflow_dispatch`.
  - `permissions: { contents: read, pages: write, id-token: write }`.
  - `concurrency: { group: pages, cancel-in-progress: true }`.
  - Steps: `actions/checkout` → install Nix
    (`DeterminateSystems/nix-installer-action` + a Nix cache action, flakes on) →
    **fetch** (`nix develop -c scripts/fetch-repos.sh`, `GITHUB_TOKEN:
    ${{ github.token }}`) → **build** (`nix develop -c hugo --minify --gc`) →
    **verify** (`nix flake check` + `lychee` + Playwright on served `public/`) →
    **deploy** (`actions/configure-pages` → `actions/upload-pages-artifact` path
    `public/` → `actions/deploy-pages`). Deploy job gated on verify success.
  - Pin all action versions to their current majors at implementation time.
- Document in the README the one-time manual step: Settings → Pages → source
  "GitHub Actions". Leave the commented CNAME/custom-domain stub note.

## Capabilities

### New Capabilities
- `ci-deploy`: The GitHub Actions pipeline that fetches, builds, verifies, and
  deploys the site to Pages, plus the daily metadata-refresh schedule.

## Impact

- New: `.github/workflows/deploy.yml`; README Pages/CNAME notes.
- Depends on: `verification` (verify must gate deploy) and every prior capability.
- Constraint: verify must pass before deploy; Pages source toggle is a documented
  manual one-time step.
