---
# wearetechnative.github.io-sfo8
title: 'CI/CD: GitHub Actions deploy to Pages + daily refresh'
status: todo
type: epic
priority: normal
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:37:00Z
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
