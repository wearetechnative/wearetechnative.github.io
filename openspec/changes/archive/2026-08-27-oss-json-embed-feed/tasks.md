## 1. Hugo output format

- [x] 1.1 Register a JSON output format for the `home` kind in `hugo.toml`, pinning the emitted file to `oss.json` at the site root (media type + output-format `baseName`/`mediaType`)
- [x] 1.2 Confirm the HTML home output is unchanged and still primary (output list order does not break `index.html`)

## 2. Feed template

- [x] 2.1 Create `layouts/index.json` that calls `partial "data/projects.html" .` and reuses its merge output verbatim
- [x] 2.2 Filter out categories whose `projects` slice is empty
- [x] 2.3 Add per-category `count` and compute `totals` (`projects`, `stars`, `forks`) by summing over the emitted categories
- [x] 2.4 Wrap in the envelope: `schema` = `technative-oss/v1`, `generated_at` (RFC 3339 UTC), `source` = site baseURL, `org` = `wearetechnative`, `totals`, `categories`
- [x] 2.5 Emit via `jsonify`; ensure integers stay integers and `null`s pass through for absent `homepage`/`description`

## 3. Verification

- [x] 3.1 Build with `nix develop -c hugo --minify --gc` and confirm `public/oss.json` exists
- [x] 3.2 Assert the feed parses as JSON and conforms to `technative-oss/v1` (schema tag present, required envelope keys, project field types); add this assertion to the `just verify` flow
- [x] 3.3 Cross-check feed ordering and totals against the rendered site for the same data snapshot
- [x] 3.4 Confirm `nix flake check` still passes

## 4. Documentation & contract

- [x] 4.1 Document the `technative-oss/v1` schema and the stable `/oss.json` URL in `README.md`, including the stability guarantee (path + field shapes frozen for `v1`; breaking changes go to `v2`)
- [x] 4.2 Add a ~15-line build-time-fetch reference snippet for a static-site consumer (schema-version check + render loop); note it is illustrative and lives only in docs
- [x] 4.3 Note in the README "Before going live" section that the feed URL becomes a public API consumed by technative.eu

## 5. Bean hygiene

- [x] 5.1 Keep the epic bean's todos in sync as tasks complete; on completion add a `## Summary of Changes` section
