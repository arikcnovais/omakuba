# ── 50-gnome ────────────────────────────────────────────────────────────────
# GNOME minimal no estilo i3, preservando a essência do Yaru.
# Somente extensões modernas: tiling + blur + métricas + anti-suspensão.
# Obs.: no Wayland, extensões recém-instaladas só carregam após logout/login —
# por isso gravamos a lista de habilitadas direto no gsettings (persistente).

FORGE_UUID="forge@jmmaranan.com"
BLUR_UUID="blur-my-shell@aunetx"
VITALS_UUID="Vitals@CoreCoding.com"
CAFFEINE_UUID="caffeine@patapon.info"

# 1) Extensões (pk/uuid no extensions.gnome.org).
install_extension "4481"          # Forge — tiling estilo i3
install_extension "$BLUR_UUID"    # Blur my Shell — profundidade na barra/dock
install_extension "$VITALS_UUID"  # Vitals — CPU/RAM/rede/disco
install_extension "$CAFFEINE_UUID" # Caffeine — impede suspensão

# 2) Persistência: habilita as modernas e tira o tiling-assistant (conflita).
persist_extensions() {
  local want=("$FORGE_UUID" "$BLUR_UUID" "$VITALS_UUID" "$CAFFEINE_UUID")
  local enabled=() e
  while IFS= read -r e; do [[ -n "$e" ]] && enabled+=("$e"); done < <(gnome-extensions list --enabled 2>/dev/null)
  for e in "${want[@]}"; do
    [[ -d "$HOME/.local/share/gnome-shell/extensions/$e" ]] || continue
    printf '%s\n' "${enabled[@]}" | grep -qxF "$e" || enabled+=("$e")
  done
  local final=()
  for e in "${enabled[@]}"; do
    [[ "$e" == "tiling-assistant@ubuntu.com" ]] && continue
    final+=("$e")
  done
  local gv="[" first=1
  for e in "${final[@]}"; do
    (( first )) || gv+=", "
    gv+="'$e'"; first=0
  done
  gv+="]"
  gsettings set org.gnome.shell enabled-extensions "$gv"
  ok "extensões habilitadas: ${final[*]}"
}
persist_extensions

# Atalho imediato quando a extensão já está carregada (senão vale no login).
for uuid in "$FORGE_UUID" "$BLUR_UUID" "$VITALS_UUID" "$CAFFEINE_UUID"; do
  gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
done
gnome-extensions disable "tiling-assistant@ubuntu.com" >/dev/null 2>&1 || true

# 3) Visual — mantém Yaru, só ajuste fino.
gs org.gnome.desktop.interface gtk-theme    "Yaru-dark"
gs org.gnome.desktop.interface icon-theme   "Yaru"
gs org.gnome.desktop.interface cursor-theme "Yaru"
gs org.gnome.desktop.interface color-scheme "prefer-dark"
gs org.gnome.desktop.interface clock-show-weekday false
gs org.gnome.desktop.interface clock-show-date false
gs org.gnome.desktop.interface enable-hot-corners false
# Desktop limpo: só o wallpaper (sem ícones de casa/lixeira).
gs org.gnome.shell.extensions.ding show-home false
gs org.gnome.shell.extensions.ding show-trash false

# Fonte monoespaçada do sistema = Nerd Font (cuidado: grep -q + pipefail).
if grep -qi "JetBrainsMono Nerd Font Mono" < <(fc-list 2>/dev/null); then
  gs org.gnome.desktop.interface monospace-font-name "'JetBrainsMono Nerd Font Mono 12'"
  ok "fonte monoespaçada -> JetBrainsMono Nerd Font Mono 12"
else
  warn "Nerd Font não encontrada — mantendo a fonte do sistema"
fi

# 4) Dock do Ubuntu: dock clássico (altura total, sem "panel mode"),
#    flutuante só na aparência, auto-hide suave e sem lixo.
DOCK="org.gnome.shell.extensions.dash-to-dock"
gs $DOCK dock-position         "'LEFT'"
gs $DOCK extend-height         true     # altura total (visual clássico, não painel)
gs $DOCK dock-fixed            false    # esconde suavemente, não fica preso
gs $DOCK autohide              true
gs $DOCK intellihide           true
gs $DOCK show-trash            false
gs $DOCK show-mounts           false
gs $DOCK show-mounts-network   false
gs $DOCK dash-max-icon-size    40
gs $DOCK icon-size-fixed       true
gs $DOCK running-indicator-style "'DOTS'"
gs $DOCK show-apps-at-top      true
gs $DOCK show-show-apps-button true
gs $DOCK background-opacity    0.72
gs $DOCK transparency-mode     "'DYNAMIC'"
gs $DOCK click-action          "'minimize-or-previews'"
ok "Ubuntu Dock refinado (altura total, DOTS, 72% opacidade dinâmica)"

