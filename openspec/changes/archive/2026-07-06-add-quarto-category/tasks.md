## 1. Category rule & display

- [x] 1.1 Add `quarto` category rules to `data/curation.yaml` (topic `quarto`/`quarto-extension`, `quarto-` prefix, `TeXnative`/`embed-sheet`), before the `other` fallback.
- [x] 1.2 Add `quarto` (title "Quarto") to the display order in `layouts/partials/data/projects.html`, after Tools and before Awesome Lists.
- [x] 1.3 Add the "Quarto" `menu.main` anchor in `hugo.toml`.

## 2. Verification

- [x] 2.1 `hugo --minify --gc` builds with 0 warnings, 0 errors.
- [x] 2.2 Quarto section renders with TeXnative, embed-sheet, quarto-with-batteries, quarto-content-slots; those repos leave "Other"; total unchanged (82).
- [x] 2.3 Header nav shows the Quarto anchor.
