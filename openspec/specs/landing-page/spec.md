# landing-page Specification

## Purpose
TBD - created by archiving change landing-page-ui. Update Purpose after archive.
## Requirements
### Requirement: Single server-rendered landing page

The site SHALL render the entire portfolio as one page, server-side from the
merged project objects, so the full grid is present with JavaScript disabled.

#### Scenario: full grid renders without JavaScript

- **WHEN** the page is served and JavaScript is disabled
- **THEN** every included repo appears as a card in its category

#### Scenario: sections present top to bottom

- **WHEN** the page loads
- **THEN** it renders, in order: header, hero, ElastiNix spotlight, sticky filter
  bar, project grid by category, awesome-lists band, and footer

### Requirement: Header

The header SHALL provide branding and navigation.

#### Scenario: header contents

- **WHEN** the header renders
- **THEN** it shows the TechNative logo linking to `https://technative.eu`, the
  site title, category nav anchors, a dark-mode toggle button, and a
  "View on GitHub" link to the org

### Requirement: Hero with a computed factual sub-line

The hero SHALL state a confident engineer-to-engineer line and one factual
sub-line whose repo count is computed from the data, not hardcoded.

#### Scenario: repo count is computed

- **WHEN** the hero renders
- **THEN** the sub-line shows the number of shown projects derived from the merged
  data

#### Scenario: unverified prose is flagged

- **WHEN** the hero contains marketing/prose copy not sourced from the API
- **THEN** it is wrapped in a `NEEDS PIM APPROVAL` HTML comment

### Requirement: Project cards

Each project SHALL render as an accessible card of machine-sourced facts.

#### Scenario: card contents

- **WHEN** a card renders
- **THEN** it shows the repo name (monospace) linking to the repo, the
  description/blurb, a language dot + label, the star count, a relative
  last-updated time, and topic tags

#### Scenario: cards are accessible

- **WHEN** a card renders
- **THEN** it is keyboard-focusable and has a screen-reader label, and carries
  data attributes (name, description, topics, language, stars, pushed date) for
  client-side filtering

### Requirement: Categories and empty-hiding

Categories SHALL display in the approved order — ElastiNix, Terraform Modules,
Cloud-Engineer Tools, Quarto, Awesome Lists, Other — and any empty category SHALL
be hidden.

#### Scenario: empty category hidden

- **WHEN** a category has zero projects
- **THEN** neither its heading nor its nav anchor renders

#### Scenario: quarto category renders in order

- **WHEN** at least one repo matches the Quarto rules
- **THEN** a "Quarto" section and nav anchor render between Cloud-Engineer Tools
  and Awesome Lists

### Requirement: Awesome-lists band and footer

The page SHALL give the awesome lists a distinct band and render a footer with
required links and legal notes.

#### Scenario: footer contents

- **WHEN** the footer renders
- **THEN** it shows the vendored light-on-dark logo, a flagged "why we
  open-source" blurb, links to the GitHub org, technative.eu, and LinkedIn, the
  current-year copyright, and the Apache-2.0 note; the X/Twitter link stays
  commented out

