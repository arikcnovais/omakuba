# 15-branding
# A identidade do sistema: o /etc/os-release com o nosso nome, o logo do
# Bluefin no sistema, o logo do About do GNOME, o watermark do Plymouth e o
# fastfetch com o layout e as cores do Bluefin.
#
# O nome é configurável (OMAKUBA_BRAND_NAME e OMAKUBA_BRAND_VARIANT); o padrão
# é "Omakuba". Assim o passo serve para qualquer derivado, sem nome cravado.
#
# Tudo que é do usuário (o fastfetch, os logos do fastfetch) vai para o home e
# roda sem sudo. O /etc/os-release, o logo do sistema, o logo do About e o
# watermark do Plymouth precisam de sudo, porque são arquivos do sistema. Nada
# é escrito no /root.
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
BRAND_PLYMOUTH_DIR="$BRAND_SHARE/plymouth"
BLUEFIN_COMMON_BASE="https://raw.githubusercontent.com/projectbluefin/common/main/system_files/bluefin"
BLUEFIN_LOGOS_BASE="$BLUEFIN_COMMON_BASE/usr/share/ublue-os/bluefin-logos"
BLUEFIN_PLYMOUTH_BASE="$BLUEFIN_COMMON_BASE/usr/share/plymouth/themes/spinner"
BLUEFIN_MASCOTS=(bluefin chicken dolly karl)

# Onde as artes do sistema entram. Deixei configurável para os testes rodarem
# sem root; no dia a dia valem os caminhos do Ubuntu.
PIXMAPS_DIR="${PIXMAPS_DIR:-/usr/share/pixmaps}"
PLYMOUTH_THEME_DIR="${PLYMOUTH_THEME_DIR:-/usr/share/plymouth/themes/spinner}"

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

# make_about_logo <destino>
# Monta o logo do About do GNOME com o dodô do Bluefin, o mesmo desenho do logo
# do sistema, e sem texto. O SVG embute o PNG para não depender de nenhum
# arquivo externo; a moldura quadrada de 192 px deixa o logo centralizado no
# painel, que tem exatamente essa largura.
make_about_logo() {
  local dest="$1"
  local bird="$BRAND_PNG_DIR/bluefin.png"
  local bird_b64
  [[ -f "$bird" ]] || return 1

  bird_b64="$(base64 -w0 "$bird")"

  cat > "$dest" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 493 493" width="192" height="192">
  <!-- gerado pelo omakuba; o original do Ubuntu fica em .omakuba-backup -->
  <image x="60.5" y="0" width="372" height="493" href="data:image/png;base64,$bird_b64"/>
</svg>
EOF
}

