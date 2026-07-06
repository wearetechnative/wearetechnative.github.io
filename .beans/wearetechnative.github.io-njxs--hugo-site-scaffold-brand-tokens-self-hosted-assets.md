---
# wearetechnative.github.io-njxs
title: Hugo site scaffold, brand tokens & self-hosted assets
status: completed
type: epic
priority: high
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:47:08Z
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

## Summary of Changes

Delivered the Hugo project skeleton, brand system, and vendored assets (OpenSpec change hugo-scaffold-brand, archived 2026-07-06).

- hugo.toml (baseURL org root, category menus), config/_default/params.toml (brand tokens, org links, umami analytics flag + optscale flag).
- assets/css/main.css: full brand-token design system, light-first + [data-theme=dark], WCAG-AA-aware, via Hugo Pipes (minify+fingerprint).
- Self-hosted IBM Plex Sans (400/500/600) + Mono (400/500) woff2 in static/fonts; local @font-face + preloads. No CDN.
- Vendored TechNative colour SVG (header) + footer PNG + org-avatar favicon in assets/img.
- head.html partial with favicon, fingerprinted CSS, font preloads, and the flag-gated Umami snippet.
- packages.default in the flake builds the site offline (placeholder repos.json).

Verified: hugo --minify --gc builds with 0 warnings/0 errors; nix build .#default succeeds; nix flake check passes; no external CDN refs in output (only wearetechnative.github.io + umami.pimsnel.com).

Note: layouts/index.html is a minimal placeholder here; the full page lands in landing-page-ui.
