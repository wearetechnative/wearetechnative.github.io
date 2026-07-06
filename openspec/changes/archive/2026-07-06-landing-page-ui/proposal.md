## Why

The landing page is the product. It must render top-to-bottom from the merged
project objects, server-side, so the full grid works even with JavaScript
disabled (brief §6, progressive enhancement).

## What Changes

- Add `layouts/index.html` and partials: `head`, `hero`, `elastinix-spotlight`,
  `project-grid`, `filters`, `awesome`, `footer`.
- **Header:** TechNative logo → `technative.eu`, site title "Open Source",
  category nav anchors, dark-mode toggle, "View on GitHub" → org.
- **Hero:** engineer-to-engineer line ("Cloud Native, our religion" register),
  one factual sub-line ("N public repositories", N computed from data), primary
  CTA → org, secondary → ElastiNix. Prose flagged for approval.
- **ElastiNix spotlight:** distinct band above the grid; member repos as
  mini-cards; link to the flagship `elastinix` flake. Factual prose flagged.
- **Filter bar:** sticky; markup for search, category chips, language dropdown,
  sort (behaviour lands in `client-interactivity`).
- **Project grid:** responsive cards — repo name (mono), description, language
  dot + label, ★ count, relative last-updated, topic tags, repo link;
  keyboard-focusable and screen-reader labelled.
- **Awesome-lists band:** visually distinct, given prominence.
- **Footer:** vendored light-on-dark logo, "why we open-source" blurb
  (placeholder, flagged), links (org, technative.eu, LinkedIn), © current year,
  Apache-2.0 note. X/Twitter link commented out.
- Inject the Umami snippet in `head.html` behind `params.analytics.umami`.
- Categories in approved order; hide any that end up empty.

## Capabilities

### New Capabilities
- `landing-page`: The single server-rendered page and its section partials,
  rendering merged project objects with full progressive enhancement.

## Impact

- New: `layouts/index.html`, `layouts/partials/*.html`,
  `layouts/shortcodes/` as needed.
- Depends on: `site-shell`, `repo-data`. Blocks: `client-interactivity`.
- Constraint: grid must render with JS disabled; all non-machine-sourced prose
  wrapped `<!-- NEEDS PIM APPROVAL: ... -->`.
