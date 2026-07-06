## Context

The landing page renders all cards server-side with `data-*` attributes and inert
filter/toggle markup. This change adds the vanilla-JS behaviour that reads those
attributes and manipulates the DOM — no framework, no network, and JS-off still
renders the full grid.

## Goals / Non-Goals

**Goals:**
- Instant search (name/desc/topics), multi-select category chips, language
  filter, sort (stars/updated/name), dark-mode toggle.
- One small `assets/js/filter.js`, loaded `defer`, fingerprinted by Hugo Pipes.
- Empty categories hidden on filter; a "no results" message.

**Non-Goals:**
- `localStorage` persistence — the brief says in-memory is fine. Theme follows
  `prefers-color-scheme` on load and toggles in-memory thereafter.
- Any change to the rendered markup contract beyond adding a hidden "no results"
  node and (if needed) a `data-pushed` fallback on awesome cards.

## Decisions

- **Read cards once, cache them.** On `DOMContentLoaded`, collect all `.card`
  nodes with their parent category `<section>`; each card's filterable text is
  precomputed from `data-name`/`data-desc`/`data-topics`. Filtering toggles a
  `hidden` attribute; no re-query per keystroke.
- **State object** `{ q, cats:Set, lang, sort }`; a single `apply()` recomputes
  visibility + ordering and updates section visibility + the no-results node. Every
  control's event handler mutates state then calls `apply()`.
- **Category visibility:** after filtering cards, a section is `hidden` iff it has
  zero visible cards. This covers both the `.category` grids and the `.awesome`
  band uniformly (both are `<section>` with a `.grid`).
- **Sort** reorders card nodes within each `.grid` via `appendChild` in the sorted
  order — stable, no layout thrash beyond one reflow. `updated` uses
  `data-pushed` (epoch); awesome cards without it get `0` so they sort last under
  "updated", which is acceptable (awesome band is its own section anyway).
- **Search matching** is case-insensitive substring across the precomputed text.
  `data-*` are already lower-cased server-side, so we just lower-case the query.
- **Dark mode:** toggle sets `document.documentElement.dataset.theme`; initial
  value seeded from `matchMedia('(prefers-color-scheme: dark)')` only if the user
  hasn't toggled. `aria-pressed` kept in sync. CSS already themes on `data-theme`.
- **Debounce** the search input lightly (~120ms) to avoid reordering on every
  keystroke for large grids; filtering itself is cheap so this is mostly for sort.
- **No-results node:** a single `<p class="no-results" hidden>` inserted after the
  grid container, shown when zero cards are visible across all sections.

## Risks / Trade-offs

- Reordering DOM nodes on every sort change is O(n) but n≈82 — negligible.
- Debounce adds a tiny delay; 120ms is below the perceptible-lag threshold and
  keeps typing smooth. Documented so it's a conscious choice.
- Awesome cards lacking `data-pushed` sort last under "updated" — acceptable since
  they live in a distinct band; noted rather than adding server-side churn.
