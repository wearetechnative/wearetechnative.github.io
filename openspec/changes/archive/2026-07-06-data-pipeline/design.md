## Context

The grid is data-driven. We need a build-time snapshot of the org's repos merged
with a human overlay, all flat-file. `curl`+`jq` only; the merge stays in Hugo so
there is no extra build tool.

## Goals / Non-Goals

**Goals:**
- `scripts/fetch-repos.sh` → normalised, paginated `data/repos.json`, fail-loud.
- `data/curation.yaml` overlay schema matching brief §4b.
- A Hugo-side merge producing the categorised project objects.

**Non-Goals:**
- Rendering — that is `landing-page-ui`. This change exposes the merged data via a
  partial/helper the UI consumes.

## Decisions

- **Fetch in bash + jq.** Loop pages until `Link` has no `rel="next"`. Accumulate
  raw pages, then one `jq` pass maps each repo to the normalised shape
  (`license_spdx` from `.license.spdx_id`). Write atomically (temp file → `mv`) so
  a mid-run failure never truncates the committed-ignored file. `set -euo
  pipefail`; any curl/jq failure or a GitHub `message` error field aborts non-zero.
- **Merge in Hugo, not jq.** A partial `partials/data/projects.html` (returns a
  slice via `return`) reads `site.Data.repos` + `site.Data.curation`, applies
  exclusions/rules/overrides/sort, and is called once from `index.html`. Keeping
  the merge in Hugo means no second data tool and the logic ships with the
  templates. `yq-go` stays available for any future pre-processing but isn't
  required for the merge.
- **curation.yaml is the human source of truth**, committed. `repos.json` is
  git-ignored (regenerated each build). Category rules are first-match-wins,
  evaluated before per-repo overrides, exactly as the brief specifies.
- **Placeholder resilience:** if `data/repos.json` is `[]` (offline `nix build`),
  the merge yields empty categories and the page still renders — no crash.

## Risks / Trade-offs

- Unauthenticated GitHub API is rate-limited (60/h). Fine for local dev with a
  warning; CI uses `github.token`. Documented in the script's warning text.
- Hugo merge logic is more verbose than jq but avoids a second toolchain and
  keeps everything in one place; acceptable for ~93 repos.
