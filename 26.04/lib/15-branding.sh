# 15-branding
# A identidade do sistema: o /etc/os-release com o nosso nome, o logo do
# Bluefin no sistema e o fastfetch com o layout e as cores do Bluefin.
#
# O nome é configurável (OMAKUBA_BRAND_NAME e OMAKUBA_BRAND_VARIANT); o padrão
# é "Omakuba". Assim o passo serve para qualquer derivado, sem nome cravado.
#
# Tudo que é do usuário (o fastfetch, os logos do fastfetch) vai para o home e
# roda sem sudo. Só o /etc/os-release e o logo do sistema precisam de sudo,
# porque são arquivos do sistema. Nada é escrito no /root.
#
# As artes vêm do repositório projectbluefin/common, o mesmo de onde o Bluefin
# tira os logos dele.

BRAND_NAME="${OMAKUBA_BRAND_NAME:-Omakuba}"
BRAND_VARIANT="${OMAKUBA_BRAND_VARIANT:-$(printf '%s' "$BRAND_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')}"
[[ -n "$BRAND_VARIANT" ]] || BRAND_VARIANT="omakuba"
BRAND_SHARE="${XDG_DATA_HOME:-$HOME/.local/share}/omakuba/branding"
BRAND_LOGO_DIR="$BRAND_SHARE/logos"
BRAND_SYMBOLS_DIR="$BRAND_LOGO_DIR/symbols"
BRAND_PNG_DIR="$BRAND_LOGO_DIR/png"
BLUEFIN_LOGOS_BASE="https://raw.githubusercontent.com/projectbluefin/common/main/system_files/bluefin/usr/share/ublue-os/bluefin-logos"
BLUEFIN_MASCOTS=(bluefin chicken dolly karl)

# read_os_field <arquivo> <chave>
# Lê uma chave do os-release sem sujar as variáveis do instalador.
read_os_field() {
  ( . "$1" 2>/dev/null; printf '%s' "${!2:-}" )
}

