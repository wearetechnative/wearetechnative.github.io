## Context

The page and its interactivity are built and were validated ad-hoc in a scratchpad
browser. This epic makes that verification permanent and committed: a Playwright
project under `tests/`, `lychee` link-checking, and a finalised `just verify` that
CI reuses. It must be hermetic — browsers come from the flake, never downloaded.

## Goals / Non-Goals

**Goals:**
- `tests/` npm project with `@playwright/test` pinned to the flake's driver
  version, `smoke.spec.ts` covering §10 behaviours, run headless against a served
  `public/`.
- Network-origin allow-list assertion (GitHub + Umami only).
- Progressive-enhancement (JS-off) test.
- `lychee` internal-link check; `just verify` wiring; Lighthouse budget in README.

**Non-Goals:**
- Running Lighthouse inside `just verify` — documented as a manual/CI command to
  keep `verify` fast and dependency-light. The budget numbers are recorded; the
  command is provided.

## Decisions

- **Version coupling:** the flake ships `playwright-driver` 1.59.1 with
  `chromium-1217`. `tests/package.json` pins `@playwright/test@1.59.1` so the npm
  runner matches the Nix browsers. `PLAYWRIGHT_BROWSERS_PATH` +
  `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` (already exported by the devShell) make it
  use them with no download. This coupling is the one flagged in the nix epic's
  design; if the flake bumps, bump this pin.
- **Serve `public/` for the run:** `playwright.config.ts` uses a `webServer` that
  serves the built `public/` on a fixed port (Node's `http-server`-equivalent via
  a tiny static server script, or `python3 -m http.server`). Chosen: a 15-line
  Node static server committed under `tests/` — no extra npm dep, works offline.
- **Chromium only** for the smoke suite — the brief's checks are behavioural, not
  cross-browser; one project keeps CI fast. Firefox/WebKit are available in the
  flake if we later want them.
- **Network assertion:** a `page.on("request")` collector fails the test if any
  request hostname is outside `{localhost, *.github.com, github.com, umami.pimsnel.com}`.
  Umami is allow-listed per the approved analytics exception.
- **JS-off test:** a second Playwright context with `javaScriptEnabled: false`
  asserts the server-rendered card count matches the JS-on count.
- **`just verify` order:** build → `nix flake check` → `lychee public` → Playwright.
  Playwright's own `webServer` serves `public/`, so `verify` doesn't manage ports.
- **npm test script:** `npm --prefix tests test` → `playwright test`, matching the
  existing justfile line so no justfile churn beyond confirming it.
- **lychee config:** `.lychee.toml` to accept the site's relative links and treat
  external links as non-fatal (warn), excluding known-flaky/social hosts.

## Risks / Trade-offs

- Pinning Playwright to the flake version couples two files; mismatch surfaces as a
  browser-launch error, caught immediately by `verify`. Documented.
- A committed static server is a little boilerplate but avoids an npm dependency
  and keeps the run fully offline/hermetic — worth it.
- Lighthouse out of `verify` keeps the loop fast; the trade-off is that the perf
  budget is enforced manually/in CI rather than on every `verify`. Acceptable and
  documented.
