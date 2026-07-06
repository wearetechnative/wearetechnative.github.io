---
# wearetechnative.github.io-2ard
title: 'Client-side interactivity: search, filter, sort, dark mode'
status: completed
type: epic
priority: normal
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T13:36:02Z
parent: wearetechnative.github.io-lria
blocked_by:
    - wearetechnative.github.io-t24g
---

Vanilla JS only (no framework) for instant client-side filtering and theming. Zero network.

## Acceptance
- assets/js/filter.js: free-text search (name+description+topics), multi-select category chips, language dropdown, sort (stars/recently updated/name). Instant, client-side.
- Dark-mode toggle flips data-theme; may use prefers-color-scheme + in-memory toggle (no localStorage required).
- Sticky filter bar.
- Progressive enhancement preserved (JS off = full grid).

OpenSpec change: client-interactivity

## Summary of Changes

Delivered client-side interactivity (OpenSpec change client-interactivity, archived 2026-07-06).

- assets/js/filter.js: vanilla JS, no framework, no network. Collects all cards once (grid + awesome band), single state object {q, cats, lang, sort} + apply() recompute. Search (debounced, name/desc/topics), multi-select category chips (aria-pressed), language dropdown, sort (stars/updated/name) reordering cards within each grid. Empty sections hidden; "no results" message. Dark-mode toggle flips data-theme + syncs aria-pressed, seeded from prefers-color-scheme.
- assets/css/main.css: [hidden] wins over display:flex/grid; .no-results styling.
- Loaded deferred + fingerprinted with SRI via Hugo Pipes.

Verified in headless Chromium against the live page: 12/12 checks pass — grid renders (82), search "terraform" narrows to 52 with every visible card matching, clear restores, chip filters + sets aria-pressed, sort A-Z, dark toggle flips light->dark, no-results appears, no console errors, no unexpected network origins. Full Playwright e2e suite is the testing epic.
