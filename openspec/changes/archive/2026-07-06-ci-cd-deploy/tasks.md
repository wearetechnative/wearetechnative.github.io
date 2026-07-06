## 1. Workflow file

- [x] 1.1 Add `.github/workflows/deploy.yml` with triggers: `push` on `main`, `workflow_dispatch`, `schedule` cron `0 6 * * *`.
- [x] 1.2 Set `permissions` (contents: read, pages: write, id-token: write) and `concurrency` (group pages, cancel-in-progress).

## 2. Build + verify job

- [x] 2.1 `actions/checkout@v7`; install Nix via `DeterminateSystems/nix-installer-action@v22` + `magic-nix-cache-action@v14`.
- [x] 2.2 Fetch step: `nix develop -c scripts/fetch-repos.sh` with `GITHUB_TOKEN: ${{ github.token }}`.
- [x] 2.3 Build + verify: `nix develop -c just verify` (builds public/, flake check, link-check, Playwright) with `CI: true`.
- [x] 2.4 `actions/configure-pages@v6` + `actions/upload-pages-artifact@v5` (path `public/`).

## 3. Deploy job (gated)

- [x] 3.1 `deploy` job `needs: build`; deploys via `actions/deploy-pages@v5` to the `github-pages` environment.
- [x] 3.2 Confirm a failed verify fails `build` and skips `deploy`.

## 4. Docs

- [x] 4.1 README: one-time Pages source = "GitHub Actions" toggle; commented CNAME/custom-domain stub.

## 5. Verification

- [x] 5.1 `yq`/parse the workflow: valid YAML; all `uses:` pinned to version tags.
- [x] 5.2 Locally re-confirm `just verify` passes (the exact command CI runs).
- [x] 5.3 workflow_dispatch run went green and https://wearetechnative.github.io/ serves 82 cards live.
