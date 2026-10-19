# 50-gnome
# O GNOME no estilo Bluefin, mas com o dock do jeito do Ubuntu: barra lateral
# esquerda, altura total e blur do Blur my Shell. O resto das extensões é o
# conjunto que o Bluefin usa no GNOME. No 24.04 o Forge continua como extra,
# para quem gosta do tiling em árvore.
#
# No Wayland, extensão recém-instalada só carrega depois de sair e entrar de
# novo. Por isso também gravo a lista no gsettings.

APPINDICATOR_UUID="ubuntu-appindicators@ubuntu.com"
DOCK_UUID="ubuntu-dock@ubuntu.com"
BLUR_UUID="blur-my-shell@aunetx"
VITALS_UUID="Vitals@CoreCoding.com"
CAFFEINE_UUID="caffeine@patapon.info"
GSCONNECT_UUID="gsconnect@andyholmes.github.io"
SEARCHLIGHT_UUID="search-light@icedman.github.com"
LOGOMENU_UUID="logomenu@aryan_k"
CUSTOMCMD_UUID="custom-command-list@storageb.github.com"
FORGE_UUID="forge@jmmaranan.com"

STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omakuba"
DOCK_DISABLED=0
[[ -f "$STATE_DIR/dock-disabled" ]] && DOCK_DISABLED=1

# O Ubuntu já traz o AppIndicator e o Dock. Se por algum motivo não estiverem,
# o pacote abaixo repõe os dois.
if ! ext_installed "$APPINDICATOR_UUID" || ! ext_installed "$DOCK_UUID"; then
  apt_install gnome-shell-ubuntu-extensions
fi

install_extension "4481"
install_extension "$BLUR_UUID"
install_extension "$VITALS_UUID"
install_extension "$CAFFEINE_UUID"
install_extension "$GSCONNECT_UUID"
install_extension "$SEARCHLIGHT_UUID"
install_extension "$LOGOMENU_UUID"
install_extension_git "$CUSTOMCMD_UUID" "StorageB/custom-command-menu" "main"

# O Bazaar Companion e a extensão do Gradia só existem para GNOME 49 ou mais
# novo. Os apps entram pelo Flatpak no passo 70.
skip "Bazaar Companion: só existe para GNOME 49 ou mais novo (pulei)"
skip "extensão do Gradia: sem build para o GNOME 46, o app entra no 70-flatpaks"

WANT=(
  "$APPINDICATOR_UUID"
  "$BLUR_UUID"
  "$VITALS_UUID"
  "$CAFFEINE_UUID"
  "$GSCONNECT_UUID"
  "$SEARCHLIGHT_UUID"
  "$LOGOMENU_UUID"
  "$CUSTOMCMD_UUID"
  "$FORGE_UUID"
)
[[ "$DOCK_DISABLED" -eq 0 ]] && WANT+=("$DOCK_UUID")

# O tiling-assistant do Ubuntu briga com o Forge.
DROP_LIST="tiling-assistant@ubuntu.com"
[[ "$DOCK_DISABLED" -eq 1 ]] && DROP_LIST="$DROP_LIST,$DOCK_UUID"

persist_extensions "$DROP_LIST" "${WANT[@]}"

for uuid in "${WANT[@]}"; do
  gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
done
# O tiling-assistant do Ubuntu fica desligado para não brigar com o Forge.
gnome-extensions disable "tiling-assistant@ubuntu.com" >/dev/null 2>&1 || true

# Visual: Adwaita puro, só ajeito alguns detalhes.
gs org.gnome.desktop.interface gtk-theme    "Adwaita-dark"
gs org.gnome.desktop.interface icon-theme   "Adwaita"
gs org.gnome.desktop.interface cursor-theme "Adwaita"
gs org.gnome.desktop.interface color-scheme "prefer-dark"
gs org.gnome.desktop.interface clock-show-weekday true
gs org.gnome.desktop.interface clock-show-date false
gs org.gnome.desktop.interface enable-hot-corners false

# Botões na direita, Num Lock ligado e janelas novas no centro.
gs org.gnome.desktop.wm.preferences button-layout "':minimize,maximize,close'"
gs org.gnome.desktop.peripherals.keyboard numlock-state true
gs org.gnome.mutter center-new-windows true
gs org.gnome.desktop.sound allow-volume-above-100-percent false

