#!/usr/bin/env bash
#
#  common.sh — helpers compartilhados por todos os passos do omakuba.
#  Carregado pelo install.sh (e pode ser sourced isoladamente p/ testes).
#

# ── Cores / log ──────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_ORANGE=$'\033[38;5;214m'; C_GREEN=$'\033[38;5;142m'
  C_BLUE=$'\033[38;5;110m'; C_YELLOW=$'\033[38;5;221m'; C_RED=$'\033[38;5;203m'
else
  C_RESET=""; C_DIM=""; C_BOLD=""
  C_ORANGE=""; C_GREEN=""; C_BLUE=""; C_YELLOW=""; C_RED=""
fi

step() { printf '%s▸%s %s%s%s\n' "$C_ORANGE" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '  %s·%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '  %s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
skip() { printf '  %s–%s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_DIM" "$*" "$C_RESET"; }
die()  { err "$*"; exit 1; }

# ── Helpers ──────────────────────────────────────────────────────────────────

# gs <schema> <key> <value> — define um gsettings só se a chave existir.
# Tolera valores inválidos (ex.: enum de versão diferente) sem abortar o passo.
gs() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-keys "$schema" 2>/dev/null | grep -qx "$key"; then
    gsettings set "$schema" "$key" "$value" 2>/dev/null \
      || warn "gsettings: valor inválido para '$schema' '$key' (ignorado)"
  else
    warn "gsettings: chave '$key' inexistente em '$schema' (ignorada)"
  fi
}

# apt_install <pkgs...> — instala pacotes de forma idempotente.
apt_install() {
  local missing=()
  local pkg
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    skip "pacotes já instalados: $*"
    return 0
  fi
  step "apt-get install: ${missing[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
}

# ── Backup ───────────────────────────────────────────────────────────────────
# Backup datado: tudo que o omakuba vai sobrescrever fica aqui antes.
BACKUP_DIR="${BACKUP_DIR:-$HOME/.omakuba-backup-$(date +%Y%m%d-%H%M%S)}"
backup_file() {
  local file="$1"
  [[ -e "$file" ]] || return 0
  local dest="$BACKUP_DIR$file"
  mkdir -p "$(dirname "$dest")"
  cp -a "$file" "$dest"
  skip "backup: $file -> $BACKUP_DIR$file"
}

# fetch <url> <destino> — download com retry e checagem de HTTP.
fetch() {
  local url="$1" dest="$2"
  curl -fsSL --retry 3 --retry-delay 2 --max-time 180 "$url" -o "$dest"
}

# install_extension <uuid-ou-pk> — instala via extensions.gnome.org para a
# versão do GNOME em uso e habilita a extensão.
install_extension() {
  local target="$1" shell_ver info download
  shell_ver="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' || echo 46)"

  if gnome-extensions list 2>/dev/null | grep -qxF "$target"; then
    gnome-extensions enable "$target" >/dev/null 2>&1 || true
    ok "$target já instalada (habilitada)"
    return 0
  fi

  if [[ "$target" =~ ^[0-9]+$ ]]; then
    info="https://extensions.gnome.org/extension-info/?pk=${target}&shell_version=${shell_ver}"
  else
    info="https://extensions.gnome.org/extension-info/?uuid=${target}&shell_version=${shell_ver}"
  fi

  local payload
  if ! payload="$(fetch "$info" /dev/stdout 2>/dev/null)"; then
    warn "extensão '$target' sem versão para GNOME $shell_ver (ignorada)"
    return 0
  fi
  download="$(printf '%s' "$payload" | jq -r '.download_url // empty' 2>/dev/null || true)"
  local uuid
  uuid="$(printf '%s' "$payload" | jq -r '.uuid // empty' 2>/dev/null || true)"
  [[ -n "$download" && -n "$uuid" ]] || { warn "'$target': download_url vazio (ignorada)"; return 0; }

  local tmp; tmp="$(mktemp -d)"
  if fetch "https://extensions.gnome.org${download}" "$tmp/$uuid.zip" \
     && gnome-extensions install --force "$tmp/$uuid.zip" >/dev/null 2>&1; then
    gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
    ok "$uuid instalada (habilitada)"
  else
    warn "falha ao instalar '$uuid' (ignorada)"
  fi
  rm -rf "$tmp"
}