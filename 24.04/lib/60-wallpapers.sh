# 60-wallpapers
# Coloco o Bamboo como papel de parede padrão e instalo o pack de wallpapers
# dinâmicos do projeto Chillsmeit/linux-dynamic-wallpapers.
WP_DIR="/usr/share/backgrounds/dynamic-wallpapers"

if [[ -d "$WP_DIR" ]] && [[ -n "$(ls -A "$WP_DIR" 2>/dev/null)" ]]; then
  ok "os wallpapers dinâmicos já estão instalados"
else
  tmp="$(mktemp -d)"
  if run_quiet "baixando o instalador de wallpapers" fetch \
    "https://raw.githubusercontent.com/Chillsmeit/linux-dynamic-wallpapers/main/full-install-remote.sh" \
    "$tmp/full-install-remote.sh"; then
    # O instalador oficial pergunta no /dev/tty, então dou um "y" por uma PTY.
    # Isso pode demorar, por isso o spinner.
    if run_quiet "instalando os wallpapers dinâmicos (pode demorar)" \
         bash -c "printf 'y\n' | timeout 900 script -qec 'bash $tmp/full-install-remote.sh' /dev/null"; then
      ok "wallpapers dinâmicos instalados"
    else
      warn "o instalador oficial falhou, vou pelo caminho manual"
      rm -rf /tmp/linux-dynamic-wallpapers
      run_quiet "baixando os wallpapers do GitHub" git clone --depth=1 \
        https://github.com/Chillsmeit/linux-dynamic-wallpapers.git /tmp/linux-dynamic-wallpapers \
        || true
      if [[ -d /tmp/linux-dynamic-wallpapers ]]; then
        run_quiet "copiando os wallpapers" sudo mkdir -p /usr/share/backgrounds/ /usr/share/gnome-background-properties/
        run_quiet "copiando os wallpapers" sudo cp -r /tmp/linux-dynamic-wallpapers/dynamic-wallpapers /usr/share/backgrounds/
        run_quiet "copiando os wallpapers" sudo cp /tmp/linux-dynamic-wallpapers/xml/* /usr/share/gnome-background-properties/
        rm -rf /tmp/linux-dynamic-wallpapers
        ok "wallpapers instalados do jeito manual"
      else
        warn "não consegui baixar os wallpapers (pulei)"
      fi
    fi
  else
    warn "o download do instalador falhou (pulei)"
  fi
  rm -rf "$tmp"
fi

apply_wallpaper() {
  local name="$1"
  local prop="/usr/share/gnome-background-properties/${name}.xml"
  [[ -f "$prop" ]] || return 1

  local target
  target="$(sed -n 's:.*<filename>\([^<]*\)</filename>.*:\1:p' "$prop" | head -1)"
  [[ -n "$target" && -e "$target" ]] || return 1

  gsettings set org.gnome.desktop.background picture-uri      "file://${target}"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${target}"
  gs org.gnome.desktop.background picture-options "zoom"
  gs org.gnome.desktop.background primary-color   "#1e2229"
  gs org.gnome.desktop.background secondary-color "#1e2229"
  gsettings set org.gnome.desktop.screensaver picture-uri      "file://${target}" 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver picture-uri-dark "file://${target}" 2>/dev/null || true
  ok "papel de parede aplicado: $name"
  return 0
}

# Bamboo: o wallpaper do projeto. O arquivo original fica em dotfiles/,
# copio para o sistema e crio o XML que faz ele aparecer nas Configurações.
BAMBOO_SRC="$DOTFILES_DIR/backgrounds/Bamboo_wallpaper.png"
BAMBOO_DST="/usr/share/backgrounds/omakuba/Bamboo_wallpaper.png"
BAMBOO_XML="/usr/share/gnome-background-properties/omakuba-bamboo.xml"

if [[ -f "$BAMBOO_SRC" ]]; then
  if [[ -f "$BAMBOO_DST" ]] && cmp -s "$BAMBOO_SRC" "$BAMBOO_DST"; then
    skip "o Bamboo já está no sistema"
  else
    run_quiet "instalando o Bamboo" sudo install -Dm644 "$BAMBOO_SRC" "$BAMBOO_DST"
    ok "Bamboo copiado para $BAMBOO_DST"
  fi

  tmp_xml="$(mktemp)"
  cat >"$tmp_xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<!-- Papel de parede do omakuba (Bamboo). Gerado pelo script, não edite à mão. -->
<wallpapers>
  <wallpaper deleted="false">
    <name>Bamboo (omakuba)</name>
    <filename>/usr/share/backgrounds/omakuba/Bamboo_wallpaper.png</filename>
    <filename-dark>/usr/share/backgrounds/omakuba/Bamboo_wallpaper.png</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#1e2229</pcolor>
    <scolor>#1e2229</scolor>
  </wallpaper>
</wallpapers>
XML
  if [[ -f "$BAMBOO_XML" ]] && cmp -s "$tmp_xml" "$BAMBOO_XML"; then
    skip "o Bamboo já aparece nas Configurações"
  else
    run_quiet "registrando o Bamboo nas Configurações" sudo install -Dm644 "$tmp_xml" "$BAMBOO_XML"
    ok "Bamboo disponível em Configurações > Aparência > Papel de parede"
  fi
  rm -f "$tmp_xml"
else
  warn "não achei dotfiles/backgrounds/Bamboo_wallpaper.png (pulei)"
fi

if [[ -d /usr/share/gnome-background-properties ]]; then
  chosen=""
  if apply_wallpaper "omakuba-bamboo"; then
    chosen="Bamboo (omakuba)"
  else
    for pref in BigSur Adwaita Fluent Aura ChromeDeepDarkPurple; do
      [[ -f "/usr/share/gnome-background-properties/${pref}.xml" ]] || continue
      if apply_wallpaper "$pref"; then chosen="$pref"; break; fi
    done
  fi
  if [[ -z "$chosen" ]]; then
    first_xml="$(ls /usr/share/gnome-background-properties/*.xml 2>/dev/null | head -1 || true)"
    if [[ -n "$first_xml" ]]; then
      apply_wallpaper "$(basename "$first_xml" .xml)" || warn "não consegui aplicar nenhum wallpaper"
    fi
  fi
else
  skip "não há propriedades de wallpaper, então não apliquei nada"
fi

info "tem mais opções em Configurações > Aparência > Papel de parede"
