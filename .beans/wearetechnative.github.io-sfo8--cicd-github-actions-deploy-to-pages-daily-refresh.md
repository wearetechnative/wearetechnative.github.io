---
# wearetechnative.github.io-sfo8
title: 'CI/CD: GitHub Actions deploy to Pages + daily refresh'
status: completed
type: epic
priority: normal
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T14:10:34Z
parent: wearetechnative.github.io-lria
blocked_by:
    - wearetechnative.github.io-poii
---

Ship it. Single workflow: fetch → build (Nix) → verify → deploy to GitHub Pages, with a daily cron so the grid stays fresh.

## Acceptance
- .github/workflows/deploy.yml: on push[main] + schedule(cron 0 6 * * *) + workflow_dispatch; permissions contents:read/pages:write/id-token:write; concurrency group pages cancel-in-progress.
- Steps: checkout → install Nix (DeterminateSystems + cache, flakes on) → fetch (nix develop -c scripts/fetch-repos.sh with GITHUB_TOKEN) → build (nix develop -c hugo --minify --gc) → verify (flake check + lychee + Playwright on served public/) → deploy (configure-pages/upload-pages-artifact/deploy-pages). Deploy gated on verify.
- Action versions pinned to current majors.
- README documents one-time Pages='GitHub Actions' source toggle + CNAME stub note.

OpenSpec change: ci-cd-deploy

## Summary of Changes

Delivered the CI/CD pipeline (OpenSpec change ci-cd-deploy, archived 2026-07-06).

- .github/workflows/deploy.yml: triggers push[main] + schedule(cron 0 6 * * *) + workflow_dispatch; permissions contents:read/pages:write/id-token:write; concurrency group pages cancel-in-progress.
- build job: checkout@v7 -> nix-installer-action@v22 + magic-nix-cache-action@v14 -> fetch-repos.sh (GITHUB_TOKEN) -> `just verify` (build+flake check+lychee+Playwright, CI=true) -> configure-pages@v6 + upload-pages-artifact@v5 (path public).
- deploy job: needs build (gates on verify), deploy-pages@v5 to github-pages env.
- README: one-time Pages source toggle + commented CNAME stub.

Verified locally: workflow is valid YAML, all 6 actions pinned to current majors; `just verify` (the exact CI command) passes — flake check OK, lychee 107/107, Playwright 7/7.

## Remaining (manual, post-merge)
Task 5.3: after Pages source is set to "GitHub Actions" in repo Settings, trigger the workflow and confirm the run is green + site publishes. This needs the workflow on main + the one-time settings toggle, so it cannot be done in this session.


## Manual step completed (this session)

Pages source switched to "GitHub Actions" (build_type=workflow) via the API, and a workflow_dispatch run completed green (build+verify+deploy). The site is LIVE at https://wearetechnative.github.io/ serving 82 cards and the computed "82 public repositories" hero. Task 5.3 satisfied.

Follow-up: quieted the non-fatal FlakeHub login warning by setting determinate:false on nix-installer-action.
