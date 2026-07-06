# repo-data Specification

## Purpose
TBD - created by archiving change data-pipeline. Update Purpose after archive.
## Requirements
### Requirement: Build-time GitHub repo fetch

The project SHALL fetch all public repositories of the `wearetechnative` org from
the GitHub REST API at build time and write a normalised `data/repos.json`. It
SHALL use only `curl` and `jq`, paginate to cover every repo, authenticate with
`GITHUB_TOKEN` when present (falling back to unauthenticated with a warning), and
fail loudly on API error.

#### Scenario: all repos are captured via pagination

- **WHEN** `scripts/fetch-repos.sh` runs against an org with more than 100 repos
- **THEN** it requests `per_page=100`, follows the `Link` `rel="next"` pages, and
  writes every repo into `data/repos.json`

#### Scenario: normalised fields per repo

- **WHEN** `data/repos.json` is produced
- **THEN** each entry contains `name`, `full_name`, `html_url`, `description`,
  `homepage`, `language`, `topics`, `stargazers_count`, `forks_count`,
  `archived`, `fork`, `is_template`, `pushed_at`, and `license_spdx`

#### Scenario: fails loudly on API error

- **WHEN** the GitHub API returns a non-success status or invalid body
- **THEN** the script exits non-zero and does not overwrite `data/repos.json`
  with stale/empty data

#### Scenario: authentication is optional but warned

- **WHEN** no `GITHUB_TOKEN` is set
- **THEN** the script prints a clear warning and proceeds unauthenticated

### Requirement: Curation overlay

The project SHALL provide a committed `data/curation.yaml` overlay that controls
which repos appear, their categories, and their presentation, without editing
machine-sourced facts.

#### Scenario: default exclusions

- **WHEN** the overlay defaults set `exclude_forks`, `exclude_archived`,
  `exclude_templates`, and an `exclude_repos` list
- **THEN** the merge drops those repos unless a per-repo override sets
  `include: true`

#### Scenario: category rules and overrides

- **WHEN** `category_rules` and per-repo `category` overrides are present
- **THEN** categories are assigned by first-matching rule, then overridden per
  repo where specified

#### Scenario: quarto category rule

- **WHEN** a repo has the `quarto` or `quarto-extension` topic, a `quarto-` name
  prefix, or is `TeXnative` / `embed-sheet`
- **THEN** it is assigned to the `quarto` category (before the `other` fallback)

### Requirement: Merge into project objects

The project SHALL merge `repos.json` with `curation.yaml` into a single
categorised list of project objects consumed by the templates.

#### Scenario: exclusion honoured with opt-in

- **WHEN** a fork such as `optscale` is present and `exclude_forks` is true
- **THEN** it appears only if its per-repo override sets `include: true`

#### Scenario: featured, blurb, and sort

- **WHEN** the merge runs
- **THEN** `featured` and `blurb` overrides apply (`blurb` falls back to the
  GitHub `description`), and repos sort within a category by featured first, then
  `stargazers_count` desc, then `pushed_at` desc

#### Scenario: elastinix is featured and grouped

- **WHEN** the overlay marks `elastinix` featured and in the ElastiNix group
- **THEN** the merged data places it in the `elastinix` category as featured

