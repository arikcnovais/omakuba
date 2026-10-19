/* app.js — o script do site do Omakuba.
 *
 * Três coisas, todas locais:
 *   1. copiar os comandos de instalação (com degradação para seleção manual);
 *   2. o menu no celular;
 *   3. o tema (auto / claro / escuro).
 *
 * Não existe fetch, XHR, analytics nem imagem remota: este site não faz
 * nenhuma requisição de rede. O CSP reflete isso em connect-src 'none'.
 *
 * E nada de innerHTML: todo texto passa por textContent.
 */
(function () {
  "use strict";

  var THEME_KEY = "float_theme_mode";
  var THEME_ORDER = ["auto", "light", "dark"];
  var THEME_LABEL = { auto: "auto", light: "claro", dark: "escuro" };
  var THEME_COLOR = { auto: "#7FD066", light: "#EDECEA", dark: "#2B2C2E" };

  function $(selector) {
    return document.querySelector(selector);
  }

  function readStore(key) {
    try {
      return window.localStorage.getItem(key);
    } catch (err) {
      return null;
    }
  }

  function writeStore(key, value) {
    try {
      window.localStorage.setItem(key, value);
    } catch (err) {
      /* modo privado: o site segue funcionando, só não lembra a escolha */
    }
  }

  /* --- Tema ------------------------------------------------------------- */

  var media = window.matchMedia ? window.matchMedia("(prefers-color-scheme: dark)") : null;

  function storedTheme() {
    var value = readStore(THEME_KEY);
    return THEME_ORDER.indexOf(value) >= 0 ? value : "auto";
  }

  function applyTheme(mode) {
    var dark = mode === "dark" || (mode === "auto" && media && media.matches);
    if (dark) document.documentElement.setAttribute("data-theme", "dark");
    else document.documentElement.removeAttribute("data-theme");

    var button = $("#theme-toggle");
    if (button) button.textContent = "Tema: " + THEME_LABEL[mode];
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute("content", THEME_COLOR[mode]);
  }

  function initTheme() {
    applyTheme(storedTheme());

    var button = $("#theme-toggle");
    if (button) {
      button.addEventListener("click", function () {
        var next = THEME_ORDER[(THEME_ORDER.indexOf(storedTheme()) + 1) % THEME_ORDER.length];
        writeStore(THEME_KEY, next);
        applyTheme(next);
      });
    }

    if (media) {
      var onChange = function () {
        if (storedTheme() === "auto") applyTheme("auto");
      };
      if (media.addEventListener) media.addEventListener("change", onChange);
      else if (media.addListener) media.addListener(onChange);
    }
  }

  /* --- Menu no celular -------------------------------------------------- */

  function initNav() {
    var toggle = $("#nav-toggle");
    var links = $("#nav-links");
    if (!toggle || !links) return;

    toggle.addEventListener("click", function () {
      var open = links.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });

    links.addEventListener("click", function (event) {
      if (event.target && event.target.tagName === "A") {
        links.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
      }
    });
  }

  /* --- Copiar comandos -------------------------------------------------- */

  function selectContents(node) {
    var range = document.createRange();
    range.selectNodeContents(node);
    var selection = window.getSelection();
    if (!selection) return false;
    selection.removeAllRanges();
    selection.addRange(range);
    return true;
  }

  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return Promise.reject(new Error("clipboard indisponível"));
  }

  function flash(button, label) {
    var original = button.getAttribute("data-label") || button.textContent;
    button.setAttribute("data-label", original);
    button.textContent = label;
    window.setTimeout(function () {
      button.textContent = original;
    }, 2200);
  }

  function initCopy() {
    var buttons = document.querySelectorAll("[data-copy]");
    Array.prototype.forEach.call(buttons, function (button) {
      button.addEventListener("click", function () {
        var target = document.querySelector(button.getAttribute("data-copy"));
        if (!target) return;

        /* Copia só os comandos: as linhas de saída (.out) e os comentários
           ficam de fora, senão o texto colado no shell tentaria executar a
           explicação. O "$" do prompt é CSS e também não entra. */
        var clone = target.cloneNode(true);
        var extra = clone.querySelectorAll(".out, .comment");
        Array.prototype.forEach.call(extra, function (node) {
          node.remove();
        });

        var text = clone.textContent.replace(/[ \t]+$/gm, "").replace(/\n{3,}/g, "\n\n").trim() + "\n";

        copyText(text).then(
          function () {
            flash(button, "Copiado");
          },
          function () {
            if (selectContents(target)) flash(button, "Ctrl+C agora");
            else flash(button, "Selecione o texto");
          }
        );
      });
    });
  }

  initTheme();
  initNav();
  initCopy();
})();
