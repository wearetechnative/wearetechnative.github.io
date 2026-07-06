---
# wearetechnative.github.io-2ard
title: 'Client-side interactivity: search, filter, sort, dark mode'
status: todo
type: epic
priority: normal
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:37:00Z
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