# brand_set <arquivo> <chave> <valor já com aspas, se precisar>
brand_set() {
  local file="$1" key="$2" value="$3" tmp
  tmp="$(mktemp)"
  awk -v k="$key" -v line="$key=$value" '
    BEGIN { done = 0 }
    $0 ~ "^" k "=" { print line; done = 1; next }
    { print }
    END { if (!done) print line }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# backup_os_release
# Guarda o conteúdo atual (mesmo sendo um link simbólico) antes de trocar.
backup_os_release() {
  local dest="$BACKUP_DIR/etc/os-release"
  [[ -e "$dest" ]] && return 0
  mkdir -p "$(dirname "$dest")"
  cat /etc/os-release > "$dest" 2>/dev/null || return 0
  chmod 0644 "$dest" 2>/dev/null || true
  skip "backup: /etc/os-release -> $dest"
}

# download_brand <url> <destino>
download_brand() {
  local url="$1" dest="$2" part="$2.part"
  if [[ -s "$dest" ]]; then
    skip "já baixado: $(basename "$dest")"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if run_quiet "baixando $(basename "$dest")" fetch "$url" "$part"; then
    mv "$part" "$dest"
    ok "baixado: $(basename "$dest")"
  else
    warn "não baixei '$(basename "$dest")' (pulei)"
    rm -f "$part"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# 1. os-release com a marca do sistema
# ---------------------------------------------------------------------------
# No Ubuntu o /etc/os-release é um link para /usr/lib/os-release. Eu troco o
# link por um arquivo de verdade, então o /usr/lib/os-release continua sendo o
# do Ubuntu. Só o NAME, o PRETTY_NAME e companhia mudam; o ID, o VERSION_ID e o
# UBUNTU_CODENAME ficam como estão, senão o APT e o resto do sistema se perdem.

BASE_OS_RELEASE="${BASE_OS_RELEASE:-/usr/lib/os-release}"
[[ -r "$BASE_OS_RELEASE" ]] || BASE_OS_RELEASE=/etc/os-release

os_version_id="$(read_os_field "$BASE_OS_RELEASE" VERSION_ID)"
[[ -n "$os_version_id" ]] || os_version_id="$(read_os_field /etc/os-release VERSION_ID)"
os_base_version="$(read_os_field "$BASE_OS_RELEASE" VERSION)"
os_base_pretty="$(read_os_field "$BASE_OS_RELEASE" PRETTY_NAME)"

# O codename completo ("Resolute Raccoon", "Noble Numbat") vive entre
# parênteses no VERSION da base. Se não tiver, cai no VERSION_CODENAME.
os_codename=""
os_codename_re='\(([^)]+)\)'
if [[ "$os_base_version" =~ $os_codename_re ]]; then
  os_codename="${BASH_REMATCH[1]}"
fi
if [[ -z "$os_codename" ]]; then
  os_codename="$(read_os_field "$BASE_OS_RELEASE" VERSION_CODENAME)"
  [[ -n "$os_codename" ]] && os_codename="${os_codename^}"
fi

if [[ -n "$os_codename" ]]; then
  os_pretty="$BRAND_NAME $os_codename"
else
  os_pretty="$BRAND_NAME ${os_version_id:-linux}"
  [[ "$os_base_version" == *LTS* ]] && os_pretty="$os_pretty LTS"
fi
os_version="$os_pretty"
[[ -n "$os_base_pretty" ]] && os_version="$os_version (base $os_base_pretty)"

os_tmp="$(mktemp)"
if [[ -r "$BASE_OS_RELEASE" ]]; then
  cat "$BASE_OS_RELEASE" > "$os_tmp"
else
  printf 'ID=ubuntu\nID_LIKE=debian\n' > "$os_tmp"
fi
brand_set "$os_tmp" NAME "\"$BRAND_NAME\""
brand_set "$os_tmp" PRETTY_NAME "\"$os_pretty\""
brand_set "$os_tmp" VERSION "\"$os_version\""
brand_set "$os_tmp" LOGO "$BRAND_VARIANT"
brand_set "$os_tmp" VARIANT "\"$BRAND_NAME\""
brand_set "$os_tmp" VARIANT_ID "$BRAND_VARIANT"
chmod 0644 "$os_tmp"

if [[ -f /etc/os-release && ! -L /etc/os-release ]] && cmp -s "$os_tmp" /etc/os-release; then
  skip "/etc/os-release já está com a marca do $BRAND_NAME"
else
  backup_os_release
  if run_quiet "gravando o /etc/os-release do $BRAND_NAME" \
       sudo install -Dm644 "$os_tmp" "/etc/.os-release.$BRAND_VARIANT" \
     && sudo mv -f "/etc/.os-release.$BRAND_VARIANT" /etc/os-release; then
    ok "/etc/os-release agora é o do $BRAND_NAME ($os_pretty)"
  else
    warn "não consegui gravar o /etc/os-release (pulei)"
    sudo rm -f "/etc/.os-release.$BRAND_VARIANT" 2>/dev/null || true
  fi
fi
rm -f "$os_tmp"

# ---------------------------------------------------------------------------
# 2. o logo do Bluefin, no sistema e no home
# ---------------------------------------------------------------------------
# O os-release aponta para o logo em /usr/share/pixmaps. A arte é a do Bluefin,
# o mesmo desenho que aparece no fastfetch.

mkdir -p "$BRAND_SYMBOLS_DIR" "$BRAND_PNG_DIR"

for mascot in "${BLUEFIN_MASCOTS[@]}"; do
  download_brand "$BLUEFIN_LOGOS_BASE/symbols/$mascot" "$BRAND_SYMBOLS_DIR/$mascot"
  download_brand "$BLUEFIN_LOGOS_BASE/$mascot.png" "$BRAND_PNG_DIR/$mascot.png"
done

SYS_LOGO="/usr/share/pixmaps/$BRAND_VARIANT.png"
if [[ -f "$BRAND_PNG_DIR/bluefin.png" ]]; then
  if [[ -f "$SYS_LOGO" ]] && cmp -s "$BRAND_PNG_DIR/bluefin.png" "$SYS_LOGO"; then
    skip "logo do sistema já está no lugar"
  else
    run_quiet "instalando o logo do $BRAND_NAME" \
      sudo install -Dm644 "$BRAND_PNG_DIR/bluefin.png" "$SYS_LOGO" \
      && ok "logo do sistema em $SYS_LOGO" \
      || warn "não instalei o logo do sistema (pulei)"
  fi
else
  skip "sem o logo do Bluefin eu não instalei o logo do sistema"
fi

# ---------------------------------------------------------------------------
# 3. fastfetch
# ---------------------------------------------------------------------------
# No 26.04 o fastfetch está no APT. No 24.04 não está, então baixo o binário do
# GitHub direto para o ~/.local/bin, sem sudo.

if command -v fastfetch >/dev/null 2>&1; then
  skip "fastfetch já instalado ($(fastfetch --version 2>/dev/null | sed -n '1p'))"
elif apt-cache show fastfetch >/dev/null 2>&1; then
  apt_install fastfetch
else
  case "$(uname -m)" in
    x86_64)          ff_arch="amd64" ;;
    aarch64|arm64)   ff_arch="aarch64" ;;
    *)               ff_arch="" ;;
  esac

  if [[ -z "$ff_arch" ]]; then
    warn "sem binário do fastfetch para a arquitetura $(uname -m) (pulei)"
  else
    ff_tmp="$(mktemp -d)"
    ff_tag="$(github_latest_tag fastfetch-cli/fastfetch || true)"
    ff_url="https://github.com/fastfetch-cli/fastfetch/releases/download/${ff_tag}/fastfetch-linux-${ff_arch}.tar.gz"
    if [[ -n "$ff_tag" ]] && run_quiet "baixando o fastfetch" fetch "$ff_url" "$ff_tmp/fastfetch.tar.gz"; then
      mkdir -p "$HOME/.local/bin"
      if tar -xzf "$ff_tmp/fastfetch.tar.gz" -C "$ff_tmp" 2>/dev/null \
         && ff_bin="$(find "$ff_tmp" -type f -path '*/usr/bin/fastfetch' -printf '%p\n' 2>/dev/null | sed -n '1p')" \
         && [[ -n "$ff_bin" ]]; then
        install -Dm755 "$ff_bin" "$HOME/.local/bin/fastfetch"
        ok "fastfetch instalado em $HOME/.local/bin/fastfetch"
      else
        warn "não achei o binário do fastfetch no pacote (pulei)"
      fi
    else
      warn "não baixei o fastfetch (pulei)"
    fi
    rm -rf "$ff_tmp"
  fi
fi

# ---------------------------------------------------------------------------
# 4. a config do fastfetch e o comando do dia a dia
# ---------------------------------------------------------------------------
# O mesmo layout do Bluefin, com os logos dele, tudo no home do usuário.

install_user_file "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
install_user_file "$DOTFILES_DIR/fastfetch/settings.json" "$HOME/.config/omakuba/fastfetch.json"
install_user_file "$DOTFILES_DIR/bin/omakuba-fastfetch" "$HOME/.local/bin/omakuba-fastfetch" 755
install_user_file "$DOTFILES_DIR/bin/omakuba-image-info" "$HOME/.local/bin/omakuba-image-info" 755

info "o os-release, o fastfetch e os logos ficam prontos depois de sair e entrar de novo."
info "para ver: omakuba-fastfetch (ou fastfetch, no shell novo)."
info "forçar outra cor: FASTFETCH_THEME=blue omakuba-fastfetch"
info "marca: OMAKUBA_BRAND_NAME=\"Minha Distro\" ./install.sh 15-branding"
