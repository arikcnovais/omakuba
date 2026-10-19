#!/usr/bin/env bash
#
# Helpers que todos os passos usam. O install.sh carrega este arquivo antes
# de rodar qualquer passo.
#

# Cores e mensagens. Se a saída não for um terminal, tudo vira texto limpo.
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_ORANGE=$'\033[38;5;214m'; C_GREEN=$'\033[38;5;142m'
  C_BLUE=$'\033[38;5;110m'; C_YELLOW=$'\033[38;5;221m'; C_RED=$'\033[38;5;203m'
else
  C_RESET=""; C_DIM=""; C_BOLD=""
  C_ORANGE=""; C_GREEN=""; C_BLUE=""; C_YELLOW=""; C_RED=""
fi

step() { printf '%s>%s %s%s%s\n' "$C_ORANGE" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '  %s.%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '  %sok%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %saviso%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '  %serro%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
skip() { printf '  %s-%s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_DIM" "$*" "$C_RESET"; }
die()  { err "$*"; exit 1; }

# gs <schema> <chave> <valor>
# Só chama o gsettings se a chave existir. Assim o script não quebra quando
# uma versão do GNOME muda ou remove alguma opção.
gs() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-keys "$schema" 2>/dev/null | grep -xF "$key" >/dev/null; then
    gsettings set "$schema" "$key" "$value" 2>/dev/null \
      || warn "gsettings: valor inválido em '$schema' '$key' (ignorei)"
  else
    warn "gsettings: '$key' não existe em '$schema' (ignorei)"
  fi
}

# apt_install <pacotes...>
# Instala só o que ainda não está no sistema.
apt_install() {
  local missing=()
  local pkg
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    skip "já instalado: $*"
    return 0
  fi
  step "apt-get install: ${missing[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
}

# apt_install_optional <pacotes...>
# Para pacotes que podem não existir em todas as versões do Ubuntu. Se um
# faltar, ele avisa e segue, sem derrubar o passo inteiro.
apt_install_optional() {
  local pkg
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      apt_install "$pkg" || warn "não instalei $pkg (pulei)"
    else
      skip "$pkg não está nos repositórios do Ubuntu (pulei)"
    fi
  done
}

# Backup com data. Tudo que o omakuba vai substituir passa por aqui antes.
BACKUP_DIR="${BACKUP_DIR:-$HOME/.omakuba-backup-$(date +%Y%m%d-%H%M%S)}"
backup_file() {
  local file="$1"
  [[ -e "$file" ]] || return 0
  local dest="$BACKUP_DIR$file"
  mkdir -p "$(dirname "$dest")"
  cp -a "$file" "$dest"
  skip "backup: $file -> $BACKUP_DIR$file"
}

# fetch <url> <destino>
# Download com algumas tentativas e tempo limite.
fetch() {
  local url="$1" dest="$2"
  curl -fsSL --retry 3 --retry-delay 2 --max-time 180 "$url" -o "$dest"
}

# run_quiet <mensagem> <comando...>
# Roda um comando que costuma demorar mostrando um spinner, para não parecer
# que o script travou. Se falhar, imprime o final da saída para ajudar.
run_quiet() {
  local msg="$1"; shift
  [[ $# -gt 0 ]] || return 0

  if [[ ! -t 1 ]]; then
    "$@"
    return $?
  fi

  local log pid rc i=0
  local frames="|/-\\"
  log="$(mktemp)"

  "$@" >"$log" 2>&1 &
  pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    printf '\r  %s%s%s %s ' "$C_BLUE" "${frames:i:1}" "$C_RESET" "$msg"
    i=$(( (i + 1) % 4 ))
    sleep 0.12
  done

  rc=0
  wait "$pid" || rc=$?
  printf '\r\033[K'

  if [[ $rc -ne 0 ]]; then
    tail -n 15 "$log" | sed 's/^/      /' >&2
  fi
  rm -f "$log"
  return $rc
}

# ext_installed <uuid>
# A extensão pode estar no home (extensions.gnome.org) ou no sistema (APT).
ext_installed() {
  local uuid="$1"
  [[ -d "$HOME/.local/share/gnome-shell/extensions/$uuid" ]] && return 0
  [[ -d "/usr/share/gnome-shell/extensions/$uuid" ]] && return 0
  gnome-extensions list 2>/dev/null | grep -xF "$uuid" >/dev/null
}

# Compila o schema que vem dentro da extensão, se precisar. Algumas extensões
# do extensions.gnome.org vêm sem o gschemas.compiled.
ext_compile_schemas() {
  local dir="$HOME/.local/share/gnome-shell/extensions/$1/schemas"
  [[ -d "$dir" ]] || return 0
  [[ -f "$dir/gschemas.compiled" ]] || glib-compile-schemas "$dir" >/dev/null 2>&1 || true
}

# ext_gs <uuid> <schema> <chave> <valor>
# Configura extensões que trazem o schema dentro da própria pasta.
ext_gs() {
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || { warn "schema de '$1' ausente (ignorei)"; return 0; }
  ext_compile_schemas "$1"
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings set "$2" "$3" "$4" 2>/dev/null \
    || warn "'$2' '$3': não apliquei"
}

# ext_has_key <uuid> <schema> <chave>
ext_has_key() {
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || return 1
  ext_compile_schemas "$1"
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings list-keys "$2" 2>/dev/null | grep -xF "$3" >/dev/null
}

# blur_has_pipeline <uuid> <nome>
blur_has_pipeline() {
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || return 1
  ext_compile_schemas "$1"
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings get org.gnome.shell.extensions.blur-my-shell pipelines 2>/dev/null \
    | grep -F "'$2'" >/dev/null
}

# persist_extensions <uuid-para-desligar-separados-por-virgula> <uuid...>
# Mantém o que já estava ligado, tira o que não quero mais e liga o que o
# projeto pede. Assim o ding, o snapd e o resto do Ubuntu continuam como estão.
persist_extensions() {
  local drop=",$1,"; shift
  local enabled=() final=() e
  while IFS= read -r e; do
    [[ -n "$e" ]] && enabled+=("$e")
  done < <(gnome-extensions list --enabled 2>/dev/null)

  for e in "${enabled[@]}"; do
    [[ "$drop" == *",$e,"* ]] && continue
    final+=("$e")
  done

  for e in "$@"; do
    ext_installed "$e" || continue
    printf '%s\n' "${final[@]}" | grep -xF "$e" >/dev/null || final+=("$e")
  done

  local gv="[" first=1
  for e in "${final[@]}"; do
    (( first )) || gv+=", "
    gv+="'$e'"
    first=0
  done
  gv+="]"
  gsettings set org.gnome.shell enabled-extensions "$gv"
  ok "extensões ligadas: ${final[*]}"
}

# flatpak_install <app...>
# Instala no home do usuário, sem sudo, e pula o que já está lá.
flatpak_install() {
  local app
  for app in "$@"; do
    if flatpak info --user "$app" >/dev/null 2>&1; then
      skip "flatpak já instalado: $app"
      continue
    fi
    if run_quiet "instalando $app" flatpak install --user -y --noninteractive flathub "$app"; then
      ok "flatpak instalado: $app"
    else
      warn "não consegui instalar o flatpak '$app' (pulei)"
    fi
  done
}

# install_extension_git <uuid> <usuario/repo> [branch]
# Para extensões que ainda não têm versão nova no extensions.gnome.org mas já
# suportam o GNOME atual no branch principal.
install_extension_git() {
  local uuid="$1" repo="$2" branch="${3:-main}" subdir="${4:-}"
  local dest="$HOME/.local/share/gnome-shell/extensions/$uuid"
  local tmp; tmp="$(mktemp -d)"

  if ! run_quiet "baixando $uuid do GitHub" fetch \
       "https://github.com/$repo/archive/refs/heads/$branch.tar.gz" "$tmp/src.tar.gz"; then
    warn "não baixei '$repo' do GitHub (pulei)"
    rm -rf "$tmp"
    return 0
  fi

  tar -xzf "$tmp/src.tar.gz" -C "$tmp" 2>/dev/null || true
  local top="$tmp/$(basename "$repo")-$branch"
  local src="$top${subdir:+/$subdir}"
  if [[ ! -f "$src/metadata.json" ]]; then
    src="$(find "$tmp" -maxdepth 3 -name metadata.json -printf '%h\n' 2>/dev/null | sed -n '1p')"
  fi
  if [[ -z "$src" || ! -f "$src/metadata.json" ]]; then
    warn "'$repo': não achei o metadata.json (pulei)"
    rm -rf "$tmp"
    return 0
  fi

  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  ext_compile_schemas "$uuid"
  gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
  ok "$uuid instalada do GitHub ($branch)"
  rm -rf "$tmp"
}

# install_extension <uuid-ou-numero>
# Baixa a extensão do extensions.gnome.org para a versão do GNOME em uso.
# Se não houver versão compatível, avisa e segue.
install_extension() {
  local target="$1" shell_ver info download
  shell_ver="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' || echo 46)"
  shell_ver="${shell_ver%%.*}"

  if gnome-extensions list 2>/dev/null | grep -xF "$target" >/dev/null; then
    gnome-extensions enable "$target" >/dev/null 2>&1 || true
    ok "$target já estava instalada"
    return 0
  fi

  if [[ "$target" =~ ^[0-9]+$ ]]; then
    info="https://extensions.gnome.org/extension-info/?pk=${target}&shell_version=${shell_ver}"
  else
    info="https://extensions.gnome.org/extension-info/?uuid=${target}&shell_version=${shell_ver}"
  fi

  local payload
  info "procurando '$target' para o GNOME $shell_ver"
  if ! payload="$(fetch "$info" /dev/stdout 2>/dev/null)"; then
    warn "'$target' não tem versão para o GNOME $shell_ver (pulei)"
    return 0
  fi
  download="$(printf '%s' "$payload" | jq -r '.download_url // empty' 2>/dev/null || true)"
  local uuid
  uuid="$(printf '%s' "$payload" | jq -r '.uuid // empty' 2>/dev/null || true)"
  [[ -n "$download" && -n "$uuid" ]] || { warn "'$target': veio sem download_url (pulei)"; return 0; }

  local tmp; tmp="$(mktemp -d)"
  if run_quiet "baixando $uuid" fetch "https://extensions.gnome.org${download}" "$tmp/$uuid.zip" \
     && run_quiet "instalando $uuid" gnome-extensions install --force "$tmp/$uuid.zip"; then
    gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
    ok "$uuid instalada"
  else
    warn "não consegui instalar '$uuid' (pulei)"
  fi
  rm -rf "$tmp"
}
