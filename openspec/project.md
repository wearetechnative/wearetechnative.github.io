# Project Context — wearetechnative.github.io

## Purpose

The public open-source portfolio site for the `wearetechnative` GitHub
organisation, served at `https://wearetechnative.github.io/`. A single, fast,
filterable landing page that makes ~93 public repos legible to two audiences:
**cloud engineers** (Terraform, AWS, NixOS, TUIs) and **open-source people**
(the awesome lists, the "battery-included self-hostable" story). Real TechNative
branding, recognisably a developer/OSS site.

This is the org's public OSS home. The authoritative spec is
`BRIEF-wearetechnative-portfolio-site.md` at the repo root — treat it as the
source of truth for every proposal and always re-read the relevant section.

## Hard constraints (non-negotiable)

1. **Hosting:** GitHub Pages, org root. Repo named `wearetechnative.github.io`.
   `baseURL = "https://wearetechnative.github.io/"`.
2. **Generator:** Hugo (extended), pinned via Nix — no floating versions.
3. **Hermetic build:** everything runs through a Nix flake.
   `nix develop -c hugo --minify` builds with zero errors; `nix flake check`
   passes. No global toolchain assumptions.
4. **Nix flakes without flake-utils.** Supported architectures are wired with
   plain nix (a `forAllSystems` helper over an explicit systems list):
   `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`.
5. **Flat files only.** No database, no runtime backend. All data is YAML/JSON on
   disk, consumed by Hugo at build time.
6. **No runtime third-party calls — one approved exception: Umami analytics.**
   Self-host fonts and logo assets (vendored). No Google Fonts CDN. The GitHub
   API is called **only at build time**, never from the browser. The single
   sanctioned runtime external request is Pim's self-hosted, privacy-preserving
   Umami tracker (see "Analytics" below); the Playwright network-origin
   assertion must allow-list `umami.pimsnel.com` alongside GitHub origins.
7. **Honesty in framing.** Every factual claim on the site must be verifiable.
   Repo names, descriptions, languages, stars, last-updated come straight from
   the GitHub API — never invent or embellish. No fabricated metrics,
   testimonials, case studies, or superlatives. Any prose not machine-sourced is
   a placeholder flagged `<!-- NEEDS PIM APPROVAL: ... -->`.
8. **License:** repos are Apache-2.0; the site repo ships under Apache-2.0 with a
   `LICENSE` and `NOTICE`.

## Tech Stack

- **Static site generator:** Hugo extended (pinned via Nix).
- **Build/dev environment:** Nix flakes (plain nix, no flake-utils).
- **Task runner:** `just` — every repeatable action is a thin wrapper over
  `nix develop -c ...`.
- **Data tooling:** `curl` + `jq` only (both in the flake). Prefer these and
  vanilla JS over adding tools.
- **Client-side:** vanilla JS only — no React/Vue/framework. Progressive
  enhancement: the full grid renders with JS disabled.
- **Testing:** Playwright (e2e smoke), `lychee` (link-check), Lighthouse (perf/
  a11y budget).
- **CI/CD:** GitHub Actions → GitHub Pages, with a daily cron refresh.
- **Fonts:** self-hosted IBM Plex Sans (UI/body) + IBM Plex Mono (repo names,
  commands, language labels), woff2 vendored, declared via `@font-face`.

## Brand tokens

```
--tn-green:      #86c33a   /* TechNative primary */
--tn-green-700:  #6ba52e   /* hover/active (verify AA contrast) */
--tn-ink:        #1e2327   /* charcoal — dark base / body text */
--tn-paper:      #ffffff
--tn-paper-soft: #f7f8f5
--tn-muted:      #5b6570
```

Ship **light-first** with a **dark-mode toggle** (dark base `--tn-ink`). All text
must meet WCAG AA in both modes. Voice: confident, technical, peer-to-peer to
engineers — no marketing fluff.

## Analytics (approved runtime exception)

