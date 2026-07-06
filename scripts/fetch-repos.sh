#!/usr/bin/env bash
# Fetch all public repos of the wearetechnative org from the GitHub REST API and
# write a normalised data/repos.json. Build-time only. curl + jq. Fails loudly.
set -euo pipefail

ORG="${GITHUB_ORG:-wearetechnative}"
OUT="${1:-data/repos.json}"
API="https://api.github.com"
PER_PAGE=100

# --- auth ---------------------------------------------------------------------
AUTH=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
else
  echo "WARN: GITHUB_TOKEN not set — using unauthenticated GitHub API (rate limit 60/h)." >&2
fi

hdr=(-sS -f
  -H "Accept: application/vnd.github+json"
  -H "X-GitHub-Api-Version: 2022-11-28"
  "${AUTH[@]}")

tmp="$(mktemp)"
pages_tmp="$(mktemp)"
trap 'rm -f "$tmp" "$pages_tmp"' EXIT

echo "[]" > "$pages_tmp"
url="${API}/orgs/${ORG}/repos?per_page=${PER_PAGE}&type=public&sort=full_name"
page=0

# --- paginate: follow Link rel="next" ----------------------------------------
while [[ -n "$url" ]]; do
  page=$((page + 1))
  # Capture headers + body; -f makes curl exit non-zero on HTTP >= 400.
  headers="$(mktemp)"
  if ! body="$(curl "${hdr[@]}" -D "$headers" "$url")"; then
    echo "ERROR: GitHub API request failed (page ${page}, url ${url})." >&2
    rm -f "$headers"; exit 1
  fi

  # Abort if GitHub returned an error object instead of an array.
  if echo "$body" | jq -e 'type == "object" and has("message")' >/dev/null 2>&1; then
    echo "ERROR: GitHub API error: $(echo "$body" | jq -r '.message')" >&2
    rm -f "$headers"; exit 1
  fi

  # Merge this page into the accumulator.
  jq -s '.[0] + .[1]' "$pages_tmp" <(echo "$body") > "${pages_tmp}.new"
  mv "${pages_tmp}.new" "$pages_tmp"

  # Next page from the Link header, if any.
  url="$(grep -i '^link:' "$headers" \
        | tr ',' '\n' | grep 'rel="next"' \
        | sed -E 's/.*<([^>]+)>.*/\1/' || true)"
  rm -f "$headers"
done

count="$(jq 'length' "$pages_tmp")"
if [[ "$count" -eq 0 ]]; then
  echo "ERROR: fetched 0 repositories for org '${ORG}' — refusing to write empty data." >&2
  exit 1
fi

# --- normalise ----------------------------------------------------------------
jq 'map({
  name,
  full_name,
  html_url,
  description,
  homepage,
  language,
  topics: (.topics // []),
  stargazers_count,
  forks_count,
  archived,
  fork,
  is_template,
  pushed_at,
  license_spdx: (.license.spdx_id // null)
})' "$pages_tmp" > "$tmp"

mkdir -p "$(dirname "$OUT")"
mv "$tmp" "$OUT"
trap 'rm -f "$pages_tmp"' EXIT
echo "Wrote ${count} repositories to ${OUT}"
