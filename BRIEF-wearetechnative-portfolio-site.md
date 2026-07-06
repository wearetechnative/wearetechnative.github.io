# Oneshotter Brief — `wearetechnative` Open-Source Portfolio Site

**Deliverable owner:** Claude Code (autonomous implementation)
**Requested by:** Pim / TechNative B.V.
**Target repo:** `wearetechnative/wearetechnative.github.io`
**Serves at:** `https://wearetechnative.github.io/`
**Status of this brief:** complete and self-contained. Implement in one pass, then run the verification suite in §10 and report results.

---

## 1. Mission

Build the public open-source portfolio site for the `wearetechnative` GitHub organisation: a single, fast, filterable landing page that makes ~93 public repos legible to two audiences at once — **cloud engineers** (Terraform, AWS, NixOS, TUIs) and **open-source people** (the awesome lists, the "battery-included self-hostable" story). It carries real TechNative branding while staying recognisably a developer/OSS site.

This is *the org's public OSS home*. Treat quality and correctness accordingly.

## 2. Hard constraints (non-negotiable)

1. **Hosting:** GitHub Pages, org root. Repo **must** be named `wearetechnative.github.io`. `baseURL = "https://wearetechnative.github.io/"`.
2. **Generator:** Hugo (extended). Pinned via Nix — no floating versions.
3. **Hermetic build:** everything runs through a Nix flake. `nix develop -c hugo --minify` must build with zero errors; `nix flake check` must pass. No global toolchain assumptions.
4. **Flat files only.** No database, no runtime backend. All data is YAML/JSON on disk, consumed by Hugo at build time.
5. **No runtime third-party calls.** Self-host fonts and logo assets (vendored into the repo). No Google Fonts CDN, no analytics that phones home unless explicitly added later. The GitHub API is called **only at build time**, never from the browser.
6. **Honesty in framing (explicit TechNative value).** Every factual claim on the site must be verifiable. Repo names, descriptions, languages, stars, and last-updated come straight from the GitHub API — never invent or embellish. No fabricated metrics, testimonials, case studies, or superlatives. Any marketing/prose copy that is not machine-sourced must be wrapped as a placeholder and flagged `<!-- NEEDS PIM APPROVAL -->` (see §9).
7. **License context:** repos are Apache-2.0; the site repo itself ships under Apache-2.0 with a `LICENSE` and `NOTICE`.

## 3. Repository layout

```
wearetechnative.github.io/
├── flake.nix                  # devShell: hugo-extended, curl, jq, nodejs, playwright, lychee, just
├── flake.lock
├── .envrc                     # use flake   (direnv, optional)
├── justfile                   # dev / build / fetch / verify targets
├── hugo.toml                  # Hugo config (baseURL, params, menus)
├── config/
│   └── _default/params.toml   # brand tokens, social links, feature flags
├── data/
│   ├── repos.json             # AUTO-GENERATED at build time (git-ignored). GitHub API snapshot.
│   └── curation.yaml          # HAND-MAINTAINED overlay (committed). Source of truth for humans.
├── content/
│   └── _index.md              # landing page front matter + optional intro body
├── layouts/
│   ├── index.html             # the single landing page
│   ├── partials/
│   │   ├── head.html          # meta, favicon, self-hosted font @font-face, theme init
│   │   ├── hero.html
│   │   ├── elastinix-spotlight.html
│   │   ├── project-grid.html  # renders merged repo objects as cards
│   │   ├── filters.html       # category + language + free-text search controls
│   │   ├── awesome.html       # awesome-lists band
│   │   └── footer.html
│   └── shortcodes/
├── assets/
│   ├── css/                   # source CSS (Hugo Pipes → fingerprinted, minified)
│   ├── js/filter.js           # vanilla JS: search/filter/sort + dark-mode toggle. No framework.
│   ├── fonts/                 # self-hosted woff2 (IBM Plex Sans + IBM Plex Mono)
│   └── img/                   # vendored TechNative logos + favicons
├── scripts/
│   └── fetch-repos.sh         # curl + jq → data/repos.json (build-time, authenticated)
├── tests/
│   └── smoke.spec.ts          # Playwright: load, search, filter, category toggle, dark mode
├── .github/workflows/
│   └── deploy.yml             # fetch → build (Nix) → verify → deploy to Pages; + daily cron
├── LICENSE                    # Apache-2.0
├── NOTICE
└── README.md                  # how the site works, how to add/curate a project
```

