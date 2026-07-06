## 1. Filter engine

- [x] 1.1 Add `assets/js/filter.js` (vanilla, no framework); collect `.card` nodes + parent sections on load, precompute filter text.
- [x] 1.2 State object `{ q, cats, lang, sort }` + single `apply()` recompute.
- [x] 1.3 Search: case-insensitive substring over name/desc/topics; debounced input.
- [x] 1.4 Category chips: multi-select, toggle `aria-pressed`, filter by `data-category`.
- [x] 1.5 Language dropdown + sort select (stars desc / updated / name A–Z), reordering cards within each grid.

## 2. Empty states

- [x] 2.1 Hide any section with zero visible cards; restore when they return.
- [x] 2.2 Show a "no results" message when nothing matches; hide otherwise.

## 3. Dark mode

- [x] 3.1 Toggle flips `document.documentElement.dataset.theme` and syncs `aria-pressed`.
- [x] 3.2 Seed initial theme from `prefers-color-scheme` when the user hasn't toggled.

## 4. Wiring & progressive enhancement

- [x] 4.1 Confirm `index.html` loads `filter.js` deferred + fingerprinted (already guarded by `with resources.Get`).
- [x] 4.2 Add the `no-results` node markup + any CSS for hidden/empty states.
- [x] 4.3 Verify JS-off still renders the full grid (controls inert).

## 5. Verification

- [x] 5.1 `hugo --minify --gc` builds with 0 warnings, 0 errors; `filter.js` is emitted + fingerprinted.
- [x] 5.2 Manual/scripted checks: search "terraform" narrows grid and every visible card matches; chip toggles filter; language filters; sort reorders; dark toggle flips `data-theme`.
- [x] 5.3 No non-GitHub/Umami network requests triggered by interaction (deferred full e2e to testing epic).
