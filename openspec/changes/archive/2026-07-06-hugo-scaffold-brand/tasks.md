## 1. Hugo configuration

- [x] 1.1 Add `hugo.toml` with `baseURL = "https://wearetechnative.github.io/"`, title, and category menu anchors.
- [x] 1.2 Add `config/_default/params.toml`: brand tokens, social links (org, technative.eu, LinkedIn), feature flags incl. `[analytics] umami = true`.
- [x] 1.3 Add `content/_index.md` landing front matter.

## 2. Brand design system

- [x] 2.1 Add `assets/css/main.css`: `:root` brand tokens + `[data-theme="dark"]` block, base typography, light-first.
- [x] 2.2 Verify WCAG AA contrast for body/muted/green text in both modes.
- [x] 2.3 Wire CSS through Hugo Pipes (minify + fingerprint) — referenced from a stub head partial so the build resolves.

## 3. Self-hosted fonts & vendored assets

- [x] 3.1 Vendor IBM Plex Sans (Regular/Medium/SemiBold) + IBM Plex Mono (Regular/Medium) woff2 into `assets/fonts/`.
- [x] 3.2 Declare local `@font-face` rules (`font-display: swap`); no CDN.
- [x] 3.3 Vendor TechNative colour SVG (header) + footer PNG into `assets/img/`; derive a favicon (org-avatar fallback).

## 4. Flake package

- [x] 4.1 Add `packages.default` to `flake.nix` building the site with `hugo --minify --gc` (placeholder `data/repos.json` for offline reproducibility).
- [x] 4.2 `nix build .#default` succeeds; `nix flake check` still passes.

## 5. Verification

- [x] 5.1 `nix develop -c hugo --minify --gc` builds `public/` with 0 errors (with a placeholder `data/repos.json`).
- [x] 5.2 No CDN/hotlink references in built output (fonts + logos local).