## 4. Data model — hybrid (auto + curated)

Two inputs, merged at build time into one list of "project" objects.

### 4a. Auto layer — `data/repos.json` (generated, git-ignored)

`scripts/fetch-repos.sh` calls the GitHub REST API with `GITHUB_TOKEN` (Actions-provided; falls back to unauthenticated with a clear warning for local dev) and writes a normalised array. Per repo, capture exactly:

```
name, full_name, html_url, description, homepage,
language, topics[], stargazers_count, forks_count,
archived, fork, is_template, pushed_at, license.spdx_id
```

Use `curl` + `jq` only (both in the flake). Paginate to cover all ~93 repos (`per_page=100`, follow `Link` `rel="next"`). Fail the build loudly on API error — never silently ship a stale/empty grid.

### 4b. Curated layer — `data/curation.yaml` (committed, human-owned)

Overlay keyed by repo name. Everything optional; presence overrides the auto layer.

```yaml
# Global rules
defaults:
  exclude_forks: true
  exclude_archived: true
  exclude_templates: true
  exclude_repos:            # infra/noise that shouldn't appear as "projects"
    - wearetechnative.github.io   # this site
    - .github
    - homebrew-tap
  # Category assignment rules, first match wins. Evaluated before per-repo overrides.
  category_rules:
    - match: { name_prefix: "terraform-" }        category: terraform-modules
    - match: { topic: "elastinix" }               category: elastinix
    - match: { name_in: [elastinix] }             category: elastinix
    - match: { name_prefix: "awesome-" }          category: awesome-lists
    - match: { topic_any: [cli, tui, cloud-engineering] } category: tools
    - match: { default: true }                    category: other

# Per-repo overrides (highest precedence)
repos:
  elastinix:
    featured: true
    category: elastinix
    blurb: ""                 # optional short human description; leave "" to use GitHub description
  optscale:                   # example: a FORK we deliberately want to surface
    include: true             # opt back in past exclude_forks
    category: tools
    blurb: ""                 # NEEDS PIM APPROVAL if non-empty — keep factual
  bmc:      { featured: true }
  race:     { }
  awesome-flake-parts: { featured: true }
  awesome-finops:      { featured: true }

# ElastiNix product family — repos grouped under the spotlight (names or a topic)
elastinix_group:
  by_topic: "elastinix"       # preferred: tag member repos with topic `elastinix`
  by_name:                    # fallback explicit membership
    - elastinix
```

**Merge algorithm (implement in a Hugo partial or a small pre-build jq step, your call — keep it flat-file):**
1. Start from `repos.json`.
2. Drop repos per `defaults.exclude_*` and `exclude_repos`, **unless** a per-repo override sets `include: true`.
3. Assign category via `category_rules` (first match wins), then apply per-repo `category` override.
4. Apply `featured`, `blurb` overrides. `blurb` falls back to the GitHub `description`.
5. Sort within category: featured first, then by `stargazers_count` desc, then `pushed_at` desc.

## 5. Categories (approved)

Display in this order; hide any that end up empty:

1. **ElastiNix** — flagship. NixOS running smoothly on AWS + battery-included self-hostable office apps.
2. **Terraform Modules** — the `terraform-aws-module-*` family (the bulk of the org).
3. **Cloud-Engineer Tools** — TUIs/CLIs for cloud-engineer happiness (`bmc`, `race`, `jira*`, etc.).
4. **Awesome Lists** — `awesome-flake-parts` (54★), `awesome-finops`, and any future `awesome-*`.
5. **Other** — everything else worth showing (e.g. `TeXnative`).

## 6. The landing page (single page, top → bottom)

