# embed-feed Specification

## Purpose
TBD - created by archiving change oss-json-embed-feed. Update Purpose after archive.
## Requirements
### Requirement: Stable published feed URL

The build SHALL emit the embed feed as a static file at the stable path
`oss.json` at the site root, served at
`https://wearetechnative.github.io/oss.json`. The path SHALL NOT change while
the feed advertises schema version `technative-oss/v1`.

#### Scenario: Feed is present after a production build

- **WHEN** `hugo --minify --gc` completes
- **THEN** `public/oss.json` exists and is valid, parseable JSON

#### Scenario: Path is stable within a schema major version

- **WHEN** the feed's `schema` field is `technative-oss/v1`
- **THEN** the feed is served at `/oss.json` and no field is renamed, removed,
  or retyped in a way that breaks an existing `v1` consumer

### Requirement: Self-describing envelope

The feed SHALL be a single JSON object carrying a `schema` string
(`technative-oss/v1`), a `generated_at` RFC 3339 UTC timestamp, a `source`
site URL, an `org` slug, a `totals` object, and a `categories` array. All
values SHALL be machine-derived from the GitHub API snapshot or the committed
curation overlay; no field SHALL contain unsourced prose.

#### Scenario: Envelope carries version and provenance

- **WHEN** a consumer reads the feed
- **THEN** `schema` equals `"technative-oss/v1"`, `generated_at` is an RFC 3339
  UTC timestamp of the build, `source` is `"https://wearetechnative.github.io/"`,
  and `org` is `"wearetechnative"`

#### Scenario: Consumer can pin on schema version

- **WHEN** a consumer encounters a `schema` value it does not recognise
- **THEN** the version tag alone is sufficient to detect the mismatch and fail
  loudly, without inspecting field shapes

### Requirement: Aggregate totals

The feed SHALL include a `totals` object with integer `projects`, `stars`, and
`forks`, computed by summing over exactly the projects that appear in the
`categories` array.

#### Scenario: Totals match the emitted projects

- **WHEN** the feed is generated
- **THEN** `totals.projects` equals the count of project objects across all
  categories, `totals.stars` equals the sum of their `stargazers_count`, and
  `totals.forks` equals the sum of their `forks_count`

### Requirement: Category and project shape mirrors the site

The `categories` array SHALL reuse the merge output of
`partial "data/projects.html"` verbatim — the same inclusion, categorisation,
and sort rules as the rendered site. Each category object SHALL carry `key`,
`title`, `count`, and a `projects` array. Each project object SHALL carry
`name`, `full_name`, `html_url`, `homepage`, `description`, `blurb`,
`language`, `topics`, `stargazers_count`, `forks_count`, `pushed_at`,
`featured`, and `category`.

#### Scenario: Project fields are present and correctly typed

- **WHEN** a consumer reads any project object
- **THEN** `stargazers_count` and `forks_count` are integers, `topics` is an
  array of strings, `featured` is a boolean, and `homepage`/`description` may
  be `null` when GitHub provides no value

#### Scenario: Feed ordering equals site ordering

- **WHEN** the feed and the site are built from the same data
- **THEN** categories appear in the site's display order and projects within a
  category follow the same featured-then-stars-then-recency sort as the site

### Requirement: Empty categories omitted

The feed SHALL omit any category that contains zero projects, matching the
site's behaviour of hiding empty category sections.

#### Scenario: A category with no projects does not appear

- **WHEN** a category resolves to zero included projects
- **THEN** that category object is absent from the `categories` array

### Requirement: No new runtime third-party coupling

The feed SHALL be generated entirely at build time and served as a flat file.
Generating or serving it SHALL NOT introduce any runtime browser call or
backend beyond the existing GitHub-Pages static hosting.

#### Scenario: Feed is a static artifact

- **WHEN** the feed is requested by a consumer
- **THEN** it is served as a static file from GitHub Pages with no server-side
  computation and no third-party request originating from this site