# install_system_branding <origem> <destino> <rótulo>
# Instala um arquivo de branding do sistema com backup do original do Ubuntu na
# mesma pasta (.omakuba-backup). O backup é feito uma vez só, e um arquivo que
# já está igual não é tocado.
install_system_branding() {
  local src="$1" dest="$2" label="$3"
  local backup="$dest.omakuba-backup"

  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    skip "$label já está no lugar: $dest"
    return 0
  fi

  if { [[ -e "$dest" ]] || [[ -L "$dest" ]]; } && [[ ! -e "$backup" ]] && [[ ! -L "$backup" ]]; then
    if run_quiet "guardando o original do Ubuntu ($label)" sudo cp -a "$dest" "$backup"; then
      skip "backup: $dest -> $backup"
    else
      warn "não guardei o backup de $dest"
    fi
  fi

  if run_quiet "instalando $label" \
       sudo install -Dm644 "$src" "$dest.omakuba-new" \
     && sudo mv -f "$dest.omakuba-new" "$dest"; then
    ok "$label: $dest"
    return 0
  fi

  warn "não instalei $label em $dest"
  sudo rm -f "$dest.omakuba-new" 2>/dev/null || true
  return 1
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

SYS_LOGO="$PIXMAPS_DIR/$BRAND_VARIANT.png"
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
# 3. o logo do About do GNOME
# ---------------------------------------------------------------------------
# O gnome-control-center do Ubuntu carrega o logo do About destes dois SVGs:
# ubuntu-logo-text.svg (tema claro) e ubuntu-logo-text-dark.svg (tema escuro).
# Eu troco os dois pelo dodô do Bluefin, sem texto, e guardo os originais do
# Ubuntu na mesma pasta, com o sufixo .omakuba-backup.

if [[ -f "$BRAND_PNG_DIR/bluefin.png" ]]; then
  about_tmp="$(mktemp -d)"
  if make_about_logo "$about_tmp/ubuntu-logo-text.svg"; then
    install_system_branding "$about_tmp/ubuntu-logo-text.svg" \
      "$PIXMAPS_DIR/ubuntu-logo-text.svg" "logo do About (tema claro)"
    install_system_branding "$about_tmp/ubuntu-logo-text.svg" \
      "$PIXMAPS_DIR/ubuntu-logo-text-dark.svg" "logo do About (tema escuro)"
  else
    warn "não montei o logo do About (pulei)"
  fi
  rm -rf "$about_tmp"
else
  skip "sem o logo do Bluefin eu não montei o logo do About"
fi

# ---------------------------------------------------------------------------
# 4. o watermark do Plymouth, como no Bluefin
# ---------------------------------------------------------------------------
# O Bluefin troca o watermark do tema spinner pelo dodô. No Ubuntu o tema
# padrão é o bgrt, que usa o ImageDir do spinner, então trocar o watermark do
# spinner muda o boot sem mexer no tema padrão. O original do Ubuntu fica
# guardado no mesmo lugar, com o sufixo .omakuba-backup.
#
# O update-initramfs é necessário para a imagem nova entrar no initramfs.

download_brand "$BLUEFIN_PLYMOUTH_BASE/watermark.png" "$BRAND_PLYMOUTH_DIR/watermark.png"

if [[ -f "$BRAND_PLYMOUTH_DIR/watermark.png" ]]; then
  if [[ -d "$PLYMOUTH_THEME_DIR" ]]; then
    if [[ -f "$PLYMOUTH_THEME_DIR/watermark.png" ]] \
       && cmp -s "$BRAND_PLYMOUTH_DIR/watermark.png" "$PLYMOUTH_THEME_DIR/watermark.png"; then
      skip "watermark do Plymouth já está no lugar"
    elif install_system_branding "$BRAND_PLYMOUTH_DIR/watermark.png" \
           "$PLYMOUTH_THEME_DIR/watermark.png" "watermark do Plymouth"; then
      initramfs_bin=""
      if command -v update-initramfs >/dev/null 2>&1; then
        initramfs_bin="update-initramfs"
      elif [[ -x /usr/sbin/update-initramfs ]]; then
        initramfs_bin="/usr/sbin/update-initramfs"
      fi

      if [[ -n "$initramfs_bin" ]]; then
        if run_quiet "atualizando o initramfs" sudo "$initramfs_bin" -u; then
          ok "initramfs atualizado"
        else
          warn "não atualizei o initramfs (o watermark entra na próxima atualização)"
        fi
      else
        skip "sem update-initramfs (pulei a atualização do initramfs)"
      fi
    fi
  else
    skip "tema do Plymouth não encontrado em $PLYMOUTH_THEME_DIR (pulei)"
  fi
else
  skip "sem o watermark do Bluefin eu não mexi no Plymouth"
fi

# ---------------------------------------------------------------------------
# 5. fastfetch
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
# 6. a config do fastfetch e o comando do dia a dia
# ---------------------------------------------------------------------------
# O mesmo layout do Bluefin, com os logos dele, tudo no home do usuário.

install_user_file "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
install_user_file "$DOTFILES_DIR/fastfetch/settings.json" "$HOME/.config/omakuba/fastfetch.json"
install_user_file "$DOTFILES_DIR/bin/omakuba-fastfetch" "$HOME/.local/bin/omakuba-fastfetch" 755
install_user_file "$DOTFILES_DIR/bin/omakuba-image-info" "$HOME/.local/bin/omakuba-image-info" 755

info "o os-release, o fastfetch e os logos ficam prontos depois de sair e entrar de novo."
info "o About do GNOME e o Plymouth também mudam; feche e abra o Settings para ver o logo."
info "os originais do Ubuntu ficam em *.omakuba-backup (em /usr/share/pixmaps e no tema do Plymouth)."
info "se um upgrade do base-files ou do Plymouth devolver os originais, rode este passo de novo."
info "para ver: omakuba-fastfetch (ou fastfetch, no shell novo)."
info "forçar outra cor: FASTFETCH_THEME=blue omakuba-fastfetch"
info "o nome da marca continua configurável por OMAKUBA_BRAND_NAME (veja o README)."
