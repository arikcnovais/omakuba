# 75-cli
# O pacote de linha de comando do Bluefin. O APT resolve a maior parte e o
# Homebrew entra com o que não tem pacote no Ubuntu.

apt_install_optional \
  bat eza fd-find ripgrep fzf gh zoxide direnv tealdeer trash-cli yq glow \
  rclone restic smartmontools tcpdump fish just gum fastfetch htop tmux \
  wl-clipboard zenity python3-pip x11-utils \
  borgbackup cryfs davfs2 ddcutil evtest input-remapper lm-sensors powertop \
  usbmuxd ifuse libimobiledevice-utils wireguard-tools

# No Ubuntu, bat e fd vêm com outro nome. Os links deixam os comandos iguais
# aos do Bluefin.
mkdir -p "$HOME/.local/bin"
if [[ -x /usr/bin/batcat ]]; then
  ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
fi
if [[ -x /usr/bin/fdfind ]]; then
  ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
fi
if [[ -x /usr/bin/trash-put ]]; then
  ln -sf /usr/bin/trash-put "$HOME/.local/bin/trash"
fi

# Homebrew (Linuxbrew). É o mesmo caminho que o Bluefin usa.
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  skip "Homebrew já instalado"
else
  step "instalando o Homebrew"
  if NONINTERACTIVE=1 CI=1 run_quiet "baixando e instalando o Homebrew" \
       /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    ok "Homebrew instalado em /home/linuxbrew/.linuxbrew"
  else
    warn "o Homebrew não instalou (sigo com o que veio do APT)"
  fi
fi

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  BREW_FORMULAS=(mise chezmoi topgrade dysk podman-tui)
  for f in "${BREW_FORMULAS[@]}"; do
    if brew list --formula "$f" >/dev/null 2>&1; then
      skip "$f já está no Homebrew"
    else
      run_quiet "brew install $f" brew install "$f" \
        && ok "$f instalado" \
        || warn "$f não instalou (pulei)"
    fi
  done
fi

# uv, o gerenciador de Python do Bluefin DX.
if command -v uv >/dev/null 2>&1; then
  skip "uv já instalado"
else
  if run_quiet "instalando o uv" bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'; then
    ok "uv instalado em ~/.local/bin"
  else
    warn "o uv não instalou (pulei)"
  fi
fi

# Tailscale é opcional porque mexe em rede e exige login depois.
if [[ "${OMAKUBA_TAILSCALE:-0}" == "1" ]]; then
  if command -v tailscale >/dev/null 2>&1; then
    skip "Tailscale já instalado"
  else
    if run_quiet "instalando o Tailscale" bash -c 'curl -fsSL https://tailscale.com/install.sh | sh'; then
      ok "Tailscale instalado"
    else
      warn "o Tailscale não instalou (pulei)"
    fi
  fi
fi

info "o Homebrew entra no PATH pelo ~/.profile e pelo ~/.zshrc, no passo 90-dotfiles."
info "para o Tailscale: OMAKUBA_TAILSCALE=1 ./install.sh 75-cli"
