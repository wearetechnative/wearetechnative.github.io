## 1. Page shell

- [x] 1.1 Rewrite `layouts/index.html`: compute merged data once, compute repo count, assemble sections in order.
- [x] 1.2 Pass merged data + count to section partials via context dicts.

## 2. Section partials

- [x] 2.1 `partials/header.html`: logo→technative.eu, title, category nav (only non-empty), dark-mode toggle button, View on GitHub.
- [x] 2.2 `partials/hero.html`: engineer-to-engineer line + computed "N public repositories" sub-line; CTAs (org, ElastiNix). Prose flagged.
- [x] 2.3 `partials/elastinix-spotlight.html`: factual band, member mini-cards, link to elastinix flake. Prose flagged.
- [x] 2.4 `partials/filters.html`: sticky bar — search input, category chips, language dropdown, sort select (markup only).
- [x] 2.5 `partials/project-grid.html`: per-category sections (hidden if empty); accessible cards with data-* attributes.
- [x] 2.6 `partials/awesome.html`: distinct band highlighting the awesome lists.
- [x] 2.7 `partials/footer.html`: vendored footer logo, flagged blurb, org/technative.eu/LinkedIn links, © current year, Apache-2.0; X/Twitter commented.

## 3. Accessibility & progressive enhancement

- [x] 3.1 Cards keyboard-focusable + screen-reader labelled; relative time with exact date in title.
- [x] 3.2 Confirm full grid renders with JS disabled (no JS yet — inherently true; verify markup).

## 4. Verification

- [x] 4.1 `nix develop -c hugo --minify --gc` builds with 0 warnings, 0 errors.
- [x] 4.2 Grid shows ~82 cards across categories; empty categories + their nav anchors hidden.
- [x] 4.3 Repo count in hero matches rendered card count; no external CDN refs; Umami present.