1. **Header** — TechNative logo (links to `https://technative.eu`), site title "Open Source", nav anchors to each category, dark-mode toggle, "View on GitHub" button → org.
2. **Hero** — confident engineer-to-engineer line in the "Cloud Native, our religion" register. One factual sub-line (e.g. "N public repositories" where N is computed from the data, not hardcoded). Primary CTA → GitHub org; secondary → ElastiNix.
3. **ElastiNix spotlight** — a distinct band above the grid: what ElastiNix is, the member repos as mini-cards, links to the flagship `elastinix` flake. This is the only section allowed a short narrative — keep it factual, flag prose for approval.
4. **Filter bar** — sticky. Free-text search (matches name + description + topics), category chips (multi-select), language dropdown, sort (stars / recently updated / name). All client-side, instant, zero network.
5. **Project grid** — responsive cards. Each card: repo name (monospace), description, language dot + label, ★ count, last-updated (relative), topic tags, link to repo. Cards are keyboard-focusable and screen-reader labelled.
6. **Awesome-lists band** — visually distinct, celebrates the curated lists (these are OSS-community catnip; give them prominence).
7. **Footer** — vendored TechNative logo (light-on-dark variant), one-line "why we open-source" blurb (placeholder, flagged), links: GitHub org, `https://technative.eu`, LinkedIn `https://www.linkedin.com/company/technative-bv/`. `© <current year> TechNative B.V.`, Apache-2.0 note. (X/Twitter `@TechNativeBV` optional — leave commented for Pim to enable.)

**Interaction/tech:** vanilla JS only for filtering; no React/Vue/framework. Progressive enhancement — with JS disabled the full grid still renders (SEO + resilience). No `localStorage` required; dark-mode may use `prefers-color-scheme` + an in-memory toggle.

## 7. Brand tokens (grounded in technative.eu)

```
--tn-green:      #86c33a   /* TechNative primary */
--tn-green-700:  #6ba52e   /* hover/active (verify AA contrast) */
--tn-ink:        #1e2327   /* charcoal — dark base / body text */
--tn-paper:      #ffffff
--tn-paper-soft: #f7f8f5
--tn-muted:      #5b6570
```
- **Colour mode:** ship **light-first** (aligns with the corporate site — this is "our new website") **with a dark-mode toggle**. Dark base = `--tn-ink`. Verify all text meets WCAG AA in both modes.
- **Type:** self-hosted **IBM Plex Sans** (UI/body) + **IBM Plex Mono** (repo names, commands, language labels, terminal accents). woff2 vendored into `assets/fonts/`; declare via `@font-face`. This gives the OSS/terminal flavour without a runtime CDN dependency. (If Pim supplies the exact brand font, swap the sans.)
- **Logos to vendor** (download into `assets/img/`, do not hotlink):
  - Colour SVG (light header): `https://technative.eu/images/logo/TechNative_logo_colour_RGB.svg`
  - Footer/light-on-dark PNG: `https://technative.eu/images/logo/TechNative_logo_footer.png`
  - Favicon: derive from the SVG mark; fallback org avatar `https://avatars.githubusercontent.com/u/130096833`
- **Voice:** confident, technical, no marketing fluff. Speak peer-to-peer to engineers.

## 8. GitHub Actions — `deploy.yml`

Single workflow, three logical stages, plus a schedule so the grid stays fresh even without pushes.

```yaml
on:
  push: { branches: [main] }
  schedule: [{ cron: "0 6 * * *" }]   # daily refresh of repo metadata
  workflow_dispatch:

permissions: { contents: read, pages: write, id-token: write }
concurrency: { group: pages, cancel-in-progress: true }
```

**Steps:**
1. `actions/checkout` (pin to current major).
2. Install Nix — `DeterminateSystems/nix-installer-action` (+ a Nix cache action). Flakes enabled.
3. **Fetch:** `nix develop -c scripts/fetch-repos.sh` with `GITHUB_TOKEN: ${{ github.token }}` in env → writes `data/repos.json`.
4. **Build:** `nix develop -c hugo --minify --gc` → `public/`.
5. **Verify (must pass before deploy):** `nix flake check`; link-check `public/` with `lychee`; run the Playwright smoke test (§10) against a locally served `public/`.
6. **Deploy:** `actions/configure-pages` → `actions/upload-pages-artifact` (path `public/`) → `actions/deploy-pages`. Gate the deploy job on verify success.

> Pin action versions to their current majors at implementation time — verify latest before committing (Pages flow is `configure-pages` / `upload-pages-artifact` / `deploy-pages`).

