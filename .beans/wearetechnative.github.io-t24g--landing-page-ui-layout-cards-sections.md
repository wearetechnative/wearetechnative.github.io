---
# wearetechnative.github.io-t24g
title: 'Landing page UI: layout, cards & sections'
status: todo
type: epic
priority: high
created_at: 2026-07-06T10:29:17Z
updated_at: 2026-07-06T10:37:00Z
parent: wearetechnative.github.io-lria
blocked_by:
    - wearetechnative.github.io-njxs
    - wearetechnative.github.io-qq8l
---

Render the single landing page top-to-bottom per brief §6, server-side via Hugo partials from merged project objects. Progressive enhancement: full grid renders with JS disabled.

## Acceptance
- layouts/index.html + partials: head, hero, elastinix-spotlight, project-grid, filters, awesome, footer.
- Header: logo→technative.eu, title, category nav anchors, dark-mode toggle, View on GitHub.
- Hero: engineer-to-engineer line, factual sub-line (N repos computed from data), CTAs.
- ElastiNix spotlight band with member mini-cards.
- Project grid: responsive cards (name mono, desc, language dot+label, stars, relative last-updated, topic tags, repo link); keyboard-focusable + SR-labelled.
- Awesome-lists band, visually distinct.
- Footer: vendored logo, blurb placeholder, org/technative.eu/LinkedIn links, © year, Apache-2.0.
- All approval-needed prose wrapped <!-- NEEDS PIM APPROVAL -->.
- Categories displayed in approved order; empty ones hidden.

OpenSpec change: landing-page-ui
