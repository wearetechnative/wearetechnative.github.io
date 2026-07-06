## MODIFIED Requirements

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
