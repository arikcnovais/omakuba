# ── 60-wallpapers ───────────────────────────────────────────────────────────
# Wallpapers dinâmicos do repo Chillsmeit/linux-dynamic-wallpapers — o mesmo
# instalador oficial (full-install-remote.sh), executado sem prompt interativo.
# Eles aparecem em Configurações › Fundo de tela e variam com o horário do dia.
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
  gsettings set org.gnome.desktop.screensaver picture-uri      "file://${target}" 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver picture-uri-dark "file://${target}" 2>/dev/null || true
  ok "wallpaper aplicado: $name"
  return 0
}

if [[ -d /usr/share/gnome-background-properties ]]; then
  chosen=""
  # Minimalistas primeiro (smooth/dark), os demais como plano B.
  for pref in BigSur Adwaita Fluent Aura ChromeDeepDarkPurple; do
    [[ -f "/usr/share/gnome-background-properties/${pref}.xml" ]] || continue
    if apply_wallpaper "$pref"; then chosen="$pref"; break; fi
  done
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