## Why

The org has a distinct cluster of Quarto/typesetting repos (`TeXnative`,
`embed-sheet`, `quarto-with-batteries`, `quarto-content-slots`) that currently
fall into the catch-all "Other" category. Pim requested a dedicated **Quarto**
category so this publishing-tooling work is legible on its own.

## What Changes

- Add a `quarto` category to the curation `category_rules` matching the `quarto` /
  `quarto-extension` topics, the `quarto-` name prefix, and the known
  `TeXnative` / `embed-sheet` repos.
- Add `quarto` to the display order in the merge partial, titled "Quarto",
  placed after Cloud-Engineer Tools and before Awesome Lists.
- Add the matching header nav anchor (`menu.main`).

## Capabilities

### Modified Capabilities
- `repo-data`: the set of category rules gains a `quarto` category.
- `landing-page`: the approved category display order gains `quarto`.

## Impact

- Files: `data/curation.yaml`, `layouts/partials/data/projects.html`, `hugo.toml`.
- No new repos shown — 4 repos move from "Other" into "Quarto"; total unchanged.
- Empty-category hiding still applies, so "Quarto" disappears automatically if no
  repo matches.
