# 20-terminal
# Kitty, Zsh, Starship e os plugins do Zsh.
apt_install kitty zsh

# Starship pelo instalador oficial.
if command -v starship >/dev/null; then
  skip "starship já instalado"
else
  if run_quiet "instalando o starship" \
       sudo bash -c 'curl -fsSL --max-time 60 https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin'; then
    ok "starship instalado"
  else
    warn "não consegui instalar o starship (pulei)"
  fi
fi

# Plugins do Zsh ficam em ~/.local/share para não sujar o home.
ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"
for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting zsh-users/zsh-history-substring-search; do
  name="${repo##*/}"
  if [[ -d "$ZSH_PLUGIN_DIR/$name" ]]; then
    skip "$name já está clonado"
  else
    run_quiet "clonando $name" git clone --depth=1 "https://github.com/$repo.git" "$ZSH_PLUGIN_DIR/$name" \
      && ok "$name clonado" \
      || warn "$name falhou (pulei)"
  fi
done

# Zsh como shell padrão. Vale no próximo login.
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" != "$(command -v zsh)" ]]; then
  sudo chsh -s "$(command -v zsh)" "$USER" \
    && ok "shell padrão agora é o zsh (vale no próximo login)"
else
  skip "o zsh já é o seu shell padrão"
fi

# Deixo o GNOME Terminal com a mesma cara do Kitty, para quando ele aparecer.
if command -v gnome-terminal >/dev/null; then
  GT_PROFILE="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'" || true)"
  if [[ -n "$GT_PROFILE" ]]; then
    GT="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${GT_PROFILE}/"
    gs "$GT" visible-name "omakuba"
    gs "$GT" use-theme-colors false
    gs "$GT" use-theme-transparency false
    gs "$GT" use-transparent-background true
    gs "$GT" background-transparency-percent 8
    gs "$GT" foreground-color "#17A88B"
    gs "$GT" background-color "#1E2229"
    gs "$GT" cursor-shape "ibeam"
    gs "$GT" cursor-blink-mode "on"
    gs "$GT" cursor-colors-set true
    gs "$GT" cursor-foreground-color "#1E2229"
    gs "$GT" cursor-background-color "#17A88B"
    gs "$GT" highlight-colors-set true
    gs "$GT" highlight-foreground-color "#1E2229"
    gs "$GT" highlight-background-color "#17A88B"
    gs "$GT" bold-is-bright false
    gs "$GT" scrollback-lines 10000
    gs "$GT" palette \
      "['#1E2229', '#ED1515', '#44853A', '#F67400', '#1D99F3', '#9B59B6', '#1ABC9C', '#FCFCFC', '#7F8C8D', '#C0392B', '#55A649', '#FDBC4B', '#3DAEE9', '#8E44AD', '#16A085', '#FFFFFF']"
    if grep -qi "JetBrainsMono Nerd Font Mono" < <(fc-list 2>/dev/null); then
      gs "$GT" use-system-font false
      gs "$GT" font "JetBrainsMono Nerd Font Mono 12"
    fi
    ok "GNOME Terminal com o perfil omakuba"
  fi
fi
