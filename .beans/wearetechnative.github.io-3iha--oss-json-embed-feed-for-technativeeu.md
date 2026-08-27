---
# wearetechnative.github.io-3iha
title: OSS JSON embed feed for technative.eu
status: completed
type: epic
priority: high
created_at: 2026-08-27T11:18:16Z
updated_at: 2026-08-27T12:14:13Z
parent: wearetechnative.github.io-i1eg
---

Publish a stable, versioned oss.json feed (schema technative-oss/v1) at a fixed GitHub Pages path, re-rendering the existing repos.json+curation.yaml merge as JSON via a Hugo output format. Feed-only: no hosted widget, no iframe. technative.eu (static SSG) pulls it at build time and renders with its own styling.

OpenSpec change: oss-json-embed-feed (archived 2026-08-27-oss-json-embed-feed)

## Summary of Changes

- `hugo.toml`: added a JSON output format for the `home` kind, pinning the filename to `oss.json` (`isPlainText`, `notAlternative`) so the feed publishes at the stable path `https://wearetechnative.github.io/oss.json`.
- `layouts/index.json`: new template rendering the SAME `partial "data/projects.html"` merge output as JSON in a `technative-oss/v1` envelope — `schema`, `generated_at` (RFC 3339 UTC), `source`, `org`, machine-derived `totals` (projects/stars/forks), and `categories`. Empty categories omitted; site ordering/sort preserved.
- `scripts/check-feed.sh`: hermetic jq validator asserting the feed conforms to `technative-oss/v1` (schema tag, envelope keys, per-project field types, totals == emitted projects). Wired into `just verify` via a new `feedcheck` target.
- `tests/smoke.spec.ts`: Playwright assertion that `/oss.json` is served, parses, and conforms.
- `README.md`: documented the schema, the stable URL, the `v1`-frozen public-API contract, and a build-time consumer snippet; added a "Before going live" checklist item.

Verification: `nix flake check` passes; hermetic package build emits `oss.json` (valid even with empty data); `just verify` green with real data (feedcheck OK, lychee 107/0, Playwright 8/8). The `v1` path + field shapes are a published contract — breaking changes ship as `v2`.
