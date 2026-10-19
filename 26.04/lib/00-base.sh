# 00-base
# Ferramentas do sistema, Docker e lazygit.

step "atualizando a lista de pacotes"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq

apt_install \
  build-essential pkg-config curl wget ca-certificates gnupg lsb-release \
  apt-transport-https software-properties-common unzip zip jq \
  tree htop fzf ripgrep fd-find bat sqlite3 tmux vim git \
  dconf-editor gnome-tweaks xdg-utils

# Ferramentas que o Bluefin traz e que fazem sentido num desktop. Uso a versão
# opcional porque algumas não existem no 24.04 e não quero derrubar o passo.
apt_install_optional \
  gnome-shell-extension-manager solaar rclone restic smartmontools tcpdump \
  fish just gum glow borgbackup cryfs davfs2 ddcutil evtest input-remapper \
  lm-sensors powertop usbmuxd ifuse libimobiledevice-utils wireguard-tools \
  wl-clipboard zenity x11-utils xdg-terminal-exec \
  libavcodec-extra gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-ugly gstreamer1.0-libav

# Em versões mais antigas o xdg-terminal-exec pode não existir. O Logo Menu e
# os atalhos do Bluefin usam ele, então deixo um fallback simples.
if ! command -v xdg-terminal-exec >/dev/null 2>&1; then
  sudo tee /usr/local/bin/xdg-terminal-exec >/dev/null <<'EOF'
#!/usr/bin/env bash
exec "${TERMINAL:-x-terminal-emulator}" "$@"
EOF
  sudo chmod 0755 /usr/local/bin/xdg-terminal-exec
  ok "criei um xdg-terminal-exec de fallback"
else
  skip "xdg-terminal-exec já existe"
fi

# Docker já vem na maioria das instalações do Ubuntu. Aqui só garanto que o
# serviço está de pé e que o seu usuário pode usar o daemon sem sudo.
if getent group docker >/dev/null; then
  if id -nG "$USER" | tr ' ' '\n' | grep -x docker >/dev/null; then
    skip "você já está no grupo docker"
  else
    sudo usermod -aG docker "$USER"
    ok "adicionei '$USER' ao grupo docker (vale no próximo login)"
  fi
else
  warn "o grupo docker não existe, então o Docker não deve estar instalado"
fi
sudo systemctl enable --now docker >/dev/null 2>&1 \
  && ok "serviço do Docker ativo" \
  || warn "não consegui ativar o docker.service"

# lazygit: pego o binário do release mais novo no GitHub.
if command -v lazygit >/dev/null; then
  skip "lazygit já instalado"
else
  case "$(uname -m)" in
    x86_64) lg_arch="x86_64" ;;
    aarch64|arm64) lg_arch="arm64" ;;
    *) lg_arch="" ;;
  esac

  if [[ -z "$lg_arch" ]]; then
    warn "arquitetura sem binário do lazygit (pulei)"
  else
    tmp="$(mktemp -d)"
    tag="$(curl -fsSL --max-time 60 https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | jq -r '.tag_name // empty' 2>/dev/null || true)"
    ver="${tag#v}"
    if [[ -n "$ver" ]] && run_quiet "baixando o lazygit" fetch \
      "https://github.com/jesseduffield/lazygit/releases/download/${tag}/lazygit_${ver}_Linux_${lg_arch}.tar.gz" \
      "$tmp/lazygit.tar.gz"; then
      run_quiet "instalando o lazygit" sudo tar -xzf "$tmp/lazygit.tar.gz" -C /usr/local/bin lazygit \
        && ok "lazygit instalado" \
        || warn "não consegui instalar o lazygit (pulei)"
    else
      warn "não consegui baixar o lazygit (pulei)"
    fi
    rm -rf "$tmp"
  fi
fi
