#!/usr/bin/env bash
# Validate the JSON embed feed against the `technative-oss/v1` contract.
# Build-time check: the feed must exist, parse, and conform before deploy.
# Usage: scripts/check-feed.sh [path]   (default: public/oss.json)
set -euo pipefail

FEED="${1:-public/oss.json}"

if [[ ! -f "$FEED" ]]; then
  echo "ERROR: feed not found at '$FEED' — did you build first?" >&2
  exit 1
fi

if ! jq empty "$FEED" 2>/dev/null; then
  echo "ERROR: '$FEED' is not valid JSON." >&2
  exit 1
fi

# jq program returns a list of human-readable problems; empty means conformant.
problems="$(jq -r '
  [
    (if .schema != "technative-oss/v1" then "schema is not \"technative-oss/v1\" (got \(.schema|tojson))" else empty end),
    (if (.generated_at | type) != "string" or (.generated_at == "") then "generated_at missing or not a string" else empty end),
    (if (.source | type) != "string" then "source missing or not a string" else empty end),
    (if .org != "wearetechnative" then "org is not \"wearetechnative\" (got \(.org|tojson))" else empty end),
    (if (.totals | type) != "object" then "totals missing" else empty end),
    (if (.categories | type) != "array" then "categories is not an array"
     else (.categories[] | select((.projects | length) == 0) | "category \(.key) is empty but present (must be omitted)")
     end),

    # totals must equal what the categories actually contain
    (if (.totals.projects) != ([.categories[].projects[]] | length)
      then "totals.projects (\(.totals.projects)) != emitted project count (\([.categories[].projects[]] | length))" else empty end),
    (if (.totals.stars) != ([.categories[].projects[].stargazers_count] | add // 0)
      then "totals.stars (\(.totals.stars)) != sum of stargazers_count (\([.categories[].projects[].stargazers_count] | add // 0))" else empty end),
    (if (.totals.forks) != ([.categories[].projects[].forks_count] | add // 0)
      then "totals.forks (\(.totals.forks)) != sum of forks_count (\([.categories[].projects[].forks_count] | add // 0))" else empty end),

    # per-category shape
    (.categories[] | select((.count) != (.projects | length)) | "category \(.key): count != len(projects)"),
    (.categories[] | select((.key|type) != "string" or (.title|type) != "string") | "category missing key/title"),

    # per-project field shapes
    (.categories[].projects[] |
      select(
        (.name|type) != "string" or
        (.full_name|type) != "string" or
        (.html_url|type) != "string" or
        (.stargazers_count|type) != "number" or
        (.forks_count|type) != "number" or
        (.topics|type) != "array" or
        (.featured|type) != "boolean" or
        (.category|type) != "string"
      ) | "project \(.name // "?") has a missing or mistyped field")
  ] | .[]
' "$FEED")"

if [[ -n "$problems" ]]; then
  echo "ERROR: '$FEED' does not conform to technative-oss/v1:" >&2
  echo "$problems" | sed 's/^/  - /' >&2
  exit 1
fi

count="$(jq '[.categories[].projects[]] | length' "$FEED")"
echo "OK: '$FEED' conforms to technative-oss/v1 (${count} projects)."
