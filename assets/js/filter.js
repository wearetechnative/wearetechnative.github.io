// Client-side search / filter / sort + dark-mode toggle.
// Vanilla JS, no framework, no network. Progressive enhancement: with JS off the
// full grid renders and these controls are simply inert.
(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {
    var doc = document.documentElement;

    // ---- Dark mode ---------------------------------------------------------
    var toggle = document.getElementById("theme-toggle");
    var userSetTheme = false;

    function prefersDark() {
      return window.matchMedia &&
        window.matchMedia("(prefers-color-scheme: dark)").matches;
    }
    function setTheme(theme) {
      doc.setAttribute("data-theme", theme);
      if (toggle) toggle.setAttribute("aria-pressed", String(theme === "dark"));
    }
    // Seed from OS preference if the user hasn't toggled.
    setTheme(prefersDark() ? "dark" : "light");
    if (window.matchMedia) {
      window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", function (e) {
        if (!userSetTheme) setTheme(e.matches ? "dark" : "light");
      });
    }
    if (toggle) {
      toggle.addEventListener("click", function () {
        userSetTheme = true;
        setTheme(doc.getAttribute("data-theme") === "dark" ? "light" : "dark");
      });
    }

    // ---- Collect cards -----------------------------------------------------
    // Cards live in category sections and the awesome band; treat uniformly.
    var sections = Array.prototype.slice.call(document.querySelectorAll("section.category, section.awesome"));
    var cards = [];
    sections.forEach(function (section) {
      var grid = section.querySelector(".grid");
      if (!grid) return;
      Array.prototype.slice.call(grid.querySelectorAll(".card")).forEach(function (el) {
        cards.push({
          el: el,
          grid: grid,
          section: section,
          name: (el.dataset.name || ""),
          text: (el.dataset.name || "") + " " + (el.dataset.desc || "") + " " + (el.dataset.topics || ""),
          lang: (el.dataset.lang || ""),
          stars: parseInt(el.dataset.stars || "0", 10),
          pushed: parseInt(el.dataset.pushed || "0", 10),
          cat: (el.dataset.category || "")
        });
      });
    });

    if (!cards.length) return; // nothing to wire (e.g. empty offline build)

    // ---- Controls ----------------------------------------------------------
    var qInput = document.getElementById("q");
    var langSel = document.getElementById("lang");
    var sortSel = document.getElementById("sort");
    var chips = Array.prototype.slice.call(document.querySelectorAll("#category-chips .chip"));

    var state = { q: "", cats: new Set(), lang: "", sort: "stars" };

    // "No results" message node.
    var noResults = document.createElement("p");
    noResults.className = "no-results empty-note";
    noResults.setAttribute("hidden", "");
    noResults.textContent = "No projects match your filters.";
    var gridsHost = sections.length ? sections[0].parentNode : document.body;
    gridsHost.appendChild(noResults);

    function matches(card) {
      if (state.q && card.text.indexOf(state.q) === -1) return false;
      if (state.cats.size && !state.cats.has(card.cat)) return false;
      if (state.lang && card.lang !== state.lang) return false;
      return true;
    }

    function comparator(a, b) {
      switch (state.sort) {
        case "updated": return b.pushed - a.pushed;
        case "name": return a.name < b.name ? -1 : (a.name > b.name ? 1 : 0);
        case "stars":
        default: return b.stars - a.stars;
      }
    }

    function apply() {
      var anyVisible = false;
      var visibleByGrid = new Map();

      cards.forEach(function (card) {
        var show = matches(card);
        card.el.hidden = !show;
        if (show) {
          anyVisible = true;
          if (!visibleByGrid.has(card.grid)) visibleByGrid.set(card.grid, []);
          visibleByGrid.get(card.grid).push(card);
        }
      });

      // Reorder visible cards within each grid, and hide empty sections.
      sections.forEach(function (section) {
        var grid = section.querySelector(".grid");
        var visible = visibleByGrid.get(grid) || [];
        visible.sort(comparator).forEach(function (card) { grid.appendChild(card.el); });
        section.hidden = visible.length === 0;
      });

      noResults.hidden = anyVisible;
    }

    // ---- Wire events -------------------------------------------------------
    var debounceTimer;
    if (qInput) {
      qInput.addEventListener("input", function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function () {
          state.q = qInput.value.trim().toLowerCase();
          apply();
        }, 120);
      });
    }
    if (langSel) {
      langSel.addEventListener("change", function () {
        state.lang = langSel.value;
        apply();
      });
    }
    if (sortSel) {
      sortSel.addEventListener("change", function () {
        state.sort = sortSel.value;
        apply();
      });
    }
    chips.forEach(function (chip) {
      chip.addEventListener("click", function () {
        var cat = chip.dataset.category;
        if (state.cats.has(cat)) { state.cats.delete(cat); chip.setAttribute("aria-pressed", "false"); }
        else { state.cats.add(cat); chip.setAttribute("aria-pressed", "true"); }
        apply();
      });
    });

    apply(); // initial sort (stars desc)
  });
})();
