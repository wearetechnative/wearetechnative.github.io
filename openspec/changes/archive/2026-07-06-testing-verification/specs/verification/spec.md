## ADDED Requirements

### Requirement: End-to-end smoke suite

The project SHALL provide a Playwright end-to-end suite that runs headless against
a locally-served copy of the built `public/` and proves the core behaviours of the
landing page.

#### Scenario: page loads and grid renders

- **WHEN** the suite loads `/`
- **THEN** the page loads and the project grid renders at least one card

#### Scenario: search narrows and every visible card matches

- **WHEN** the suite types "terraform" into the search box
- **THEN** the number of visible cards decreases and every visible card matches
  the query in its name, description, or topics

#### Scenario: category chip filters

- **WHEN** the suite toggles a category chip
- **THEN** only cards in that category remain visible and the chip's
  `aria-pressed` is `true`

#### Scenario: dark-mode toggle flips and persists

- **WHEN** the suite activates the dark-mode toggle and then performs another
  interaction
- **THEN** `data-theme` is flipped and remains flipped across the interaction

#### Scenario: no console errors

- **WHEN** the suite exercises the page
- **THEN** no browser console errors are recorded

### Requirement: Runtime network origin allow-list

The suite SHALL assert that the running page makes no network request to any
origin other than GitHub origins and the approved Umami tracker.

#### Scenario: only approved origins are contacted

- **WHEN** the page loads and is interacted with
- **THEN** every network request targets `localhost`, a GitHub origin, or
  `umami.pimsnel.com`; any other origin fails the test

### Requirement: Progressive enhancement check

The suite SHALL verify the grid renders with JavaScript disabled.

#### Scenario: grid renders without JavaScript

- **WHEN** the page is loaded with JavaScript disabled
- **THEN** every card is present in the rendered HTML

### Requirement: Link checking

The build SHALL link-check the generated `public/` directory and fail on broken
internal links.

#### Scenario: internal links resolve

- **WHEN** `lychee` runs against `public/`
- **THEN** it reports no broken internal links (external links may warn)

### Requirement: Verification entry point and performance budget

The project SHALL expose a single `just verify` command that runs the flake check,
the link check, and the e2e suite, and SHALL document the Lighthouse budget.

#### Scenario: just verify runs all gates

- **WHEN** `just verify` is run
- **THEN** it builds the site, runs `nix flake check`, runs `lychee` on `public/`,
  and runs the Playwright suite against a served `public/`

#### Scenario: performance budget documented

- **WHEN** the README is read
- **THEN** it documents the Lighthouse budget (Performance ≥ 90, Accessibility ≥
  95) and the command to measure it
