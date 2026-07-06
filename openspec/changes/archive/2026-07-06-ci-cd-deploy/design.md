## Context

Everything builds and verifies locally through `just verify`. This epic wires that
same flow into GitHub Actions and deploys to Pages, with a daily cron so the grid
refreshes without pushes. It's the last milestone-01 epic; after it, a one-time
Pages settings toggle makes the site live.

## Goals / Non-Goals

**Goals:**
- One workflow: fetch → build → verify → deploy, deploy gated on verify.
- Triggers: push to `main`, `workflow_dispatch`, daily `schedule`.
- Correct Pages permissions + concurrency; all actions pinned.
- README: the one-time Pages toggle + a commented CNAME stub.

**Non-Goals:**
- Enabling Pages in repo settings — that cannot be scripted; documented instead.
- A custom domain — out of scope; only a commented stub note.

## Decisions

- **Two jobs, `build` then `deploy`.** `build` does fetch+build+verify and uploads
  the Pages artifact; `deploy` `needs: build` and only runs the Pages deployment.
  A failed verify fails `build`, so `deploy` is skipped — this is the gating.
- **Pinned actions (current majors, verified at authoring time 2026-07-06):**
  - `actions/checkout@v7`
  - `DeterminateSystems/nix-installer-action@v22` (flakes enabled by default)
  - `DeterminateSystems/magic-nix-cache-action@v14` (active; speeds Nix eval/builds)
  - `actions/configure-pages@v6`
  - `actions/upload-pages-artifact@v5`
  - `actions/deploy-pages@v5`
- **Verify in CI = `just verify`** minus the build (build already ran): run
  `nix develop -c nix flake check`, `just linkcheck`, and the Playwright suite.
  To reuse the local target exactly, CI calls `just verify` which rebuilds; the
  rebuild is cheap and keeps one source of truth. Playwright browsers come from
  the flake (`PLAYWRIGHT_BROWSERS_PATH` is set inside the devShell), so CI needs
  no browser download.
- **Fetch auth:** `scripts/fetch-repos.sh` reads `GITHUB_TOKEN`; the workflow sets
  `GITHUB_TOKEN: ${{ github.token }}` on the fetch step. The default token has
  read access to public repos — sufficient, and lifts the 60/h unauthenticated
  limit to 1000/h.
- **Permissions/concurrency** exactly per the brief: `contents: read`,
  `pages: write`, `id-token: write`; `concurrency: { group: pages,
  cancel-in-progress: true }`.
- **Env for verify:** set `CI: true` so Playwright uses the `line` reporter and
  `forbidOnly`.

## Risks / Trade-offs

- `magic-nix-cache-action` depends on GitHub Actions cache; if it ever sunsets,
  swap for another cache action — the build still works without it, just slower.
  Noted.
- Calling `just verify` in CI rebuilds the site once more after the explicit build
  step. Marginally redundant but keeps CI and local identical — one source of
  truth beats shaving a few seconds. Documented.
- The first successful run still won't publish until Pages source is set to
  "GitHub Actions" in settings — a documented manual step.
