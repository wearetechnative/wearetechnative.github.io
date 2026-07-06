import { test, expect, Page } from "@playwright/test";

// Origins the running page is allowed to contact. Anything else fails the test.
// GitHub (build-time data is baked in, but avatars/links may resolve) + the
// approved self-hosted Umami tracker.
const ALLOWED_HOSTS = [
  "localhost",
  "127.0.0.1",
  "umami.pimsnel.com",
  "github.com",
  "api.github.com",
  "raw.githubusercontent.com",
  "avatars.githubusercontent.com",
];

function hostAllowed(url: string): boolean {
  try {
    const h = new URL(url).hostname;
    return ALLOWED_HOSTS.some((a) => h === a || h.endsWith("." + a));
  } catch {
    return url.startsWith("data:") || url.startsWith("blob:");
  }
}

function trackErrorsAndRequests(page: Page) {
  const consoleErrors: string[] = [];
  const badRequests: string[] = [];
  page.on("console", (m) => {
    if (m.type() === "error") consoleErrors.push(m.text());
  });
  page.on("request", (r) => {
    if (!hostAllowed(r.url())) badRequests.push(r.url());
  });
  return { consoleErrors, badRequests };
}

test.describe("landing page", () => {
  test("loads and renders the grid", async ({ page }) => {
    await page.goto("/");
    const cards = page.locator("article.card:visible");
    expect(await cards.count()).toBeGreaterThan(0);
  });

  test("search narrows the grid and every visible card matches", async ({ page }) => {
    await page.goto("/");
    const cards = page.locator("article.card:visible");
    const total = await cards.count();

    await page.fill("#q", "terraform");
    await expect
      .poll(async () => cards.count(), { timeout: 3000 })
      .toBeLessThan(total);

    const allMatch = await page.evaluate(() => {
      const q = "terraform";
      return [...document.querySelectorAll<HTMLElement>("article.card")]
        .filter((c) => !c.hidden)
        .every((c) =>
          `${c.dataset.name} ${c.dataset.desc} ${c.dataset.topics}`
            .toLowerCase()
            .includes(q)
        );
    });
    expect(allMatch).toBe(true);

    // clearing restores the full grid
    await page.fill("#q", "");
    await expect.poll(async () => cards.count(), { timeout: 3000 }).toBe(total);
  });

  test("category chip filters and sets aria-pressed", async ({ page }) => {
    await page.goto("/");
    const chip = page.locator("#category-chips .chip").first();
    const cat = await chip.getAttribute("data-category");
    await chip.click();
    await expect(chip).toHaveAttribute("aria-pressed", "true");

    const onlyCat = await page.evaluate(
      (c) =>
        [...document.querySelectorAll<HTMLElement>("article.card")]
          .filter((el) => !el.hidden)
          .every((el) => el.dataset.category === c),
      cat
    );
    expect(onlyCat).toBe(true);
  });

  test("dark-mode toggle flips data-theme and persists across interaction", async ({ page }) => {
    await page.goto("/");
    const before = await page.evaluate(() =>
      document.documentElement.getAttribute("data-theme")
    );
    await page.click("#theme-toggle");
    const after = await page.evaluate(() =>
      document.documentElement.getAttribute("data-theme")
    );
    expect(after).not.toBe(before);
    await expect(page.locator("#theme-toggle")).toHaveAttribute(
      "aria-pressed",
      String(after === "dark")
    );

    // persists across a later interaction (a search)
    await page.fill("#q", "aws");
    await page.fill("#q", "");
    const stillAfter = await page.evaluate(() =>
      document.documentElement.getAttribute("data-theme")
    );
    expect(stillAfter).toBe(after);
  });

  test("no console errors and only approved network origins", async ({ page }) => {
    const { consoleErrors, badRequests } = trackErrorsAndRequests(page);
    await page.goto("/", { waitUntil: "networkidle" });
    // exercise the page a bit
    await page.fill("#q", "terraform");
    await page.fill("#q", "");
    await page.locator("#category-chips .chip").first().click();
    await page.click("#theme-toggle");
    await page.waitForTimeout(300);

    expect(consoleErrors, `console errors: ${consoleErrors.join(" | ")}`).toEqual([]);
    expect(
      badRequests,
      `unexpected network origins: ${badRequests.join(" | ")}`
    ).toEqual([]);
  });

  test("no-results message shows when nothing matches", async ({ page }) => {
    await page.goto("/");
    await page.fill("#q", "zzzznomatchzzzz");
    await expect(page.locator(".no-results")).toBeVisible();
    expect(await page.locator("article.card:visible").count()).toBe(0);
  });
});

test.describe("progressive enhancement", () => {
  test.use({ javaScriptEnabled: false });

  test("full grid renders with JavaScript disabled", async ({ page }) => {
    await page.goto("/");
    // With JS off the cards are all present (none hidden by the filter engine).
    const count = await page.locator("article.card").count();
    expect(count).toBeGreaterThan(0);
  });
});