Pim's self-hosted, cookieless Umami instance provides privacy-preserving page
analytics. Inject this snippet in `layouts/partials/head.html`, guarded behind a
`params.analytics.umami` feature flag (default **on**) so it can be toggled
without touching the template:

```html
<script async src="https://umami.pimsnel.com/script.js"
  data-website-id="a225a8cb-2309-4c1d-8f36-ec1c67e00e90"></script>
```

This is the **only** permitted runtime third-party request. It is not vendored
(Umami's script must load from the tracker host). The Playwright network
assertion allow-lists `umami.pimsnel.com`. Note in the README that Umami is
active and how to disable it via the feature flag.

## Categories (approved display order; hide empties)

1. **ElastiNix** — flagship. NixOS on AWS + battery-included self-hostable apps.
2. **Terraform Modules** — the `terraform-aws-module-*` family.
3. **Cloud-Engineer Tools** — TUIs/CLIs (`bmc`, `race`, `jira*`, etc.).
4. **Awesome Lists** — `awesome-flake-parts`, `awesome-finops`, future `awesome-*`.
5. **Other** — everything else worth showing (e.g. `TeXnative`).

## Project Conventions

### Repository layout

Follow the layout in `BRIEF-…§3` exactly. Key rules:
- Commit `data/curation.yaml`, `flake.lock`, vendored assets.
- Git-ignore `data/repos.json` (auto-generated) and `public/`.

### Data model (hybrid: auto + curated)

- **Auto layer** `data/repos.json` — generated, git-ignored. GitHub API snapshot.
- **Curated layer** `data/curation.yaml` — committed, human-owned overlay.
- **Merge** (per `BRIEF-…§4b`): exclude forks/archived/templates by default;
  `include: true` opts back in; `category_rules` first-match-wins; per-repo
  overrides; `blurb` falls back to GitHub `description`; sort featured → stars →
  `pushed_at`.

### Content requiring approval (do not invent — `BRIEF-…§9`)

Hero headline+sub-line, ElastiNix spotlight paragraph, footer "why we
open-source" blurb, the `optscale` fork decision (default off), the X/Twitter
footer link (default off). Every placeholder wrapped
`<!-- NEEDS PIM APPROVAL: ... -->` and listed at the top of the README under
"Before going live".

### Out of scope (`BRIEF-…§11`)

Per-project pages, blog/news, i18n, CMS, comments, search backend, custom domain.
Single page only. Leave a commented CNAME stub note in the README; build nothing.

## Workflow (how work is tracked and shipped)

- **Issue tracking:** `beans`. Milestones (`01 …`, `02 …`) contain epics; epics
  contain tasks. Keep bean todo items current; mark completed only when all todos
  are checked. See `CLAUDE.md` for the full loop.
- **Spec-driven changes:** OpenSpec. One change per epic (`proposal → specs →
  design → tasks`). Implement via `/opsx:apply`, then archive.
- **Version control:** `jj` (Jujutsu). Commit after **every** OpenSpec change
  archival. Commit as **Pim Snel** — no self-promotion, no co-author trailers.

## Acceptance criteria (the PoC is "done" only when all pass — `BRIEF-…§10`)

- `nix flake check` passes.
- `nix develop -c hugo --minify --gc` builds `public/` with 0 errors, 0 warnings.
- `scripts/fetch-repos.sh` produces valid `data/repos.json` covering all public
  repos (paginated); exits non-zero on API failure.
- Merge logic correct (forks/archived/templates excluded; `optscale` only if
  `include: true`; `elastinix` featured + grouped; awesome lists categorised).
- `lychee` link-check on `public/` — no broken internal links.
- Playwright `smoke.spec.ts` passes headless (load, search, filter, category
  toggle, dark-mode flips `data-theme` + persists, no console errors).
- No runtime requests to non-GitHub origins (verified in Playwright).
- Grid renders with JavaScript disabled.
- Lighthouse: Performance ≥ 90, Accessibility ≥ 95 (command in README).
- README documents local dev, curation, the one-time Pages toggle, and the
  "Before going live" approval list.