Enable Pages → "GitHub Actions" as source in repo settings (document this in README as a one-time manual step, since it can't be fully scripted).

## 9. Content requiring approval (do not invent)

Insert these as clearly-marked placeholders and list them at the top of the README under "Before going live":
- Hero headline + sub-line (draft a factual placeholder; no unverifiable claims).
- ElastiNix spotlight paragraph (factual only).
- Footer "why we open-source" blurb.
- Decision: feature the `optscale` fork? (default: **off** — `include:` commented in `curation.yaml`).
- Decision: enable X/Twitter link in footer? (default: **off**).

Every placeholder wrapped: `<!-- NEEDS PIM APPROVAL: ... -->`.

## 10. Acceptance criteria & verification instrumentation

The build is "done" only when all of these pass and are wired into `just verify` + CI:

- [ ] `nix flake check` passes.
- [ ] `nix develop -c hugo --minify --gc` builds `public/` with **0 errors, 0 warnings**.
- [ ] `scripts/fetch-repos.sh` produces valid `data/repos.json` covering **all** public repos (paginated); exits non-zero on API failure.
- [ ] Merge logic: forks/archived/templates excluded by default; `optscale` appears **only** if `include: true`; `elastinix` is `featured` and in the ElastiNix group; awesome lists categorised correctly.
- [ ] `lychee` link-check on `public/` reports no broken internal links (external allowed to warn).
- [ ] **Playwright `smoke.spec.ts`** passes headless:
  - page loads at `/`, grid renders ≥1 card;
  - typing "terraform" in search reduces the grid and every visible card matches;
  - toggling a category chip filters correctly;
  - dark-mode toggle flips `data-theme` and persists across interaction (in-memory);
  - no console errors.
- [ ] No network requests to non-GitHub origins at runtime (fonts/logos are local). Verify in the Playwright run.
- [ ] Grid renders fully with JavaScript disabled (progressive enhancement).
- [ ] Lighthouse (or equivalent) budget: Performance ≥ 90, Accessibility ≥ 95 on the built page. Include the command in the README.
- [ ] README documents: local dev (`just dev`), how to curate a project (`data/curation.yaml`), the one-time Pages settings toggle, and the "Before going live" approval list.

Report the pass/fail of each checkbox at the end of the run.

## 11. Out of scope (do not build)

Per-project pages, blog/news, i18n/Dutch translation, CMS, comments, search backend, custom domain. Keep it a single page. (Forward-compat note: if a custom domain like `opensource.technative.eu` is wanted later, it's a `CNAME` file + one DNS record — leave a commented stub in README, build nothing.)

## 12. Working style

- Use `just` targets for every repeatable action; keep them thin wrappers over `nix develop -c ...`.
- Keep dependencies minimal and pinned in the flake; prefer `curl`/`jq`/vanilla JS over adding tools.
- Commit `data/curation.yaml`, `flake.lock`, vendored assets; git-ignore `data/repos.json` and `public/`.
- Write the README so a TechNative engineer who has never seen the repo can add a project and ship in under 5 minutes.

---

### Appendix A — Open decisions carried from planning (defaults chosen; flip freely)

| # | Decision | Default in this brief |
|---|----------|-----------------------|
| 1 | Colour mode | Light-first + dark toggle |
| 2 | URL | `wearetechnative.github.io` now; custom domain deferred |
| 3 | Feature `optscale` fork | Off (opt-in in `curation.yaml`) |
| 4 | X/Twitter footer link | Off (commented) |
| 5 | Fonts | IBM Plex Sans + Mono, self-hosted |

### Appendix B — Ground-truth references

- Org: `https://github.com/wearetechnative` — 93 public repos, Apache-2.0.
- Sample repos seen: `elastinix` (Nix, flagship), `terraform-aws-module-rds-instance` / `-scheduler` / `-observability-sender` (Terraform family), `bmc` (Go, "AWS Utilities for Cloud Engineers"), `race` (Shell, Terraform tooling), `jirasync` / `jiraticketcreate` (Python), `awesome-flake-parts` (54★), `awesome-finops`, `TeXnative` (Lua/Quarto), `optscale` (fork), `homebrew-tap` (exclude).
- Corporate site: `https://technative.eu` (Hugo). Green `#86c33a`. Tone: "Cloud Native, our religion".
