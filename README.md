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

## Deployment

GitHub Actions builds and deploys to GitHub Pages (org root), with a daily cron
that refreshes the repo metadata. **One-time manual step:** in repo Settings →
Pages, set the source to **GitHub Actions**. _(Workflow added by the CI/CD epic.)_

<!-- Custom domain (e.g. opensource.technative.eu) is deferred: it would be a
     CNAME file + one DNS record. Out of scope for the PoC — build nothing. -->

## Project tracking

- **Milestones & epics:** [`beans`](https://github.com/) (`beans list`,
  `beans roadmap`).
- **Spec-driven changes:** OpenSpec (`openspec/`). One change per epic.
- **Version control:** `jj` (Jujutsu). Commits authored by Pim Snel.

## License

Apache-2.0. See [`LICENSE`](./LICENSE) and [`NOTICE`](./NOTICE).
