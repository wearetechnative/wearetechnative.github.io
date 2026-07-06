---
# wearetechnative.github.io-njxs
title: Hugo site scaffold, brand tokens & self-hosted assets
status: todo
type: epic
priority: high
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:37:00Z
parent: wearetechnative.github.io-lria
blocked_by:
    - wearetechnative.github.io-j5rf
---

Stand up the Hugo (extended) project skeleton: config, params, brand tokens, self-hosted fonts and vendored TechNative logos/favicons. No runtime third-party calls.

## Acceptance
- hugo.toml with baseURL=https://wearetechnative.github.io/, params, menus.
- config/_default/params.toml: brand tokens, social links, feature flags.
- content/_index.md landing front matter.
- assets/css source (Hugo Pipes → fingerprinted, minified) using approved brand tokens; WCAG AA in light+dark.
- assets/fonts: IBM Plex Sans + Mono woff2 vendored, @font-face declared.
- assets/img: TechNative colour SVG (header), footer PNG (light-on-dark), favicon derived from SVG mark.
- LICENSE (Apache-2.0) + NOTICE.

OpenSpec change: hugo-scaffold-brand
