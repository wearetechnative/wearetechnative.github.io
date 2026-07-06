## MODIFIED Requirements

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
