#!/usr/bin/env bash
#
# omakuba para Ubuntu 24.04 (GNOME 46 + Adwaita)
#
# Uso:
#   ./install.sh              roda todos os passos
#   ./install.sh --list       mostra os passos
#   ./install.sh 30-dev       roda só um passo
#   ./install.sh 50-gnome 90-dotfiles
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$ROOT/.." && pwd)"
DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
export ROOT PROJECT_ROOT DOTFILES_DIR

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

WANT_UBUNTU="24.04"

banner() {
  printf '\n\033[38;5;214momakuba para Ubuntu 24.04\033[0m\n'
  printf '\033[2mGNOME 46, Adwaita e Forge no lugar do tiling do sistema\033[0m\n'
}

usage() {
  banner
  cat <<'EOF'

  Passos:
    00-base        ferramentas do dia a dia via APT, Docker e lazygit
    10-fonts       JetBrainsMono Nerd Font
    20-terminal    Kitty, Zsh, Starship e os plugins do Zsh
    30-dev         Node LTS, pnpm, yarn, .NET e ferramentas do dotnet
    40-vscode      extensões e settings do VS Code
    50-gnome       Forge, Blur my Shell, Vitals, Caffeine e ajustes de aparência
    60-wallpapers  instala os wallpapers que estão em dotfiles/backgrounds
    90-dotfiles    copia os dotfiles, com backup do que já existe

  Uso:
    ./install.sh              tudo
    ./install.sh --list       só a lista
    ./install.sh 50-gnome     um passo específico

  Se estiver em outra versão do Ubuntu, o script para. Para insistir:
    OMAKUBA_FORCE=1 ./install.sh

EOF
}

check_ubuntu() {
  local id="" version="" pretty=""
  if [[ -r /etc/os-release ]]; then
    id="$(. /etc/os-release; printf '%s' "${ID:-}")"
    version="$(. /etc/os-release; printf '%s' "${VERSION_ID:-}")"
    pretty="$(. /etc/os-release; printf '%s' "${PRETTY_NAME:-}")"
  fi
  if [[ "$id" != "ubuntu" || "$version" != "$WANT_UBUNTU" ]]; then
    warn "este script é para Ubuntu $WANT_UBUNTU, mas estou vendo ${pretty:-um sistema que não reconheci}."
    if [[ "${OMAKUBA_FORCE:-0}" != "1" ]]; then
      die "para rodar de qualquer jeito: OMAKUBA_FORCE=1 ./install.sh"
    fi
    warn "seguindo porque OMAKUBA_FORCE=1."
  fi
}

require_sudo() {
  if sudo -n true 2>/dev/null; then
    return 0
  fi
  if [[ -t 0 ]]; then
    step "pedindo a senha do sudo"
    sudo -v || die "o sudo não aceitou a senha."
  else
    die "não tenho sudo sem senha. Rode 'sudo -v' antes, num terminal normal."
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

  check_ubuntu

  # O passo 90-dotfiles só mexe no seu home, então não precisa de sudo.
  if [[ ${#steps[@]} -eq 1 && "${steps[0]}" == "90-dotfiles" ]]; then
    :
  else
    require_sudo
  fi
  banner

  local started total_steps index=0
  local failed=()
  started=$(date +%s)
  total_steps=${#steps[@]}

  for step_name in "${steps[@]}"; do
    local file="$ROOT/lib/${step_name}.sh"
    [[ -f "$file" ]] || die "passo desconhecido: '$step_name' (veja --list)"
    index=$((index + 1))

    printf '\n\033[1;38;5;208m[%d/%d] %s\033[0m\n' "$index" "$total_steps" "$step_name"
    local step_start step_rc step_elapsed
    step_start=$(date +%s)

    # Um passo com problema não derruba o resto. Assim o 90-dotfiles roda
    # mesmo que o download dos wallpapers, por exemplo, tenha falhado.
    set +e
    # shellcheck disable=SC1090
    source "$file"
    step_rc=$?
    set -e

    step_elapsed=$(( $(date +%s) - step_start ))
    if [[ $step_rc -eq 0 ]]; then
      ok "$step_name pronto em ${step_elapsed}s"
    else
      warn "$step_name terminou com erro ($step_rc), seguindo em frente"
      failed+=("$step_name")
    fi
  done

  local elapsed=$(( $(date +%s) - started ))
  printf '\n'
  if [[ ${#failed[@]} -gt 0 ]]; then
    warn "passos com problema: ${failed[*]}"
  fi
  ok "terminei em ${elapsed}s. Bom trabalho."
}

main "$@"