# 5) Extensões: configuração real via schema da própria extensão.
ext_gs() { # uuid schema chave valor
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || { warn "schema de '$1' ausente (ignorado)"; return 0; }
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings set "$2" "$3" "$4" 2>/dev/null \
    || warn "'$2' '$3': não aplicado"
}

# Forge — i3 de verdade: gaps de 8px, borda de foco discreta.
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge window-gap-size 8
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge focus-border-size 2
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge focus-border-color "'rgba(26, 188, 156, 0.9)'"   # teal do Breath
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge split-border-toggle false
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge primary-layout-mode "'tiling'"
ok "Forge: tiling com gaps 8px e borda de foco sutil"

# Blur my Shell — discreto: barra, dock, visão geral e popups.
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell sigma 24
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell brightness 0.55
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.panel blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.panel static-blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.overview blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.applications blur false
ok "Blur my Shell: blur sutil (sem blur em janelas — leve e profissional)"

# Vitals — só o essencial na barra (CPU, RAM, disco, rede).
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-processor true
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-memory    true
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-storage   true
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-network   true
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-temperature false
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-system    false
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-fan       false
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals show-voltage   false
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals hide-zeros     true
ext_gs "$VITALS_UUID" org.gnome.shell.extensions.vitals position-in-panel 2
ok "Vitals: CPU/RAM/disco/rede (sem ruído de sensores)"

# 6) Workspaces estilo i3 (fixos, 5): Super+1..5 troca, +Shift move.
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings set org.gnome.shell.keybindings "switch-to-application-$i" "[]" 2>/dev/null || true
done
for i in 1 2 3 4 5; do
  gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "['<Super>$i']" 2>/dev/null || true
  gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$i" "['<Super><Shift>$i']" 2>/dev/null || true
done
gs org.gnome.desktop.wm.preferences num-workspaces 5
gs org.gnome.mutter dynamic-workspaces false
ok "workspaces: 5 fixos, Super+1..5 / Super+Shift+1..5"

# 7) Super+Return abre o Kitty (atalho custom, com aspas corretas no GVariant).
CB_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/omakuba-kitty/"

# Migração: o projeto já se chamou "omadev" — remove o atalho antigo, se existir.
LEGACY_CB="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/omadev-kitty/"
current="$(gsettings get $CB_SCHEMA custom-keybindings)"
if [[ "$current" == *"$LEGACY_CB"* ]]; then
  current="${current//\'$LEGACY_CB\', /}"
  current="${current//, \'$LEGACY_CB\'/}"
  current="${current//\'$LEGACY_CB\'/}"
  [[ -z "${current//[[:space:]]/}" || "$current" == "[]" ]] && current="[]"
  gsettings set $CB_SCHEMA custom-keybindings "$current" 2>/dev/null || true
  dconf reset -f "$LEGACY_CB" 2>/dev/null || true
  ok "atalho antigo 'omadev-kitty' migrado"
fi

if ! gsettings get $CB_SCHEMA custom-keybindings | grep -q "omakuba-kitty"; then
  current="$(gsettings get $CB_SCHEMA custom-keybindings)"
  if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
    gsettings set $CB_SCHEMA custom-keybindings "['$CB_PATH']"
  else
    gsettings set $CB_SCHEMA custom-keybindings "${current%]}, '$CB_PATH']"
  fi
fi
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CB_PATH" name    "Kitty (omakuba)"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CB_PATH" command "kitty"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CB_PATH" binding "<Super>Return"
ok "Super+Return -> kitty"

# 8) Dock: favoritos enxutos (Firefox, Code, Kitty, Postman, Arquivos).
if [[ -f /usr/share/applications/kitty.desktop ]]; then
  gs org.gnome.shell favorite-apps \
    "['firefox_firefox.desktop', 'code_code.desktop', 'kitty.desktop', 'postman_postman.desktop', 'org.gnome.Nautilus.desktop']"
  ok "dock: favoritos enxutos"
fi

warn "extensões do GNOME entram em vigor após logout/login (Wayland)."