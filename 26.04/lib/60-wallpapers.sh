# 60-wallpapers
# Pega as imagens que você deixar em dotfiles/backgrounds/ e instala todas no
# sistema, criando o XML que faz cada uma aparecer em Configurações, Aparência,
# Papel de parede. Nenhum wallpaper é aplicado: o seu fica como está e você
# escolhe outro quando quiser. OMAKUBA_WALLPAPER é a única exceção, porque aí a
# escolha é explícita.

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
  elif [[ "$base" == [Ss]unrise* ]]; then
    printf 'Sunrise (Universal Blue)'
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
  done
  shopt -u nullglob nocaseglob

  if [[ "$count" -eq 0 ]]; then
    warn "não tem imagem em $WP_SRC_DIR (pulei)"
  fi
fi

# Não aplico nada por padrão: o papel de parede que já está configurado
# continua sendo o seu. A galeria nova fica só registrada, para escolher depois.
if [[ -n "${OMAKUBA_WALLPAPER:-}" ]]; then
  wp_override="$OMAKUBA_WALLPAPER"
  [[ -f "$wp_override" ]] || wp_override="$WP_DST_DIR/$OMAKUBA_WALLPAPER"
  [[ -f "$wp_override" ]] || wp_override="$WP_SRC_DIR/$OMAKUBA_WALLPAPER"
  [[ -f "$wp_override" ]] || wp_override="$WP_XML_DIR/$OMAKUBA_WALLPAPER"

  if [[ "$wp_override" == *.xml ]]; then
    wallpaper_apply_xml "$wp_override" \
      || warn "não consegui aplicar OMAKUBA_WALLPAPER=$OMAKUBA_WALLPAPER"
  elif [[ -f "$wp_override" ]]; then
    wallpaper_apply_image "$wp_override" \
      || warn "não consegui aplicar OMAKUBA_WALLPAPER=$OMAKUBA_WALLPAPER"
  else
    warn "OMAKUBA_WALLPAPER não existe: $OMAKUBA_WALLPAPER"
  fi
else
  current_uri=""
  if command -v gsettings >/dev/null 2>&1; then
    current_uri="$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null || true)"
  fi
  if [[ -n "$current_uri" && "$current_uri" != "''" ]]; then
    skip "mantive o seu papel de parede"
  else
    info "nenhum papel de parede aplicado; escolha um em Configurações > Aparência"
  fi
fi

info "os wallpapers aparecem em Configurações > Aparência > Papel de parede"
info "para aplicar um agora: OMAKUBA_WALLPAPER=/caminho/da/imagem ./install.sh 60-wallpapers"
info "os wallpapers do Bluefin e da Universal Blue entram no passo 65-bluefin-wallpapers"