# Polimento do dia a dia: detalhes pequenos que deixam o desktop mais
# confortável, sem sair do Adwaita.
gs org.gnome.desktop.interface show-battery-percentage true
gs org.gnome.desktop.interface font-antialiasing "'rgba'"
gs org.gnome.desktop.interface font-hinting "'slight'"
gs org.gnome.desktop.calendar show-weekdate true
gs org.gnome.desktop.peripherals.touchpad tap-to-click true
gs org.gnome.desktop.wm.preferences action-middle-click-titlebar "'minimize'"
gs org.gnome.mutter check-alive-timeout 20000
ok "polimento: bateria, fontes, touchpad e janelas"

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

# Dock do Ubuntu: barra lateral esquerda, altura total, auto-hide e sem os
# ícones que eu não uso. O blur vem do Blur my Shell, mais abaixo.
if [[ "$DOCK_DISABLED" -eq 0 ]]; then
  DOCK="org.gnome.shell.extensions.dash-to-dock"
  gs $DOCK dock-position         "'LEFT'"
  gs $DOCK extend-height         true
  gs $DOCK dock-fixed            false
  gs $DOCK autohide              true
  gs $DOCK intellihide           true
  gs $DOCK show-trash            true
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
  gs $DOCK scroll-action         "'cycle-windows'"
  gs $DOCK apply-custom-theme    true
  gs $DOCK custom-background-color true
  gs $DOCK background-color      "'rgb(40,40,40)'"
  gs $DOCK custom-theme-shrink   true
  gs $DOCK force-straight-corner false
  gs $DOCK disable-overview-on-startup true
  ok "dock: barra lateral esquerda, altura total, auto-hide e blur"
else
  skip "dock desligado por vontade sua (omakuba dock on para voltar)"
fi

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

# Forge: gaps de 8px e uma borda discreta no teal do Breath.
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge window-gap-size 8
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge focus-border-size 2
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge focus-border-color "'rgba(26, 188, 156, 0.9)'"
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge split-border-toggle false
ext_gs "$FORGE_UUID" org.gnome.shell.extensions.forge primary-layout-mode "'tiling'"
ok "Forge: tiling com gaps de 8px"

# Search Light: Super+Space abre a busca no meio da tela, com o fundo escuro
# e o blur que o Bluefin usa.
if ext_installed "$SEARCHLIGHT_UUID"; then
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light shortcut-search "['<Super>space']"
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light scale-width 0.10
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light scale-height 0.15
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light border-thickness 1
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light border-radius 1.65
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light border-color "(0.23, 0.23, 0.23, 1.0)"
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light background-color "(0.0, 0.0, 0.0, 0.8)"
  ext_gs "$SEARCHLIGHT_UUID" org.gnome.shell.extensions.search-light blur-background true
  ok "Search Light: Super+Space"
fi

# Logo Menu: o menu do logo no canto esquerdo, com os comandos do dia a dia.
# O Bazaar, o Mission Center e o Extension Manager entram no passo 70-flatpaks.
if ext_installed "$LOGOMENU_UUID"; then
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu menu-button-terminal "'xdg-terminal-exec'"
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu menu-button-system-monitor "'flatpak run io.missioncenter.MissionCenter'"
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu menu-button-software-center "'flatpak run io.github.kolunmi.Bazaar'"
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu menu-button-extensions-app "'com.mattjakeman.ExtensionManager.desktop'"
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu show-activities-button false
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu show-power-options true
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu show-lockscreen true
  ext_gs "$LOGOMENU_UUID" org.gnome.shell.extensions.logo-menu menu-button-icon-size 25
  ok "Logo Menu: terminal, Bazaar, Mission Center e ajustes"
fi

