# 60-wallpapers
# Pega as imagens que você deixar em dotfiles/backgrounds/ e instala todas no
# sistema, criando o XML que faz cada uma aparecer em Configurações, Aparência,
# Papel de parede. O green forest fica como padrão quando está na pasta.

WP_SRC_DIR="${WP_SRC_DIR:-$DOTFILES_DIR/backgrounds}"
WP_DST_DIR="${WP_DST_DIR:-/usr/share/backgrounds/omakuba}"
WP_XML_DIR="${WP_XML_DIR:-/usr/share/gnome-background-properties}"
BREATH_BG="#1e2229"

# Nome que vai aparecer na lista de wallpapers.
wallpaper_name() {
  local base="${1%.*}"
  base="${base//_/ }"
  base="${base//-/ }"
  if [[ "$base" == [Bb]amboo* ]]; then
    printf 'Bamboo (omakuba)'
  elif [[ "$base" == [Gg]reen[[:space:]]*[Ff]orest ]]; then
    printf 'Green Forest (omakuba)'
  else
    printf '%s (omakuba)' "$base"
  fi
}

# Nome do arquivo XML, sem espaço nem acento.
wallpaper_slug() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//'
}

xml_escape() {
  printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Transforma um caminho em URI de arquivo. O python3 cuida dos espaços e dos
# acentos, que aparecem nos nomes dos wallpapers.
file_uri() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).as_uri())' "$1"
  else
    printf 'file://%s' "$1"
  fi
}

apply_wallpaper() {
  local prop="$1"
  [[ -f "$prop" ]] || return 1

  local target uri
  target="$(sed -n 's:.*<filename>\([^<]*\)</filename>.*:\1:p' "$prop" | sed -n '1p')"
  [[ -n "$target" && -e "$target" ]] || return 1
  uri="$(file_uri "$target")"

  gsettings set org.gnome.desktop.background picture-uri      "$uri"
  gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
  gs org.gnome.desktop.background picture-options "zoom"
  gs org.gnome.desktop.background primary-color   "$BREATH_BG"
  gs org.gnome.desktop.background secondary-color "$BREATH_BG"
  gsettings set org.gnome.desktop.screensaver picture-uri      "$uri" 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver picture-uri-dark "$uri" 2>/dev/null || true
  ok "papel de parede aplicado: $(wallpaper_name "$(basename "$target")")"
  return 0
}

green_xml=""
bamboo_xml=""
first_xml=""
count=0

if [[ ! -d "$WP_SRC_DIR" ]]; then
  warn "não achei a pasta $WP_SRC_DIR (pulei)"
else
  shopt -s nullglob nocaseglob
  for src in "$WP_SRC_DIR"/*.{png,jpg,jpeg,webp,avif}; do
    file="$(basename "$src")"
    dst="$WP_DST_DIR/$file"
    slug="$(wallpaper_slug "$file")"
    xml="$WP_XML_DIR/omakuba-$slug.xml"
    name="$(wallpaper_name "$file")"
    count=$((count + 1))

    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
      skip "já instalado: $file"
    else
      run_quiet "instalando $file" sudo install -Dm644 "$src" "$dst"
      ok "instalado: $dst"
    fi

    tmp_xml="$(mktemp)"
    cat >"$tmp_xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<!-- Papel de parede do omakuba. Gerado pelo script, nao edite a mao. -->
<wallpapers>
  <wallpaper deleted="false">
    <name>$(xml_escape "$name")</name>
    <filename>$dst</filename>
    <filename-dark>$dst</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>$BREATH_BG</pcolor>
    <scolor>$BREATH_BG</scolor>
  </wallpaper>
</wallpapers>
XML
    if [[ -f "$xml" ]] && cmp -s "$tmp_xml" "$xml"; then
      skip "já registrado: $name"
    else
      run_quiet "registrando $name" sudo install -Dm644 "$tmp_xml" "$xml"
      ok "$name aparece em Configurações > Aparência > Papel de parede"
    fi
    rm -f "$tmp_xml"

    [[ -z "$first_xml" ]] && first_xml="$xml"
    [[ "$slug" == green-forest* ]] && green_xml="$xml"
    [[ "$slug" == bamboo* ]] && bamboo_xml="$xml"
  done
  shopt -u nullglob nocaseglob

  if [[ "$count" -eq 0 ]]; then
    warn "não tem imagem em $WP_SRC_DIR (pulei)"
  fi
fi

chosen="${green_xml:-${bamboo_xml:-$first_xml}}"
if [[ -n "$chosen" ]]; then
  apply_wallpaper "$chosen" || warn "não consegui aplicar o wallpaper padrão"
fi

info "coloque mais imagens em dotfiles/backgrounds/ e rode ./install.sh 60-wallpapers"
info "os wallpapers do Bluefin e da Universal Blue entram no passo 65-bluefin-wallpapers"
