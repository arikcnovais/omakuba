#!/usr/bin/env bash
#
#  omakuba — setup de desenvolvimento para Ubuntu 24.04 (GNOME/Yaru)
#  Inspirado na filosofia do Omakub, escrito do zero (zero componentes do Omakub).
#
#  Uso:
#     ./install.sh              # executa todos os passos
#     ./install.sh --list       # lista os passos
#     ./install.sh 30-dev       # executa apenas o passo 30-dev
#     ./install.sh 50-gnome 90-dotfiles
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"

ALL_STEPS=(
  "00-base"
  "10-fonts"
  "20-terminal"
  "30-dev"
  "40-vscode"
  "50-gnome"
  "60-wallpapers"
  "90-dotfiles"
)

banner() {
  printf '\n\033[38;5;214m%s\033[0m\n' "  ╔══════════════════════════════════════════════════╗"
  printf '\033[38;5;214m%s\033[0m\n' "  ║  omakuba · dev setup para Ubuntu 24.04 + GNOME     ║"
  printf '\033[38;5;214m%s\033[0m\n' "  ╚══════════════════════════════════════════════════╝"
}

usage() {
  banner
  cat <<'EOF'

  Passos disponíveis:
    00-base        Ferramentas base via APT + usuário no grupo docker
    10-fonts       JetBrainsMono Nerd Font (ícones no terminal/editor)
    20-terminal    Kitty + Zsh + Starship + plugins (autosuggestions/highlight)
    30-dev         Node LTS via nvm, pnpm/yarn, .NET SDK 10 + 8, dotnet tools
    40-vscode      Extensões do VS Code + settings minimalistas (merge)
    50-gnome       Extensões (Forge, Blur my Shell, Vitals, Caffeine) + Yaru polish
    60-wallpapers  Wallpapers dinâmicos (Chillsmeit) + aplicar um dark minimal
    90-dotfiles    Deploy dos dotfiles (com backup do que já existe)

  Uso:
    ./install.sh              # tudo
    ./install.sh --list       # só a lista
    ./install.sh 50-gnome     # um passo específico

EOF
}

require_sudo() {
  if sudo -n true 2>/dev/null; then
    return 0
  fi
  if [[ -t 0 ]]; then
    step "Validando credenciais sudo…"
    sudo -v || die "sudo falhou."
  else
    die "Sem credenciais sudo. Rode 'sudo -v' antes (ou em um terminal interativo)."
  fi
}

main() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then usage; exit 0; fi
  if [[ "${1:-}" == "--list" ]]; then printf '%s\n' "${ALL_STEPS[@]}"; exit 0; fi

  local steps=()
  if [[ $# -gt 0 ]]; then
    steps=("$@")
  else
    steps=("${ALL_STEPS[@]}")
  fi

  require_sudo
  banner

  local started total=0
  started=$(date +%s)

  for step_name in "${steps[@]}"; do
    local file="$ROOT/lib/${step_name}.sh"
    [[ -f "$file" ]] || die "Passo desconhecido: '$step_name' (use --list)"
    total=$((total + 1))
    printf '\n\033[1;38;5;208m▸ %s\033[0m\n' "$((total)). $step_name"
    # shellcheck disable=SC1090
    source "$file"
  done

  local elapsed=$(( $(date +%s) - started ))
  printf '\n'
  ok "Concluído em ${elapsed}s — aproveite seu setup."
}

main "$@"