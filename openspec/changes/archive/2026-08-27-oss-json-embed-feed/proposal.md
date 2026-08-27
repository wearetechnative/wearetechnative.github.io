## Why

technative.eu wants a thoughtbot-style open-source showcase, sourced from the
organisation's *real* public repositories rather than hand-maintained marketing
copy. The portfolio site already merges the GitHub API snapshot with the
`curation.yaml` overlay into a categorised, sorted list of projects — but that
data is only ever rendered as HTML for the standalone Pages site. Exposing the
same data as a stable JSON feed lets technative.eu (a static-site generator)
pull it at build time and render the showcase in its own design system, with no
duplicated data pipeline and no new fabrication risk.

## What Changes

- Add a `json` output format for the home page so Hugo emits `oss.json`
  alongside the existing HTML at a **stable, public path**:
  `https://wearetechnative.github.io/oss.json`.
- The feed re-renders the **existing** `partial "data/projects.html"` merge
  output as JSON — same inclusion, categorisation, and sort rules as the site.
  No new data source, no second copy of the merge logic.
- Wrap the categories in a self-describing envelope: `schema` version tag,
  `generated_at`, `source`, `org`, and machine-derived `totals`
  (projects / stars / forks).
- Empty categories are omitted from the feed, matching the site's render.
- Treat the URL + `technative-oss/v1` schema as a **published contract**: once
  technative.eu pins to it, the path and field shapes are stable; any
  breaking reshape becomes `/v2`, never an in-place change to `v1`.
- Document the schema and a short build-time-fetch example in the README, and
  add one verification assertion that `oss.json` exists, parses, and conforms.

Out of scope (explicitly not built): a hosted JS widget / web component, an
iframe embed view, runtime browser calls, per-project pages, and any feed
consumer code inside *this* repo — technative.eu owns rendering.

## Capabilities

### New Capabilities

- `embed-feed`: A build-time-generated, versioned JSON feed of the curated
  open-source project catalogue, published at a stable GitHub Pages URL for
  external consumption (technative.eu). Covers the envelope schema, the
  `technative-oss/v1` contract, category/project field shapes, totals
  derivation, empty-category handling, and the stability guarantee.

### Modified Capabilities

<!-- None. The data merge is reused verbatim; no existing spec's requirements change. -->

## Impact

- **New/changed files**: `hugo.toml` (add `json` to home output formats +
  media/output-format config), `layouts/index.json` (new envelope template),
  `README.md` (schema docs + consumer example). No change to
  `scripts/fetch-repos.sh`, `data/curation.yaml`, or the merge partial.
- **Build**: `hugo --minify --gc` now also emits `public/oss.json`. Refreshed
  on the same daily Actions cron that rebuilds the site.
- **Verification**: one added assertion in the verify flow (feed exists, valid
  JSON, matches `technative-oss/v1`).
- **External contract**: `https://wearetechnative.github.io/oss.json` becomes a
  public API consumed by technative.eu's build. GitHub Pages serves it with
  `Access-Control-Allow-Origin: *`, so runtime fetch also works, but the
  chosen consumer is build-time (SSG) — no runtime coupling for eu visitors.
- **Guardrails**: all feed fields are machine-sourced (GitHub API) or curated
  presentation flags already in `curation.yaml`; no fabricated content is
  introduced.
