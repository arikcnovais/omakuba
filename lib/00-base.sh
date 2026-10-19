# ── 00-base ─────────────────────────────────────────────────────────────────
# Ferramentas base + usuário no grupo docker (precisa de sudo em 2 pontos).
step "atualizando índices do APT"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq

apt_install \
  build-essential pkg-config curl wget ca-certificates gnupg lsb-release \
  apt-transport-https software-properties-common unzip zip jq \
  tree htop fzf ripgrep fd-find bat sqlite3 tmux vim git \
  dconf-editor gnome-tweaks xdg-utils

# Docker: já vem instalado na maioria das máquinas; aqui só garantimos
# que o serviço está ativo e que o usuário pode falar com o daemon.
if getent group docker >/dev/null; then
  if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    skip "usuário já está no grupo docker"
  else
    sudo usermod -aG docker "$USER"
    ok "usuário '$USER' adicionado ao grupo docker (vale após relogar)"
  fi
else
  warn "grupo docker não existe (docker não instalado?) — pulando"
fi
sudo systemctl enable --now docker >/dev/null 2>&1 && ok "serviço docker ativo" || warn "docker.service indisponível"

# Lazygit (TUI profissional de git) — via release oficial, com fallback se falhar.
if command -v lazygit >/dev/null; then
  skip "lazygit já instalado"
else
  case "$(uname -m)" in
    x86_64) lg_arch="x86_64" ;;
    aarch64|arm64) lg_arch="arm64" ;;
    *) lg_arch="" ;;
  esac
  if [[ -n "$lg_arch" ]]; then
    tmp="$(mktemp -d)"
    if fetch "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_Linux_${lg_arch}.tar.gz" "$tmp/lazy.tar.gz" 2>/dev/null \
       || fetch "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name | tr -d v)_Linux_${lg_arch}.tar.gz" "$tmp/lazy.tar.gz" 2>/dev/null; then
      sudo tar -xzf "$tmp/lazy.tar.gz" -C /usr/local/bin lazygit && ok "lazygit instalado"
    else
      warn "lazygit não pôde ser baixado (ignorado)"
    fi
    rm -rf "$tmp"
  fi
fi