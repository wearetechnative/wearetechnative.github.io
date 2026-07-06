---
# wearetechnative.github.io-qq8l
title: 'Data pipeline: GitHub fetch + curation merge'
status: completed
type: epic
priority: high
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:50:59Z
parent: wearetechnative.github.io-lria
blocked_by:
    - wearetechnative.github.io-j5rf
---

Build the flat-file data layer: fetch all ~93 public repos from the GitHub REST API at build time and merge with the hand-maintained curation overlay into one categorised list of project objects.

## Acceptance
- scripts/fetch-repos.sh: curl+jq, paginated (per_page=100, follow Link rel=next), authenticated via GITHUB_TOKEN with unauthenticated fallback + warning. Writes normalised data/repos.json. Exits non-zero on API error.
- data/curation.yaml: committed overlay (defaults, exclude rules, category_rules, per-repo overrides, elastinix_group).
- Merge logic (Hugo partial or jq pre-step): exclude forks/archived/templates by default; include:true opt-in; category_rules first-match-wins; per-repo overrides; featured+blurb fallback to GitHub description; sort featured→stars→pushed_at.
- data/repos.json git-ignored; curation.yaml + flake.lock committed.

OpenSpec change: data-pipeline

## Summary of Changes

Delivered the flat-file data pipeline (OpenSpec change data-pipeline, archived 2026-07-06).

- scripts/fetch-repos.sh: curl+jq, paginated (per_page=100, follows Link rel=next), GITHUB_TOKEN auth with unauthenticated-fallback warning, atomic write, fails non-zero on API error or empty result. Verified: fetched 93 repos.
- data/curation.yaml: committed overlay (defaults+excludes, first-match category_rules, per-repo overrides, elastinix_group). optscale include:false pending approval.
- layouts/partials/data/projects.html: Hugo merge — exclusions with include opt-in, category rules, per-repo overrides, blurb fallback, sort featured→stars→pushed_at. Uses hugo.Data (no deprecation).

Verified merge: elastinix featured+grouped (1); terraform-modules 48; tools 4; awesome-lists 4; other 25; optscale absent; this site + .github excluded; empty [] placeholder renders without crashing. 0 Hugo warnings.
