## 1. Test project scaffold

- [x] 1.1 Add `tests/package.json` pinning `@playwright/test` to the flake driver version (1.59.1); `test` script → `playwright test`.
- [x] 1.2 Add `tests/playwright.config.ts`: chromium project, headless, `webServer` serving built `public/` on a fixed port, base URL.
- [x] 1.3 Add a tiny committed static server (`tests/serve.mjs`) so the run needs no extra npm dep and stays offline.
- [x] 1.4 Add `tests/.gitignore` (node_modules, test-results, report) — or rely on repo root .gitignore.

## 2. Smoke spec

- [x] 2.1 `tests/smoke.spec.ts`: page loads, grid ≥1 card.
- [x] 2.2 Search "terraform" narrows grid; every visible card matches.
- [x] 2.3 Category chip toggle filters; `aria-pressed` true.
- [x] 2.4 Dark-mode toggle flips `data-theme` and persists across a later interaction.
- [x] 2.5 No console errors during interaction.
- [x] 2.6 Network-origin allow-list: only localhost / GitHub / umami.pimsnel.com.
- [x] 2.7 Progressive enhancement: JS-off context renders all cards.

## 3. Link checking

- [x] 3.1 Add `.lychee.toml` (accept relative links; external non-fatal/warn; sensible excludes).
- [x] 3.2 Confirm `lychee public` passes on internal links.

## 4. Wiring & docs

- [x] 4.1 Confirm `just verify` = build → flake check → lychee → Playwright.
- [x] 4.2 Document the Lighthouse budget (Perf ≥90, A11y ≥95) + command in README.

## 5. Verification

- [x] 5.1 `npm --prefix tests install` then `just verify` passes end to end (hermetic, browsers from flake).
- [x] 5.2 Build stays 0 warnings / 0 errors.
