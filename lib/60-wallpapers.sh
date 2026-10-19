# ── 60-wallpapers ───────────────────────────────────────────────────────────
# 1) O wallpaper do omakuba — Bamboo — versionado em dotfiles/backgrounds/,
#    instalado no sistema e registrado para aparecer nas Configurações.
# 2) O pack de wallpapers dinâmicos do repo Chillsmeit/linux-dynamic-wallpapers,
#    via instalador oficial (full-install-remote.sh), executado sem prompt
#    interativo. Tudo aparece em Configurações › Fundo de tela.
WP_DIR="/usr/share/backgrounds/dynamic-wallpapers"

if [[ -d "$WP_DIR" ]] && [[ -n "$(ls -A "$WP_DIR" 2>/dev/null)" ]]; then
  ok "wallpapers dinâmicos já instalados"
else
  tmp="$(mktemp -d)"
  if fetch "https://raw.githubusercontent.com/Chillsmeit/linux-dynamic-wallpapers/main/full-install-remote.sh" "$tmp/full-install-remote.sh" 2>/dev/null; then
    # O instalador oficial pergunta via /dev/tty; damos uma PTY com "y".
    if printf 'y\n' | timeout 900 script -qec "bash $tmp/full-install-remote.sh" /dev/null >"$tmp/install.log" 2>&1; then
      ok "wallpapers dinâmicos instalados (instalador oficial)"
    else
      warn "instalador oficial falhou — usando método manual equivalente"
      rm -rf /tmp/linux-dynamic-wallpapers
      git clone --depth=1 https://github.com/Chillsmeit/linux-dynamic-wallpapers.git /tmp/linux-dynamic-wallpapers >/dev/null 2>&1 || true
      if [[ -d /tmp/linux-dynamic-wallpapers ]]; then
        sudo mkdir -p /usr/share/backgrounds/ /usr/share/gnome-background-properties/
        sudo cp -r /tmp/linux-dynamic-wallpapers/dynamic-wallpapers /usr/share/backgrounds/
        sudo cp /tmp/linux-dynamic-wallpapers/xml/* /usr/share/gnome-background-properties/
        rm -rf /tmp/linux-dynamic-wallpapers
        ok "wallpapers instalados (método manual oficial)"
      else
        warn "não foi possível obter os wallpapers (ignorado)"
      fi
    fi
  else
    warn "download do instalador falhou (ignorado)"
  fi
  rm -rf "$tmp"
fi

# Aplica um wallpaper dark e minimal como padrão (claro e escuro).
apply_wallpaper() {
  local name="$1"
  local prop="/usr/share/gnome-background-properties/${name}.xml"
  [[ -f "$prop" ]] || return 1
  # O descriptor traz o caminho ABSOLUTO do wallpaper dinâmico (XML do GNOME).
  local target
  target="$(sed -n 's:.*<filename>\([^<]*\)</filename>.*:\1:p' "$prop" | head -1)"
  [[ -n "$target" && -e "$target" ]] || return 1
  gsettings set org.gnome.desktop.background picture-uri      "file://${target}"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${target}"
  gs org.gnome.desktop.background picture-options "zoom"
  # Cor de fundo/transição na cor do Breath (o papel de parede é sólido).
  gs org.gnome.desktop.background primary-color   "#1e2229"
  gs org.gnome.desktop.background secondary-color "#1e2229"
  gsettings set org.gnome.desktop.screensaver picture-uri      "file://${target}" 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver picture-uri-dark "file://${target}" 2>/dev/null || true
  ok "wallpaper aplicado: $name"
  return 0
}

# ── Bamboo: o wallpaper do omakuba ──────────────────────────────────────────
# O original vive versionado em dotfiles/backgrounds/. Instalamos no sistema e
# criamos o descriptor que faz ele APARECER em Configurações › Aparência ›
# Fundo de tela (com fundo sólido na cor do Breath).
BAMBOO_SRC="$ROOT/dotfiles/backgrounds/Bamboo_wallpaper.png"
BAMBOO_DST="/usr/share/backgrounds/omakuba/Bamboo_wallpaper.png"
BAMBOO_XML="/usr/share/gnome-background-properties/omakuba-bamboo.xml"

if [[ -f "$BAMBOO_SRC" ]]; then
  if [[ -f "$BAMBOO_DST" ]] && cmp -s "$BAMBOO_SRC" "$BAMBOO_DST"; then
    skip "Bamboo já instalado no sistema"
  else
    sudo install -Dm644 "$BAMBOO_SRC" "$BAMBOO_DST"
    ok "Bamboo instalado em $BAMBOO_DST"
  fi

  tmp_xml="$(mktemp)"
  cat >"$tmp_xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<!-- Wallpaper do omakuba (Bamboo). Editado por lib/60-wallpapers.sh — não mexa à mão. -->
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
    skip "Bamboo já aparece nas Configurações"
  else
    sudo install -Dm644 "$tmp_xml" "$BAMBOO_XML"
    ok "Bamboo aparece em Configurações › Aparência › Fundo de tela"
  fi
  rm -f "$tmp_xml"
else
  warn "dotfiles/backgrounds/Bamboo_wallpaper.png ausente (ignorado)"
fi

if [[ -d /usr/share/gnome-background-properties ]]; then
  chosen=""
  # 1º o Bamboo (wallpaper do omakuba); se faltar, os minimalistas do pack.
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
      apply_wallpaper "$(basename "$first_xml" .xml)" || warn "nenhum wallpaper aplicado automaticamente"
    fi
  fi
else
  skip "sem propriedades de wallpaper — nada a aplicar"
fi

info "mais wallpapers: Configurações › Fundo de tela"