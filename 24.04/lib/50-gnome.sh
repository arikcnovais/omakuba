# 50-gnome
# Deixo o GNOME com cara de i3, mas com o Adwaita puro.
# Uso Forge para o tiling, Blur my Shell para o fundo, Vitals para as métricas
# e Caffeine para o notebook não dormir no meio de um build.
# No Wayland, extensão recém-instalada só carrega depois de sair e entrar de
# novo. Por isso também gravo a lista no gsettings.

FORGE_UUID="forge@jmmaranan.com"
BLUR_UUID="blur-my-shell@aunetx"
VITALS_UUID="Vitals@CoreCoding.com"
CAFFEINE_UUID="caffeine@patapon.info"

install_extension "4481"
install_extension "$BLUR_UUID"
install_extension "$VITALS_UUID"
install_extension "$CAFFEINE_UUID"

persist_extensions() {
  local want=("$FORGE_UUID" "$BLUR_UUID" "$VITALS_UUID" "$CAFFEINE_UUID")
  local enabled=() e
  while IFS= read -r e; do
    [[ -n "$e" ]] && enabled+=("$e")
  done < <(gnome-extensions list --enabled 2>/dev/null)

  for e in "${want[@]}"; do
    [[ -d "$HOME/.local/share/gnome-shell/extensions/$e" ]] || continue
    printf '%s\n' "${enabled[@]}" | grep -qxF "$e" || enabled+=("$e")
  done

  # O tiling-assistant do Ubuntu briga com o Forge, então tiro ele da lista.
  local final=()
  for e in "${enabled[@]}"; do
    [[ "$e" == "tiling-assistant@ubuntu.com" ]] && continue
    final+=("$e")
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
persist_extensions

for uuid in "$FORGE_UUID" "$BLUR_UUID" "$VITALS_UUID" "$CAFFEINE_UUID"; do
  gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
done
gnome-extensions disable "tiling-assistant@ubuntu.com" >/dev/null 2>&1 || true

# Visual: Adwaita puro, só ajeito alguns detalhes.
gs org.gnome.desktop.interface gtk-theme    "Adwaita-dark"
gs org.gnome.desktop.interface icon-theme   "Adwaita"
gs org.gnome.desktop.interface cursor-theme "Adwaita"
gs org.gnome.desktop.interface color-scheme "prefer-dark"
gs org.gnome.desktop.interface clock-show-weekday false
gs org.gnome.desktop.interface clock-show-date false
gs org.gnome.desktop.interface enable-hot-corners false

# Desktop limpo, só com o papel de parede.
gs org.gnome.shell.extensions.ding show-home false
gs org.gnome.shell.extensions.ding show-trash false

# Fonte monoespaçada do sistema. O grep com processo evita o pipefail reclamar.
if grep -qi "JetBrainsMono Nerd Font Mono" < <(fc-list 2>/dev/null); then
  gs org.gnome.desktop.interface monospace-font-name "'JetBrainsMono Nerd Font Mono 12'"
  ok "fonte monoespaçada: JetBrainsMono Nerd Font Mono 12"
else
  warn "não achei a Nerd Font, mantive a fonte do sistema"
fi

# Dock do Ubuntu: altura total, auto-hide e sem ícones que eu não uso.
DOCK="org.gnome.shell.extensions.dash-to-dock"
gs $DOCK dock-position         "'LEFT'"
gs $DOCK extend-height         true
gs $DOCK dock-fixed            false
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
ok "dock ajustado (altura total, bolinhas e 72% de opacidade)"

# Configuração das extensões. Leio o schema que vem dentro da pasta de cada
# uma, porque ele não fica instalado no sistema.
ext_gs() { # uuid schema chave valor
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || { warn "schema de '$1' ausente (ignorei)"; return 0; }
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings set "$2" "$3" "$4" 2>/dev/null \
    || warn "'$2' '$3': não apliquei"
}

# Diz se a chave existe no schema que vem junto da extensão.
ext_has_key() { # uuid schema chave
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || return 1
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings list-keys "$2" 2>/dev/null | grep -qxF "$3"
}

# Diz se existe um pipeline com esse nome. Nas versões antigas o Blur my Shell
# guarda os pipelines no schema geral dele.
blur_has_pipeline() { # uuid nome
  local dir="$HOME/.local/share/gnome-shell/extensions/$1"
  [[ -d "$dir/schemas" ]] || return 1
  GSETTINGS_SCHEMA_DIR="$dir/schemas" gsettings get org.gnome.shell.extensions.blur-my-shell pipelines 2>/dev/null \
    | grep -qF "'$2'"
}

# Forge: gaps de 8px e uma borda discreta no teal do Breath.
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge window-gap-size 8
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge focus-border-size 2
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge focus-border-color "'rgba(26, 188, 156, 0.9)'"
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge split-border-toggle false
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge primary-layout-mode "'tiling'"
ok "Forge: tiling com gaps de 8px"

# Blur my Shell: barra, dock, visão geral e popups. Sem blur nas janelas.
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell sigma 24
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell brightness 0.55
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.panel blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.panel static-blur true
# No dock eu não quero o pipeline com cantos arredondados. Nas versões novas
# da extensão o dock usa um pipeline, então aponto para o padrão. Se a versão
# instalada não tiver essa opção, desligo o blur do dock.
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
if ext_has_key "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline; then
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock pipeline "'pipeline_default'"
else
  warn "Blur my Shell antigo: desliguei o blur do dock"
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur false
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur false
fi
# Popups: quero os cantos arredondados, senão fica quadrado e com uns encaixes
# estranhos. Nas versões que têm o pipeline "Default rounded" aponto para ele.
# Nas mais novas, que arredondam por chave, rounded-corners 0 quer dizer
# "os quatro cantos" e o raio vem de corner-radius.
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup blur true
if blur_has_pipeline "$BLUR_UUID" "pipeline_default_rounded"; then
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup pipeline "'pipeline_default_rounded'"
else
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup rounded-corners 0
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup corner-radius 18
fi
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.overview blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.applications blur false
ok "Blur my Shell: barra e visão geral com blur, dock reto e popups arredondados"

# Vitals: só CPU, memória, disco e rede.
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
ok "Vitals: CPU, memória, disco e rede"

# Workspaces fixos, como no i3. Super+1..5 troca, com Shift manda a janela.
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings set org.gnome.shell.keybindings "switch-to-application-$i" "[]" 2>/dev/null || true
done
for i in 1 2 3 4 5; do
  gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "['<Super>$i']" 2>/dev/null || true
  gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$i" "['<Super><Shift>$i']" 2>/dev/null || true
done
gs org.gnome.desktop.wm.preferences num-workspaces 5
gs org.gnome.mutter dynamic-workspaces false
ok "5 workspaces fixos: Super+1..5 e Super+Shift+1..5"

# Super+Return abre o Kitty.
CB_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/omakuba-kitty/"

# O projeto já se chamou omadev. Se sobrou o atalho antigo, removo.
LEGACY_CB="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/omadev-kitty/"
current="$(gsettings get $CB_SCHEMA custom-keybindings)"
if [[ "$current" == *"$LEGACY_CB"* ]]; then
  current="${current//\'$LEGACY_CB\', /}"
  current="${current//, \'$LEGACY_CB\'/}"
  current="${current//\'$LEGACY_CB\'/}"
  [[ -z "${current//[[:space:]]/}" || "$current" == "[]" ]] && current="[]"
  gsettings set $CB_SCHEMA custom-keybindings "$current" 2>/dev/null || true
  dconf reset -f "$LEGACY_CB" 2>/dev/null || true
  ok "atalho antigo do omadev removido"
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
ok "Super+Return abre o Kitty"

# Favoritos do dock.
if [[ -f /usr/share/applications/kitty.desktop ]]; then
  gs org.gnome.shell favorite-apps \
    "['firefox_firefox.desktop', 'code_code.desktop', 'kitty.desktop', 'postman_postman.desktop', 'org.gnome.Nautilus.desktop']"
  ok "dock com poucos favoritos"
fi

warn "as extensões do GNOME só entram no ar depois de sair e entrar de novo."
