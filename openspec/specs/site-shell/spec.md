# site-shell Specification

## Purpose
TBD - created by archiving change hugo-scaffold-brand. Update Purpose after archive.
## Requirements
### Requirement: Hugo project configuration

The site SHALL be a Hugo project configured for GitHub Pages at the org root, with
the production base URL and category navigation defined in config.

#### Scenario: base URL is the org Pages root

- **WHEN** `hugo.toml` is inspected
- **THEN** `baseURL` is `https://wearetechnative.github.io/`

#### Scenario: build succeeds hermetically

- **WHEN** `nix develop -c hugo --minify --gc` is run with a populated
  `data/repos.json`
- **THEN** it writes `public/` with no errors

#### Scenario: site builds via the flake package

- **WHEN** `nix build .#default` is run
- **THEN** the built site is produced in the result output and `nix flake check`
  still passes

### Requirement: Brand design system

The site SHALL define the approved TechNative brand tokens as CSS custom
properties and meet WCAG AA contrast in both light and dark modes.

#### Scenario: brand tokens are defined

- **WHEN** the compiled CSS is inspected
- **THEN** it declares `--tn-green` `#86c33a`, `--tn-green-700` `#6ba52e`,
  `--tn-ink` `#1e2327`, `--tn-paper` `#ffffff`, `--tn-paper-soft` `#f7f8f5`, and
  `--tn-muted` `#5b6570`

#### Scenario: light-first with dark base

- **WHEN** the page loads with no theme override
- **THEN** it renders light-first; when `data-theme="dark"` is set the base is
  `--tn-ink`

#### Scenario: CSS is fingerprinted

- **WHEN** the site is built
- **THEN** the stylesheet is processed through Hugo Pipes (minified and
  fingerprinted)

### Requirement: Self-hosted fonts and vendored assets

The site SHALL self-host all fonts and vendor all logo/favicon assets — no
runtime CDN or hotlinking.

#### Scenario: fonts are self-hosted woff2

- **WHEN** `assets/fonts/` is inspected
- **THEN** it contains IBM Plex Sans and IBM Plex Mono woff2 files declared via
  local `@font-face` rules — no Google Fonts or other CDN reference

#### Scenario: logos and favicon are vendored

- **WHEN** `assets/img/` is inspected
- **THEN** it contains the TechNative colour logo (header), a light-on-dark
  footer logo, and a favicon derived from the mark — all local files

### Requirement: Feature flags and params

The site SHALL expose brand tokens, social links, and feature flags via params,
including an analytics toggle for the approved Umami tracker.

#### Scenario: umami analytics flag exists and defaults on

- **WHEN** `config/_default/params.toml` is inspected
- **THEN** an `analytics.umami` flag exists and defaults to enabled

