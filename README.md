# wearetechnative.github.io

The public open-source portfolio site for the [`wearetechnative`](https://github.com/wearetechnative)
GitHub organisation — a single, fast, filterable Hugo landing page for the org's
~93 public repos, hermetically built with Nix flakes and deployed to GitHub Pages.

> **Status: alpha / PoC in progress.** This repo is being built out epic by epic.
> The authoritative specification is
> [`BRIEF-wearetechnative-portfolio-site.md`](./BRIEF-wearetechnative-portfolio-site.md).
> Build conventions live in [`CLAUDE.md`](./CLAUDE.md).

## Before going live (needs Pim's approval)

These items are placeholders or open decisions and must be reviewed before launch.
Each in-page placeholder is wrapped `<!-- NEEDS PIM APPROVAL: ... -->`.

- [ ] Hero headline + sub-line (factual placeholder in place).
- [ ] ElastiNix spotlight paragraph (factual only).
- [ ] Footer "why we open-source" blurb.
- [ ] Feature the `optscale` fork? (default: **off** — opt-in in `data/curation.yaml`).
- [ ] Enable X/Twitter footer link? (default: **off**, commented).
- [ ] `oss.json` embed feed is a **public API** consumed by technative.eu's build
      (`technative-oss/v1`). Confirm the path/schema before technative.eu pins to it —
      afterwards it's frozen (breaking changes go to `v2`). See the *Embed feed* section.
- [x] Umami analytics — **approved & enabled** by Pim. Loads
      `https://umami.pimsnel.com/script.js` (cookieless, self-hosted). The only
      permitted runtime third-party request. Toggle via the
      `params.analytics.umami` feature flag; details in `CLAUDE.md` /
      `openspec/project.md`.

## Development

Everything runs through the Nix flake — no global toolchain required.

```sh
nix develop            # enter the dev shell (or: direnv allow, with .envrc)
just dev               # live preview at http://localhost:1313
just build             # build public/ (minified)
just fetch             # refresh data/repos.json from the GitHub API
just verify            # build + nix flake check + link-check + Playwright e2e
just test              # just the Playwright suite (needs `just build` first)
```

The e2e suite lives in `tests/` (Playwright, pinned to the flake's browser
version). Browsers come from the Nix flake — nothing is downloaded. `just verify`
is exactly what CI runs before deploy.

### Lighthouse budget

Target on the built page: **Performance ≥ 90, Accessibility ≥ 95**. To measure,
serve `public/` and run Lighthouse against it (Chromium from the flake):

```sh
just build
nix develop -c node tests/serve.mjs &            # serves public/ on :4173
nix develop -c npx --prefix tests lighthouse \
    http://localhost:4173 --preset=desktop --view
```

## Adding or curating a project

Repo facts (name, description, language, stars, last-updated) come straight from
the GitHub API — never edited by hand. To change how a repo is presented — feature
it, recategorise it, add a factual blurb, or include/exclude it — edit
`data/curation.yaml` (the committed, human-owned overlay) and rebuild. See the
comments in that file and `BRIEF-…§4b`.

## How the build works

`scripts/fetch-repos.sh` snapshots the GitHub API into `data/repos.json`
(git-ignored) at build time; Hugo merges it with `data/curation.yaml` into the
categorised project grid. No database, no runtime backend, no browser-side API
calls. Fonts and logos are self-hosted/vendored.

## Embed feed for technative.eu (`oss.json`)

Every build also publishes a JSON feed of the curated project catalogue at a
stable path:

```
https://wearetechnative.github.io/oss.json
```

It is the **same** merge output the site renders (`data/repos.json` +
`data/curation.yaml`), emitted as JSON via a Hugo output format — so the feed
and the site never drift. technative.eu (a static-site generator) pulls this at
**build time** and renders the open-source showcase in its own design system.
No hosted widget, no iframe, no runtime browser call.

### Contract — `technative-oss/v1`

The feed is a self-describing envelope. **The path and the `v1` field shapes are
a published contract:** once technative.eu pins to them they are frozen —
additive changes are safe, but any rename/removal/retype ships as a new version
(`v2`), never an in-place edit of `v1`.

```jsonc
{
  "schema": "technative-oss/v1",
  "generated_at": "2026-08-27T06:00:00Z",   // RFC 3339 UTC, build time
  "source": "https://wearetechnative.github.io/",
  "org": "wearetechnative",
  "totals": { "projects": 42, "stars": 1234, "forks": 210 },
  "categories": [
    {
      "key": "elastinix", "title": "ElastiNix", "count": 3,
      "projects": [
        {
          "name": "elastinix",
          "full_name": "wearetechnative/elastinix",
          "html_url": "https://github.com/wearetechnative/elastinix",
          "homepage": null,                  // may be null
          "description": "…",                // raw GitHub description (may be null)
          "blurb": "…",                      // curated blurb, else the description
          "language": "Nix",
          "topics": ["elastinix"],
          "stargazers_count": 12,
          "forks_count": 3,
          "pushed_at": "2026-08-20T09:15:00Z",
          "featured": true,
          "category": "elastinix"
        }
      ]
    }
  ]
}
```

- All values are machine-sourced (GitHub API) or curation flags — no unsourced prose.
- `totals` are summed over exactly the projects in `categories`.
- Empty categories are omitted; categories follow the site's display order and
  projects its featured → stars → recency sort.

### Consuming it (build-time example)

Illustrative only — this snippet lives on the technative.eu side, not in this repo:

```js
// build step on technative.eu
const feed = await fetch("https://wearetechnative.github.io/oss.json").then((r) => r.json());
if (feed.schema !== "technative-oss/v1") throw new Error(`unexpected feed schema: ${feed.schema}`);

for (const category of feed.categories) {
  renderSection(category.title, category.projects.map((p) => ({
    title: p.name,
    href: p.html_url,
    blurb: p.blurb,
    stars: p.stargazers_count,
    language: p.language,
  })));
}
```

GitHub Pages serves the feed with `Access-Control-Allow-Origin: *`, so a runtime
`fetch()` from the browser also works — but build-time consumption keeps
technative.eu's visitors free of any runtime dependency on Pages availability.

## Deployment

`.github/workflows/deploy.yml` builds and deploys to GitHub Pages (org root) on
every push to `main`, on manual dispatch, and daily at 06:00 UTC (a cron that
refreshes the repo metadata without a push). The pipeline is **fetch → build →
verify → deploy**, and deploy only runs if `just verify` (flake check + link check
+ Playwright e2e) passes.

**One-time manual step (cannot be scripted):** in repo **Settings → Pages →
Build and deployment → Source**, choose **GitHub Actions**. Until this is set, the
workflow runs green but nothing publishes. After it's set, the site goes live at
https://wearetechnative.github.io/ on the next run (or trigger one from the
Actions tab → "Deploy to GitHub Pages" → Run workflow).

<!-- Custom domain (e.g. opensource.technative.eu) is deferred: it would be a
     CNAME file (static/CNAME) + one DNS record. Out of scope for the PoC —
     build nothing. -->

## Project tracking

- **Milestones & epics:** [`beans`](https://github.com/) (`beans list`,
  `beans roadmap`).
- **Spec-driven changes:** OpenSpec (`openspec/`). One change per epic.
- **Version control:** `jj` (Jujutsu). Commits authored by Pim Snel.

## License

Apache-2.0. See [`LICENSE`](./LICENSE) and [`NOTICE`](./NOTICE).
