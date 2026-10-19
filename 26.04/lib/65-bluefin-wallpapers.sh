# 65-bluefin-wallpapers
# Baixa os wallpapers do Bluefin e da Universal Blue direto do repositório
# ublue-os/artwork. Eles entram na mesma pasta do omakuba e aparecem em
# Configurações > Aparência > Papel de parede. No fim, o Sunrise da Universal
# Blue vira o padrão; o green forest fica de reserva no passo 60.

WP_SRC_DIR="${WP_SRC_DIR:-$DOTFILES_DIR/backgrounds}"
WP_DST_DIR="${WP_DST_DIR:-/usr/share/backgrounds/omakuba}"
WP_XML_DIR="${WP_XML_DIR:-/usr/share/gnome-background-properties}"
WP_CACHE_DIR="${WP_CACHE_DIR:-$HOME/.cache/omakuba/wallpapers}"
ART_BASE="https://raw.githubusercontent.com/ublue-os/artwork/main/wallpapers"

mkdir -p "$WP_CACHE_DIR"

# download_wp <caminho-no-repo> <arquivo-local>
download_wp() {
  local remote="$1" local_file="$2" part="$2.part"
  if [[ -s "$local_file" ]]; then
    skip "já baixado: $(basename "$local_file")"
    return 0
  fi
  mkdir -p "$(dirname "$local_file")"
  if run_quiet "baixando $(basename "$local_file")" fetch "$ART_BASE/$remote" "$part"; then
    mv "$part" "$local_file"
    ok "baixado: $(basename "$local_file")"
  else
    warn "não baixei '$remote' (pulei)"
    rm -f "$part"
    return 1
  fi
}

# install_wp <arquivo-local> <subpasta>
install_wp() {
  local src="$1" sub="$2"
  local dst="$WP_DST_DIR/$sub/$(basename "$src")"
  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    skip "já instalado: $dst"
    return 0
  fi
  run_quiet "instalando $(basename "$src")" sudo install -Dm644 "$src" "$dst" \
    && ok "instalado: $dst" \
    || warn "não instalei $(basename "$src")"
}

# write_xml <nome> <arquivo-dia> <arquivo-noite-ou-vazio> <slug>
write_xml() {
  local name="$1" day="$2" night="$3" slug="$4"
  local xml="$WP_XML_DIR/omakuba-$slug.xml"
  local tmp; tmp="$(mktemp)"
  {
    printf '<?xml version="1.0" encoding="UTF-8"?>\n'
    printf '<!-- Papel de parede do omakuba. Gerado pelo script, nao edite a mao. -->\n'
    printf '<wallpapers>\n  <wallpaper deleted="false">\n'
    printf '    <name>%s</name>\n' "$name"
    printf '    <filename>%s</filename>\n' "$day"
    if [[ -n "$night" ]]; then
      printf '    <filename-dark>%s</filename-dark>\n' "$night"
    else
      printf '    <filename-dark>%s</filename-dark>\n' "$day"
    fi
    printf '    <options>zoom</options>\n'
    printf '    <shade_type>solid</shade_type>\n'
    printf '    <pcolor>#000000</pcolor>\n'
    printf '    <scolor>#000000</scolor>\n'
    printf '  </wallpaper>\n</wallpapers>\n'
  } > "$tmp"
  if [[ -f "$xml" ]] && cmp -s "$tmp" "$xml"; then
    skip "já registrado: $name"
  else
    run_quiet "registrando $name" sudo install -Dm644 "$tmp" "$xml" \
      && ok "$name aparece em Configurações > Aparência > Papel de parede" \
      || warn "não registrei $name"
  fi
  rm -f "$tmp"
}

# Bluefin: 12 pares dia/noite. O 11 é SVG, o resto é JXL, e o GNOME lê os dois.
for n in 01 02 03 04 05 06 07 08 09 10 11 12; do
  ext="jxl"
  [[ "$n" == "11" ]] && ext="svg"
  day="$WP_CACHE_DIR/bluefin/$n-bluefin-day.$ext"
  night="$WP_CACHE_DIR/bluefin/$n-bluefin-night.$ext"
  if download_wp "bluefin/images/$n-bluefin-day.$ext" "$day" \
     && download_wp "bluefin/images/$n-bluefin-night.$ext" "$night"; then
    install_wp "$day" "bluefin"
    install_wp "$night" "bluefin"
    write_xml "Bluefin $n" \
      "$WP_DST_DIR/bluefin/$(basename "$day")" \
      "$WP_DST_DIR/bluefin/$(basename "$night")" \
      "bluefin-$n"
  fi
done

# Universal Blue: os wallpapers que aparecem nas outras edições. A maioria é
# SVG, então baixa rápido. Dusk, Huntress e Lazy Days só têm JXL.
ublue_pair() { # slug dir nome ext
  local slug="$1" dir="$2" name="$3" ext="${4:-svg}"
  local day="$WP_CACHE_DIR/universal-blue/$slug-day.$ext"
  local night="$WP_CACHE_DIR/universal-blue/$slug-night.$ext"
  if download_wp "$dir/$slug-day.$ext" "$day" \
     && download_wp "$dir/$slug-night.$ext" "$night"; then
    install_wp "$day" "universal-blue"
    install_wp "$night" "universal-blue"
    write_xml "Universal Blue: $name" \
      "$WP_DST_DIR/universal-blue/$(basename "$day")" \
      "$WP_DST_DIR/universal-blue/$(basename "$night")" \
      "ublue-$slug"
  fi
}

ublue_single() { # slug dir arquivo nome
  local slug="$1" dir="$2" file="$3" name="$4"
  local src="$WP_CACHE_DIR/universal-blue/$file"
  if download_wp "$dir/$file" "$src"; then
    install_wp "$src" "universal-blue"
    write_xml "Universal Blue: $name" \
      "$WP_DST_DIR/universal-blue/$file" "" "ublue-$slug"
  fi
}

ublue_pair "cloud-dancer"        "cloud-dancer"        "Cloud Dancer"
ublue_pair "collapse"            "collapse"            "Collapse"
ublue_pair "duality"             "duality"             "Duality"
ublue_pair "leaf-collector"      "leaf-collector"      "Leaf Collector"
ublue_pair "prey"                "prey"                "Prey"
ublue_pair "sunrise"             "sunrise"             "Sunrise"
ublue_pair "tenacious-pterosaur" "tenacious-pterosaur" "Tenacious Pterosaur"
ublue_pair "dusk"                "dusk"                "Dusk" "jxl"

ublue_single "eyes"      "eyes"      "eyes.svg"      "Eyes"
ublue_single "huntress"  "huntress"  "huntress.jxl"  "Huntress"
ublue_single "lazy-days" "lazy-days" "lazy-days.jxl" "Lazy Days"

sunrise_xml="$WP_XML_DIR/omakuba-ublue-sunrise.xml"

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
elif [[ -f "$sunrise_xml" ]]; then
  wallpaper_apply_xml "$sunrise_xml" \
    && ok "padrão aplicado: Universal Blue: Sunrise" \
    || warn "não consegui aplicar o Sunrise"
fi

info "os wallpapers do Bluefin e da Universal Blue ficam em $WP_DST_DIR."
info "o padrão é o Sunrise da Universal Blue; o green forest fica de reserva."
info "para escolher outro: OMAKUBA_WALLPAPER=... ./install.sh 60-wallpapers"
info "o cache dos downloads fica em $WP_CACHE_DIR."
