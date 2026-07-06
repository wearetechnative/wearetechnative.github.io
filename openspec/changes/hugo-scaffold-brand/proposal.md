## Why

Hugo needs a real project skeleton — config, params, brand tokens, and vendored
assets — before any page or partial can be built (brief §3, §7). This also lands
`packages.default` in the flake (deferred from `nix-flake-devenv`) so the site
builds hermetically end to end.

## What Changes

- Add `hugo.toml`: `baseURL = "https://wearetechnative.github.io/"`, params,
  category menus.
- Add `config/_default/params.toml`: brand tokens, social links, feature flags
  (incl. `analytics.umami`, default on — see `openspec/project.md`).
- Add `content/_index.md`: landing front matter + optional intro body.
- Add `assets/css/`: source CSS via Hugo Pipes (fingerprinted, minified) using
  the approved brand tokens; verify WCAG AA in light and dark.
- Vendor `assets/fonts/`: IBM Plex Sans + IBM Plex Mono woff2, declared via
  `@font-face`. No CDN.
- Vendor `assets/img/`: TechNative colour SVG (header), footer light-on-dark PNG,
  favicon derived from the SVG mark (org-avatar fallback).
- Add `packages.default` to `flake.nix` building the site with Hugo; keep
  `nix flake check` green.

## Capabilities

### New Capabilities
- `site-shell`: The Hugo project configuration, brand-token design system, and
  self-hosted font/logo assets that every page renders within.

## Impact

- New: `hugo.toml`, `config/_default/params.toml`, `content/_index.md`,
  `assets/css/**`, `assets/fonts/**`, `assets/img/**`; `packages.default` in the
  flake.
- Depends on: `dev-environment`. Blocks: `landing-page-ui`.
- Constraint: no runtime third-party calls except the approved Umami tracker;
  fonts and logos are vendored.
