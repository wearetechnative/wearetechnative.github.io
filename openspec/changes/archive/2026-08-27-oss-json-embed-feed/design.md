# Design — OSS JSON embed feed

## Context

`layouts/partials/data/projects.html` already returns the fully merged,
categorised, sorted project list (see its doc comment). The site renders that
via `layouts/index.html`. We want a second rendering of the *same in-memory
value* as JSON. This is an output-format problem, not a data-pipeline problem.

```
  data/repos.json ─┐
  (GitHub API)     ├─▶ partial "data/projects.html" ─┬─▶ index.html  (HTML, existing)
  data/curation.yaml┘   (merge/categorise/sort)      └─▶ index.json  (JSON, NEW)
```

## Decisions

### 1. Hugo custom output format, not a separate script

Add a `json` output format to the home page. The template
`layouts/index.json` calls the same partial and `jsonify`s an envelope around
it. Rationale: reusing the partial guarantees the feed and the site never
drift — same inclusion rules, same category order, same sort. A standalone jq
script would duplicate ~90 lines of merge logic and invite skew.

`hugo.toml`:
- register a media type / output format for JSON at the home kind (Hugo ships
  a built-in `JSON` output format; we attach it to `home` and pin the emitted
  filename to `oss.json` via the output format's `baseName`/`mediaType` so the
  public path is `/oss.json`, not `/index.json`).

### 2. Envelope built in the template, totals folded in-template

`layouts/index.json` computes `totals` by ranging the merged categories and
summing `stargazers_count` / `forks_count` and counting projects — so totals
are provably consistent with what is emitted (spec: "Totals match the emitted
projects"). Per-category `count` is added the same way.

Sketch (not final code):
```
{{- $data := partial "data/projects.html" . -}}
{{- $nonEmpty := where $data "projects" ":!" ... -}}  // drop empties
{{- range ... accumulate totals ... -}}
{{ dict "schema" "technative-oss/v1" "generated_at" (now.UTC.Format "2006-01-02T15:04:05Z07:00")
        "source" .Site.BaseURL "org" "wearetechnative"
        "totals" $totals "categories" $cats | jsonify (dict "indent" "  ") }}
```

### 3. Drop empty categories in the feed

The site hides empty category sections; the feed mirrors that by filtering
categories whose `projects` slice is empty before emitting. Keeps the two
renderings semantically identical and avoids `count: 0` noise for consumers.

### 4. `generated_at` — accept per-build byte churn

Including a build timestamp means `oss.json` bytes change on every build even
when no repo data changed. Accepted deliberately: the field is useful for an
"OSS activity as of {date}" line on technative.eu and the feed is not
content-addressed. If byte-stable caching ever matters, this is the first knob
to revisit.

### 5. Versioning as a published contract

`schema: "technative-oss/v1"` is the pin. The path `/oss.json` and the `v1`
field shapes are frozen once technative.eu consumes them. Any breaking reshape
ships as a new file/version (`v2`), never an in-place edit of `v1`. This is
documented in the README so future changes don't silently break the consumer.

### 6. Field parity, verbatim

Emit exactly the fields the partial already produces (`name`, `full_name`,
`html_url`, `homepage`, `description`, `blurb`, `language`, `topics`,
`stargazers_count`, `forks_count`, `pushed_at`, `featured`, `category`) plus
per-category `count`. No renaming into a "prettier" external vocabulary — the
internal names are already clean and renaming would add a mapping layer to
maintain. Integers stay integers (the partial already `int`-casts counts).

## Consumption (informative, not built here)

technative.eu is a static-site generator. Recommended pattern: fetch
`https://wearetechnative.github.io/oss.json` at build time, check
`schema === "technative-oss/v1"`, render categories/cards in eu's own design
system. GitHub Pages sends `Access-Control-Allow-Origin: *`, so a runtime
`fetch()` also works, but build-time keeps eu's visitors free of any runtime
dependency on Pages availability. The README carries a ~15-line reference
snippet; no consumer code lives in this repo.

## Risks / trade-offs

- **Contract rigidity** — freezing `v1` is the point, but it means additive-only
  evolution. Mitigation: additive fields are safe; only removals/retypes force
  `v2`.
- **Timestamp churn** (§4) — accepted.
- **Filename pinning** — Hugo output-format config must actually yield
  `/oss.json`; verified by the acceptance assertion (file exists at that path).
