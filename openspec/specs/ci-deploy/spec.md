# ci-deploy Specification

## Purpose
TBD - created by archiving change ci-cd-deploy. Update Purpose after archive.
## Requirements
### Requirement: Build-fetch-verify-deploy pipeline

The project SHALL provide a single GitHub Actions workflow that fetches repo data,
builds the site through Nix, verifies it, and deploys it to GitHub Pages, with the
deploy gated on verification success.

#### Scenario: pipeline stages run in order

- **WHEN** the workflow runs
- **THEN** it installs Nix (flakes enabled), runs `scripts/fetch-repos.sh` with a
  `GITHUB_TOKEN` to produce `data/repos.json`, builds the site with
  `hugo --minify --gc`, runs verification, and only then deploys

#### Scenario: deploy is gated on verification

- **WHEN** verification (flake check, link check, e2e suite) fails
- **THEN** the deploy job does not run

#### Scenario: hermetic build via Nix

- **WHEN** any build or verify step runs
- **THEN** it runs through `nix develop -c ...`, not a globally installed toolchain

### Requirement: Triggers and scheduled refresh

The workflow SHALL run on pushes to `main`, on manual dispatch, and on a daily
schedule so the grid stays current without pushes.

#### Scenario: triggers

- **WHEN** the workflow file is inspected
- **THEN** it declares `push` on `main`, `workflow_dispatch`, and a `schedule`
  with `cron: "0 6 * * *"`

### Requirement: Pages permissions and concurrency

The workflow SHALL use the least privileges required to deploy Pages and SHALL
serialise Pages deployments.

#### Scenario: permissions and concurrency

- **WHEN** the workflow file is inspected
- **THEN** it sets `permissions` `contents: read`, `pages: write`,
  `id-token: write`, and `concurrency` group `pages` with
  `cancel-in-progress: true`

### Requirement: Pinned action versions

Every third-party action SHALL be pinned to a released major version.

#### Scenario: actions are pinned

- **WHEN** the workflow file is inspected
- **THEN** each `uses:` reference names a released version tag (no floating
  `@main`/`@master`)

### Requirement: Documented one-time Pages setup

The README SHALL document the one-time manual step to enable Pages, and SHALL
leave a commented custom-domain (CNAME) stub without building it.

#### Scenario: Pages source documented

- **WHEN** the README is read
- **THEN** it states that Pages source must be set to "GitHub Actions" once in
  repo settings, and includes a commented CNAME/custom-domain note that builds
  nothing

