## Context

Scaffold and data pipeline are in place. This change writes the actual page:
`index.html` + section partials rendering the merged project objects, fully
server-side so it works with JS off. Client behaviour (filtering, dark toggle
logic) is layered in the next epic; here we render everything and add the
data attributes + toggle markup those scripts will hook.

## Goals / Non-Goals

**Goals:**
- The complete top-to-bottom page from brief §6.
- Accessible, keyboard-navigable cards carrying filter data attributes.
- Empty categories hidden; repo count computed; prose flagged for approval.

**Non-Goals:**
- Filtering/sort/search behaviour and the dark-mode toggle *logic* — that is
  `client-interactivity`. This epic ships the markup and a no-JS-safe default.

## Decisions

- **Partial per section:** `hero`, `elastinix-spotlight`, `filters`,
  `project-grid`, `awesome`, `footer`, plus the existing `head`. `index.html`
  calls the merge once (`partial "data/projects.html"`) and passes the result to
  the partials via a dict context, so the data is computed a single time.
- **Cards carry `data-*` attributes** (`data-name`, `data-desc`, `data-topics`,
  `data-lang`, `data-stars`, `data-pushed`) so the next epic's vanilla JS filters
  without re-fetching. With JS off these are inert and the full grid shows.
- **Relative time** via Hugo's `time.Format`/`.Unix` math rendered server-side to
  a human string (e.g. "updated 3 weeks ago"); the exact date is in a `title`
  attribute for accessibility.
- **Language dot colour:** keep it brand-green (single accent) for the PoC rather
  than per-language GitHub colours — avoids shipping a colour map; can be a later
  enhancement. Documented so it's a conscious choice.
- **Dark-mode toggle** renders as a `<button aria-pressed>` that sets
  `data-theme` on `<html>`; the actual JS is in the next epic, but the button and
  a `prefers-color-scheme` CSS default mean dark mode works pre-JS too.
- **Prose flagging:** hero headline/sub-line, spotlight paragraph, and footer
  blurb are wrapped `<!-- NEEDS PIM APPROVAL: ... -->` with factual placeholders.
- **Computed count:** repo count = sum of `len .projects` across categories.

## Risks / Trade-offs

- Server-side relative time is fixed at build; acceptable since the daily CI cron
  rebuilds. Noted.
- Single-accent language dots trade fidelity for simplicity — deliberate for the
  PoC.
