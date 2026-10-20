/* Omakuba: tema, menu mobile, copiar comandos, wallpapers, seção ativa e voltar ao topo. */
(() => {
  const root = document.documentElement;
  const $ = (sel, ctx = document) => ctx.querySelector(sel);
  const $$ = (sel, ctx = document) => Array.from(ctx.querySelectorAll(sel));

  /* ---- Tema (auto, claro, escuro) ------------------------------------ */

  const themeButton = $('#theme-toggle');
  const media = window.matchMedia('(prefers-color-scheme: light)');
  const labels = { auto: 'automático', light: 'claro', dark: 'escuro' };
  let pref = root.dataset.themePref || 'auto';

  const resolveTheme = (value) =>
    value === 'light' || value === 'dark'
      ? value
      : media.matches
        ? 'light'
        : 'dark';

  const applyTheme = (value) => {
    root.dataset.theme = resolveTheme(value);
    root.dataset.themePref = value;
    if (!themeButton) return;
    themeButton.textContent = `Tema: ${labels[value]}`;
    themeButton.setAttribute('aria-label', `Tema ${labels[value]}; clique para trocar`);
    themeButton.title = `Tema ${labels[value]}; clique para alternar entre automático, claro e escuro`;
  };

  const storeTheme = (value) => {
    try {
      window.localStorage.setItem('omakuba-theme', value);
    } catch (_) {
      /* sem armazenamento: a preferência vale só nesta página */
    }
  };

  applyTheme(pref);

  if (themeButton) {
    themeButton.addEventListener('click', () => {
      const order = ['auto', 'light', 'dark'];
      pref = order[(order.indexOf(pref) + 1) % order.length];
      storeTheme(pref);
      applyTheme(pref);
    });
  }

  const onSystemThemeChange = () => {
    if (pref === 'auto') applyTheme('auto');
  };

  if (typeof media.addEventListener === 'function') {
    media.addEventListener('change', onSystemThemeChange);
  } else if (typeof media.addListener === 'function') {
    media.addListener(onSystemThemeChange);
  }

  /* ---- Menu mobile --------------------------------------------------- */

  const nav = $('#site-nav');
  const navButton = $('#nav-toggle');

  const closeNav = (returnFocus = false) => {
    if (!nav || !navButton) return;
    nav.classList.remove('is-open');
    navButton.setAttribute('aria-expanded', 'false');
    navButton.textContent = 'Menu';
    if (returnFocus) navButton.focus();
  };

  if (nav && navButton) {
    navButton.addEventListener('click', () => {
      const open = nav.classList.toggle('is-open');
      navButton.setAttribute('aria-expanded', String(open));
      navButton.textContent = open ? 'Fechar' : 'Menu';
    });

    nav.addEventListener('click', (event) => {
      if (event.target.closest('a')) closeNav();
    });

    document.addEventListener('click', (event) => {
      if (!nav.classList.contains('is-open')) return;
      if (nav.contains(event.target) || navButton.contains(event.target)) return;
      closeNav();
    });

    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape' && nav.classList.contains('is-open')) {
        closeNav(true);
      }
    });

    window.addEventListener('resize', () => {
      if (window.innerWidth > 980) closeNav();
    });
  }

  /* ---- Copiar comandos ----------------------------------------------- */

  const copyStatus = $('#copy-status');

  const copyText = async (text) => {
    if (navigator.clipboard && window.isSecureContext) {
      try {
        await navigator.clipboard.writeText(text);
        return;
      } catch (_) {
        /* tenta o caminho antigo abaixo */
      }
    }

    const helper = document.createElement('textarea');
    helper.className = 'copy-helper';
    helper.value = text;
    helper.setAttribute('readonly', '');
    document.body.appendChild(helper);
    helper.select();

    let copied = false;
    try {
      copied = document.execCommand('copy');
    } finally {
      document.body.removeChild(helper);
    }

    if (!copied) throw new Error('copy failed');
  };

  $$('.copy-btn').forEach((button) => {
    button.addEventListener('click', async () => {
      const selector = button.getAttribute('data-copy');
      if (!selector) return;

      const target = document.querySelector(selector);
      if (!target) return;

      const commands = $$('.line', target)
        .map((line) => line.textContent.trim())
        .filter(Boolean);
      const text = commands.length ? commands.join('\n') : target.textContent.trim();
      const label = button.dataset.label || (button.dataset.label = button.textContent);

      try {
        await copyText(text);
        button.textContent = 'Copiado!';
        if (copyStatus) copyStatus.textContent = 'Comandos copiados para a área de transferência.';
      } catch (_) {
        button.textContent = 'Não deu';
        if (copyStatus) copyStatus.textContent = 'Não consegui copiar; selecione o texto e copie à mão.';
      }

      window.setTimeout(() => {
        button.textContent = label;
      }, 1600);
    });
  });

  /* ---- Wallpapers no body (sorteio a cada 15s) ---------------------- */

  const wallpapers = [
    'fire-forest',
    'bamboojaro',
    'devil-thumb',
    'forest',
    'green-forest',
    'mountain',
    'watch-tower',
    'zorin12',
  ];
  const rotationMs = 15000;
  const body = document.body;
  const wallpaperClasses = wallpapers.map((name) => `wallpaper-${name}`);

  const currentWallpaper = () => {
    const found = Array.from(body.classList).find((name) => name.startsWith('wallpaper-'));
    return found ? found.slice('wallpaper-'.length) : null;
  };

  const setWallpaper = (name) => {
    body.classList.remove(...wallpaperClasses);
    body.classList.add(`wallpaper-${name}`);
  };

  const preloadWallpaper = (name) =>
    new Promise((resolve) => {
      const image = new Image();
      image.onload = () => resolve(true);
      image.onerror = () => resolve(false);
      image.src = `assets/backgrounds/${name}.jpg`;
    });

  const pickWallpaper = (avoid) => {
    if (wallpapers.length < 2) return wallpapers[0];
    let next = avoid;
    while (next === avoid) {
      next = wallpapers[Math.floor(Math.random() * wallpapers.length)];
    }
    return next;
  };

  const rotateWallpaper = async () => {
    const next = pickWallpaper(currentWallpaper());
    if (await preloadWallpaper(next)) setWallpaper(next);
    window.setTimeout(rotateWallpaper, rotationMs);
  };

  if (wallpapers.length) window.setTimeout(rotateWallpaper, 0);

  /* ---- Seção ativa no menu ------------------------------------------- */

  const navLinks = $$('.nav-links a[href^="#"]');
  const sections = navLinks
    .map((link) => document.querySelector(link.getAttribute('href')))
    .filter(Boolean);

  const markActive = (id) => {
    navLinks.forEach((link) => {
      const active = id !== null && link.getAttribute('href') === `#${id}`;
      link.classList.toggle('active', active);
      if (active) {
        link.setAttribute('aria-current', 'true');
      } else {
        link.removeAttribute('aria-current');
      }
    });
  };

  if (sections.length) {
    const updateActiveSection = () => {
      const offset = 100;
      let current = null;
      sections.forEach((section) => {
        if (section.getBoundingClientRect().top <= offset) current = section.id;
      });
      markActive(current);
    };

    updateActiveSection();
    window.addEventListener('scroll', updateActiveSection, { passive: true });
    window.addEventListener('resize', updateActiveSection);
  }

  /* ---- Voltar ao topo ------------------------------------------------ */

  const toTop = $('.to-top');
  if (toTop) {
    const updateToTop = () => {
      toTop.classList.toggle('visible', window.scrollY > 600);
    };
    updateToTop();
    window.addEventListener('scroll', updateToTop, { passive: true });
  }
})();
