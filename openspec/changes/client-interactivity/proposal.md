## Why

The grid must be instantly filterable and themeable entirely client-side, with no
network and no framework (brief §6). This layers behaviour onto the
already-rendered page so it degrades gracefully when JS is off.

## What Changes

- Add `assets/js/filter.js` (vanilla JS, no framework):
  - Free-text search matching name + description + topics.
  - Multi-select category chips.
  - Language dropdown.
  - Sort: stars / recently updated / name.
  - All instant, client-side, zero network.
- Dark-mode toggle flips `data-theme`; may use `prefers-color-scheme` plus an
  in-memory toggle (no `localStorage` required).
- Keep the filter bar sticky and the interactions keyboard-accessible.
- Preserve progressive enhancement: with JS disabled the full grid still renders.

## Capabilities

### New Capabilities
- `client-filtering`: The vanilla-JS search/filter/sort and dark-mode behaviour
  layered onto the server-rendered grid.

## Impact

- New: `assets/js/filter.js` (fingerprinted via Hugo Pipes).
- Depends on: `landing-page` (needs the rendered grid + filter markup).
- Blocks: `testing-verification` (the e2e suite drives these interactions).
- Constraint: no framework, no network, JS-off still renders the grid.
