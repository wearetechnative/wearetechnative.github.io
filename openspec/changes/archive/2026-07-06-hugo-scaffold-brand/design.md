## Context

`nix-flake-devenv` gave us a devShell with hugo-extended but no Hugo project. This
change adds the project skeleton, brand system, and vendored assets, and promotes
`packages.default` in the flake so the site builds hermetically end to end. It is
the last dependency (with `data-pipeline`) before the landing page can render.

## Goals / Non-Goals

**Goals:**
- A minimal, correct Hugo config targeting the org Pages root.
- The brand-token CSS design system (light-first + dark), WCAG AA.
- Self-hosted IBM Plex fonts + vendored TechNative logos/favicon.
- `packages.default` building the site under Nix.

**Non-Goals:**
- The landing-page layout/partials — that is `landing-page-ui`.
- Any repo data or merge logic — that is `data-pipeline`. This change only needs
  a placeholder so `hugo` builds; the real grid arrives with the UI epic.

## Decisions

- **Config format:** `hugo.toml` (top-level) + `config/_default/params.toml` for
  brand tokens, social links, and feature flags — matches the brief layout and
  keeps params separable.
- **CSS via Hugo Pipes:** a single `assets/css/main.css` → `resources.Minify |
  resources.Fingerprint`, referenced from the head partial (added in the UI
  epic; for now a stub head so the build resolves). Brand tokens live in `:root`
  and a `[data-theme="dark"]` block.
- **Fonts:** download IBM Plex Sans (Regular/Medium/SemiBold) and IBM Plex Mono
  (Regular/Medium) woff2 into `assets/fonts/`, declared with `font-display: swap`
  local `@font-face`. OFL license noted in NOTICE (already present).
- **Logos:** fetch the colour SVG and footer PNG from technative.eu at build-
  authoring time and vendor them; derive a favicon from the SVG mark (fallback to
  the org avatar if the SVG can't be rasterised).
- **`packages.default`:** `pkgs.stdenvNoCC.mkDerivation` running
  `hugo --minify --gc` with the flake source as `src`, output to `$out`. Because
  the build needs `data/repos.json` (git-ignored), the package build supplies an
  empty/placeholder `data/repos.json` so `nix build` is reproducible without
  network; the real data is fetched in CI/dev before `just build`.
- **Umami flag:** `[analytics]\numami = true` in params; the head partial (UI
  epic) reads it. Keeping the flag here means the toggle exists before the
  snippet is wired.

## Risks / Trade-offs

- Vendoring assets from technative.eu is a one-time authoring fetch, not a runtime
  call — consistent with §5. If a URL 404s, fall back to the org avatar and flag
  it for Pim.
- `packages.default` needs a placeholder `data/repos.json` to build offline;
  documented so no one mistakes the Nix-built site for one with live data. `just
  build` (after `just fetch`) is the path that produces the real grid.