# Custom Command Menu: comandos rápidos na direita da barra. No Bluefin ele
# fica no lugar do menu de logo; aqui os dois convivem, um de cada lado.
if ext_installed "$CUSTOMCMD_UUID"; then
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list menuoptions-setting 2
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list menuicon-setting "'system-run-symbolic'"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list menulocation-setting 2
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list menuposition-setting 0
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command-order "[1, 2, 3, 4, 5, 6, 7, 8]"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command1 "('Terminal', 'xdg-terminal-exec', 'utilities-terminal-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command2 "('Arquivos', 'nautilus --new-window', 'system-file-manager-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command3 "('Bazaar', 'flatpak run io.github.kolunmi.Bazaar', 'system-software-install-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command4 "('Monitor do sistema', 'flatpak run io.missioncenter.MissionCenter', 'utilities-system-monitor-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command5 "('Configurações', 'gnome-control-center', 'preferences-system-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command6 "('Extensões', 'flatpak run com.mattjakeman.ExtensionManager', 'application-x-addon-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command7 "('Sobre o sistema', 'gnome-control-center system about', 'help-about-symbolic', true)"
  ext_gs "$CUSTOMCMD_UUID" org.gnome.shell.extensions.custom-command-list command8 "('Atualizar apps', '$HOME/.local/bin/omakuba update', 'software-update-available-symbolic', true)"
  ok "Custom Command Menu: comandos rápidos na direita da barra"
fi

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

# Atalhos do Bluefin, com o terminal do sistema no Ctrl+Alt+T.
gs org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gs org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gs org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gs org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gs org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gs org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"
# O Super+Space fica para o Search Light; o layout de teclado usa Shift+Super.
gs org.gnome.desktop.wm.keybindings switch-input-source "['<Shift><Super>space']"
gs org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

CB_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CB_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# O projeto já se chamou omadev. Se sobrou o atalho antigo, removo.
LEGACY_CB="$CB_BASE/omadev-kitty/"
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

add_custom() { # slug nome comando atalho
  local slug="$1" name="$2" cmd="$3" binding="$4"
  local path="$CB_BASE/$slug/" current
  current="$(gsettings get $CB_SCHEMA custom-keybindings 2>/dev/null || echo '@as []')"
  if [[ "$current" != *"$path"* ]]; then
    if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
      current="['$path']"
    else
      current="${current%]}, '$path']"
    fi
    gsettings set $CB_SCHEMA custom-keybindings "$current" 2>/dev/null || true
  fi
  gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path" name "$name" 2>/dev/null || true
  gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path" command "$cmd" 2>/dev/null || true
  gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path" binding "$binding" 2>/dev/null || true
}

add_custom "omakuba-kitty"        "Kitty (omakuba)"        "kitty"        "<Super>Return"
add_custom "omakuba-terminal"     "Terminal"               "xdg-terminal-exec" "<Control><Alt>t"
add_custom "omakuba-terminal-alt" "Terminal alternativo"   "xdg-terminal-exec" "<Control><Alt>Return"
add_custom "omakuba-files"        "Arquivos"               "nautilus --new-window" "<Super>e"
add_custom "omakuba-monitor"      "Monitor do sistema"     "flatpak run io.missioncenter.MissionCenter" "<Control><Shift>Escape"
ok "atalhos: Super+Return, Ctrl+Alt+T, Ctrl+Alt+Return, Super+E e Ctrl+Shift+Esc"

# Favoritos do dock. Só entra o que está instalado, para não ficar buraco.
desktop_exists() {
  local id="$1"
  [[ -f "/usr/share/applications/$id" ]] && return 0
  [[ -f "/var/lib/snapd/desktop/applications/$id" ]] && return 0
  [[ -f "/var/lib/flatpak/exports/share/applications/$id" ]] && return 0
  [[ -f "$HOME/.local/share/flatpak/exports/share/applications/$id" ]] && return 0
  return 1
}

FAVORITES=()
add_fav() { if desktop_exists "$1"; then FAVORITES+=("$1"); fi; return 0; }

if desktop_exists "firefox_firefox.desktop"; then add_fav "firefox_firefox.desktop"
elif desktop_exists "firefox.desktop"; then add_fav "firefox.desktop"; fi
if desktop_exists "thunderbird_thunderbird.desktop"; then add_fav "thunderbird_thunderbird.desktop"
elif desktop_exists "thunderbird.desktop"; then add_fav "thunderbird.desktop"; fi
add_fav "org.gnome.Nautilus.desktop"
add_fav "io.github.kolunmi.Bazaar.desktop"
if desktop_exists "kitty.desktop"; then add_fav "kitty.desktop"
elif desktop_exists "org.gnome.Ptyxis.desktop"; then add_fav "org.gnome.Ptyxis.desktop"; fi
if desktop_exists "code.desktop"; then add_fav "code.desktop"
elif desktop_exists "code_code.desktop"; then add_fav "code_code.desktop"; fi
add_fav "io.missioncenter.MissionCenter.desktop"
add_fav "com.mattjakeman.ExtensionManager.desktop"

if [[ ${#FAVORITES[@]} -gt 0 ]]; then
  gv="[" first=1
  for f in "${FAVORITES[@]}"; do
    (( first )) || gv+=", "
    gv+="'$f'"
    first=0
  done
  gv+="]"
  gsettings set org.gnome.shell favorite-apps "$gv"
  ok "favoritos do dock: ${FAVORITES[*]}"
fi

warn "as extensões do GNOME só entram no ar depois de sair e entrar de novo."
