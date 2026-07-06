# client-filtering Specification

## Purpose
TBD - created by archiving change client-interactivity. Update Purpose after archive.
## Requirements
### Requirement: Client-side search

The site SHALL filter the project grid by a free-text query matching each repo's
name, description, and topics, instantly and entirely in the browser with no
network request.

#### Scenario: search narrows the grid

- **WHEN** the user types text in the search box
- **THEN** only cards whose name, description, or topics contain the query remain
  visible, updated as they type

#### Scenario: every visible card matches

- **WHEN** a non-empty query is active
- **THEN** every visible card matches the query in name, description, or topics

#### Scenario: clearing search restores the grid

- **WHEN** the query is cleared
- **THEN** all cards allowed by the other active filters become visible again

### Requirement: Category filtering

The site SHALL let the user restrict the grid to one or more categories via the
category chips.

#### Scenario: multi-select chips

- **WHEN** one or more category chips are toggled on
- **THEN** only cards in the selected categories remain visible; with no chip
  selected, all categories are shown

#### Scenario: chip state is reflected

- **WHEN** a chip is toggled
- **THEN** its `aria-pressed` state flips to match

### Requirement: Language filtering and sorting

The site SHALL filter by language and sort the visible cards by stars, recent
update, or name.

#### Scenario: language filter

- **WHEN** a language is chosen from the dropdown
- **THEN** only cards with that language remain visible; "All languages" shows all

#### Scenario: sort reorders cards

- **WHEN** a sort option is chosen
- **THEN** the visible cards within each category reorder accordingly (stars desc,
  most-recently-updated first, or name A–Z)

### Requirement: Empty-category and empty-state handling

The site SHALL hide any category whose cards are all filtered out and indicate
when nothing matches.

#### Scenario: category with no matches is hidden

- **WHEN** every card in a category is filtered out
- **THEN** that category's heading and grid are hidden

#### Scenario: no results message

- **WHEN** no card matches the active filters
- **THEN** a visible "no results" message is shown

### Requirement: Dark-mode toggle

The site SHALL provide an accessible dark-mode toggle that flips the `data-theme`
attribute and persists across interactions within the session.

#### Scenario: toggle flips the theme

- **WHEN** the user activates the dark-mode toggle
- **THEN** the document `data-theme` switches between `light` and `dark` and the
  toggle's `aria-pressed` reflects the state

#### Scenario: initial theme follows the OS preference

- **WHEN** the page first loads and the user has not toggled
- **THEN** the theme matches the `prefers-color-scheme` media query

### Requirement: No framework, no network, progressive enhancement

The interactivity SHALL be implemented in vanilla JavaScript with no framework and
no runtime network request, and the full grid SHALL remain usable with JavaScript
disabled.

#### Scenario: no network on interaction

- **WHEN** the user searches, filters, sorts, or toggles the theme
- **THEN** no network request is made

#### Scenario: works without JavaScript

- **WHEN** JavaScript is disabled
- **THEN** every card renders and the page is readable (controls are simply inert)

