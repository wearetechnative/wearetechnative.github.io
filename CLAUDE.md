# CLAUDE.md — Autonomous build guide for `wearetechnative.github.io`

You are building the **wearetechnative open-source portfolio site** — a single,
fast, filterable Hugo landing page for ~93 public repos, hermetically built with
Nix flakes and deployed to GitHub Pages. This file is your operating manual.

**Authoritative spec:** `BRIEF-wearetechnative-portfolio-site.md` (repo root).
Re-read the relevant section before every epic. When this file and the brief
disagree, the brief wins — except where `openspec/project.md` records an approved
deviation (e.g. the Umami analytics exception).

## The golden loop (do this for every epic)

Work epic-by-epic in dependency order (beans encodes it via `blocked-by`). For
each epic:

1. **Pick the next ready epic.**
   `beans list --json --ready` → choose the highest-priority unblocked epic
   under milestone `01`. Mark it in-progress: `beans update <id> -s in-progress`.

2. **Write the OpenSpec change** (the epic body names it, e.g. `01-nix-flake-devenv`).
   ```
   openspec new change "<change-name>"
   openspec status --change "<change-name>" --json     # get artifact order
   ```
   Create artifacts in dependency order (proposal → specs → design → tasks),
   using `openspec instructions <artifact> --change "<name>" --json` for each.
   Ground everything in `openspec/project.md` and the brief. Do not copy
   `context`/`rules` blocks into the artifacts.

3. **Implement** via the apply skill / `/opsx:apply`. Work the tasks. Keep the
   bean's todo checkboxes current as you go (`- [ ]` → `- [x]`).

4. **Verify.** Run the checks relevant to the epic (`just` targets below). Nothing
   is "done" until it actually passes — run it and read the output.

5. **Complete the bean.** Only when all its todos are checked:
   `beans update <id> -s completed` and append a `## Summary of Changes` section.

6. **Archive the OpenSpec change** once implemented and verified:
   ```
   openspec archive <change-name>
   ```

7. **Commit** (see VCS rules). One commit per archived OpenSpec change, including
   both code and the updated bean/openspec files.

Repeat until milestone `01`'s Definition of Done is met, then verify the full
§10 acceptance suite and report pass/fail per checkbox.

## Issue tracking — beans

- **beans, not TodoWrite**, for all work tracking. Run `beans prime` if you need
  the full command reference.
- Hierarchy: milestone (`01 …`) → epic → task. Milestone `01` and its 7 epics
  already exist. Create task beans under an epic when you decompose it, parenting
  them with `--parent <epic-id>`.
- Milestone titles start with an incremental two-digit number (`01`, `02`, …).
  You administer milestones and epics — create milestone `02` when alpha work
  beyond this PoC begins.
- Mark a bean `completed` only when every todo item in it is checked. Add a
  `## Summary of Changes` on completion, or `## Reasons for Scrapping` if scrapped.

## Spec-driven changes — OpenSpec

- One OpenSpec change per epic. The change name is recorded in each epic bean.
- Full setup already done (`openspec init`; `openspec/project.md` written).
- Flow per change: `openspec new change` → create artifacts (proposal, specs,
  design, tasks) → `/opsx:apply` to implement → `openspec archive`.
- Read dependency artifacts before writing the next one. Validate with
  `openspec validate <change>` before applying.

## Version control — jj (Jujutsu)

- This repo uses **jj** (colocated with git). Author is **Pim Snel**
  (`sysadmin@technative.eu`), already configured.
- **Commit after every OpenSpec change archival** — and only then (plus the
  initial scaffold commit). One logical change per commit.
- Commit messages: describe the change plainly. **No self-promotion, no
  "Co-Authored-By" / "Generated with" trailers.** Author must be Pim Snel.
- Typical sequence to record a commit and start the next:
  ```
  jj describe -m "<subject>

  <body>"
  jj new            # start a fresh working-copy commit for the next change
  ```
- Remote: Pim will supply the URL. Once given:
  `jj git remote add origin <url>` then `jj git push --allow-new`.

## Nix / build — plain flakes, no flake-utils

- Supported systems via a `forAllSystems` helper over an explicit list:
  `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`.
  **Do not use flake-utils.**
- Everything hermetic: run tools through `nix develop -c ...`. `nix flake check`
  must pass.
- `just` targets are thin wrappers over `nix develop -c ...`:

  | target        | does                                                        |
  |---------------|-------------------------------------------------------------|
  | `just dev`    | `hugo server` (live preview)                                |
  | `just build`  | `hugo --minify --gc` → `public/`                            |
  | `just fetch`  | `scripts/fetch-repos.sh` → `data/repos.json`               |
  | `just verify` | `nix flake check` + `lychee` + Playwright on served `public/` |

## Guardrails (from the brief — do not cross)

- **No fabricated content.** Repo facts come from the GitHub API only. Any prose
  that isn't machine-sourced is a placeholder wrapped
  `<!-- NEEDS PIM APPROVAL: ... -->` and listed in the README "Before going live".
- **No runtime third-party calls** except the approved Umami tracker
  (`umami.pimsnel.com`, see `openspec/project.md` → Analytics). Fonts and logos
  are vendored/self-hosted.
- **Vanilla JS only** for filtering — no framework. Progressive enhancement: the
  grid must render with JS disabled.
- **Flat files only** — no database, no runtime backend.
- Commit `data/curation.yaml`, `flake.lock`, vendored assets. Git-ignore
  `data/repos.json` and `public/`.
- Out of scope (do not build): per-project pages, blog, i18n, CMS, comments,
  search backend, custom domain.

## Definition of Done (milestone 01)

The full §10 acceptance suite in the brief. In short: `nix flake check` passes;
`hugo --minify --gc` builds clean; the data fetch + merge is correct; the
Playwright e2e suite passes headless; the grid renders with JS off; only GitHub
+ Umami runtime origins; Lighthouse Perf ≥ 90 / A11y ≥ 95; README complete.
Report pass/fail per checkbox at the end of the run.
