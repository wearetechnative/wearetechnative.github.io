## 1. Fetch script

- [x] 1.1 Add `scripts/fetch-repos.sh` (`set -euo pipefail`): paginate `per_page=100`, follow `Link rel="next"`.
- [x] 1.2 Authenticate with `GITHUB_TOKEN` if set; else warn and continue unauthenticated.
- [x] 1.3 Normalise each repo via `jq` to the exact field set (incl. `license_spdx`).
- [x] 1.4 Fail non-zero on any API/HTTP/jq error or a GitHub error `message`; write atomically (temp → mv).
- [x] 1.5 Make executable; wire to `just fetch`.

## 2. Curation overlay

- [x] 2.1 Add `data/curation.yaml`: `defaults` (exclude_forks/archived/templates, exclude_repos), `category_rules`, per-repo `repos` overrides, `elastinix_group`.
- [x] 2.2 Seed the known repos from the brief (elastinix featured; awesome-* featured; optscale include:false; bmc/race/jira* tools).

## 3. Merge logic

- [x] 3.1 Add `layouts/partials/data/projects.html` returning the merged, categorised, sorted project slice.
- [x] 3.2 Apply exclusions (with `include:true` opt-in), category_rules (first match), per-repo overrides, featured/blurb fallback, sort featured→stars→pushed_at.

## 4. Verification

- [x] 4.1 Run `just fetch`; `data/repos.json` is valid JSON covering the org's repos (jq length > 0).
- [x] 4.2 Confirm merge: forks/archived/templates excluded; `optscale` absent (include false); `elastinix` featured+grouped; awesome lists categorised.
- [x] 4.3 Offline placeholder (`[]`) yields empty categories without error.
