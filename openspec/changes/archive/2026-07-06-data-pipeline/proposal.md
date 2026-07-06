## Why

The site is data-driven: it must render all ~93 public repos from live GitHub
data merged with a human-curated overlay, at build time only (brief §4). Without
this flat-file data layer there is nothing for the Hugo templates to render, so it
gates the UI epic.

## What Changes

- Add `scripts/fetch-repos.sh`: `curl` + `jq`, paginated (`per_page=100`, follow
  `Link rel="next"`), authenticated via `GITHUB_TOKEN` with an unauthenticated
  fallback that warns. Writes a normalised `data/repos.json` capturing exactly:
  `name, full_name, html_url, description, homepage, language, topics[],
  stargazers_count, forks_count, archived, fork, is_template, pushed_at,
  license.spdx_id`. **Exits non-zero on any API error** — never ships a
  stale/empty grid.
- Add `data/curation.yaml`: committed, human-owned overlay — `defaults`
  (exclude_forks/archived/templates, exclude_repos), `category_rules`
  (first-match-wins), per-repo overrides, `elastinix_group`.
- Implement the merge (Hugo partial or a small jq pre-step — keep it flat-file):
  drop excluded repos unless `include: true`; assign category via rules then
  per-repo override; apply `featured`/`blurb` (blurb falls back to GitHub
  `description`); sort featured → `stargazers_count` desc → `pushed_at` desc.
- Wire `just fetch` to the script.

## Capabilities

### New Capabilities
- `repo-data`: The build-time GitHub fetch, the curation overlay schema, and the
  merge algorithm that yields the categorised list of project objects.

## Impact

- New: `scripts/fetch-repos.sh`, `data/curation.yaml`, merge logic (partial or
  pre-step). `data/repos.json` generated + git-ignored.
- Depends on: `dev-environment` (curl/jq/yq in the devShell).
- Blocks: `landing-page-ui` (consumes the merged objects).
- Acceptance (brief §10): valid `repos.json` covering all repos, paginated,
  non-zero exit on failure; merge excludes forks/archived/templates, `optscale`
  only if `include: true`, `elastinix` featured + grouped, awesome lists
  categorised.
