/* Aplica o tema antes do primeiro desenho da página (evita o flash). */
(() => {
  const root = document.documentElement;
  root.classList.add('js');

  let pref = 'auto';
  try {
    const saved = window.localStorage.getItem('omakuba-theme');
    if (saved === 'auto' || saved === 'light' || saved === 'dark') {
      pref = saved;
    }
  } catch (_) {
    /* armazenamento indisponível (modo privado): fica no automático */
  }

  const media = window.matchMedia('(prefers-color-scheme: light)');
  const theme = pref === 'auto' ? (media.matches ? 'light' : 'dark') : pref;

  root.dataset.theme = theme;
  root.dataset.themePref = pref;
})();
