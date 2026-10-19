# 50-gnome
# O GNOME no estilo Bluefin, mas com o dock do jeito do Ubuntu: barra lateral
# esquerda, altura total e blur do Blur my Shell. O resto das extensões é o
# conjunto que o Bluefin usa no GNOME.
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
BAZAAR_UUID="bazaar-integration@kolunmi.github.io"
ACCENT_DIRS_UUID="accent-directories@taiwbi.com"
LEGACY_THEME_UUID="legacyschemeautoswitcher@joshimukul29.gmail.com"
FORGE_UUID="forge@jmmaranan.com"

STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omakuba"
DOCK_DISABLED=0
[[ -f "$STATE_DIR/dock-disabled" ]] && DOCK_DISABLED=1

# O Ubuntu já traz o AppIndicator e o Dock. Se por algum motivo não estiverem,
# o pacote abaixo repõe os dois.
if ! ext_installed "$APPINDICATOR_UUID" || ! ext_installed "$DOCK_UUID"; then
  apt_install gnome-shell-ubuntu-extensions
fi

install_extension "$BLUR_UUID"
install_extension "$VITALS_UUID"
install_extension "$CAFFEINE_UUID"
install_extension "$GSCONNECT_UUID"
# O extensions.gnome.org ainda entrega uma versão do Search Light que só
# declara suporte até o GNOME 49. O branch principal já suporta o 50.
install_extension_git "$SEARCHLIGHT_UUID" "icedman/search-light" "main"
install_extension "$LOGOMENU_UUID"
install_extension_git "$CUSTOMCMD_UUID" "StorageB/custom-command-menu" "main"
# O Bazaar Companion é o menu de contexto "ver no Bazaar". Ele só declara
# suporte a partir do GNOME 49.
install_extension_git "$BAZAAR_UUID" "bazaar-org/bazaar-companion" "main" "src"

# Accent Icons: as pastas acompanham a cor do acento. A extensão só existe
# para GNOME 47+, então no 24.04 (GNOME 46) eu pulo.
ACCENT_DIRS=0
shell_major="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | sed -n '1p' || true)"
if [[ -n "$shell_major" ]] && (( shell_major >= 47 )); then
  ACCENT_DIRS=1
  install_extension "$ACCENT_DIRS_UUID"
else
  skip "Accent Icons: só existe para GNOME 47+ (pulei)"
fi

# Legacy (GTK3) Theme Scheme Auto Switcher: segue o claro/escuro do sistema e
# troca o tema GTK3 entre adw-gtk3 e adw-gtk3-dark. Vai do GNOME 45 ao 51, então
# entra nas duas versões; não tem schema, é só instalar e ligar.
install_extension "$LEGACY_THEME_UUID"

# A extensão do Gradia não tem build para o GNOME 46 nem para o 50. O app entra
# pelo Flatpak no passo 70, então aqui só aviso.
skip "extensão do Gradia: sem build para o GNOME 50, o app entra no 70-flatpaks"

WANT=(
  "$APPINDICATOR_UUID"
  "$BLUR_UUID"
  "$VITALS_UUID"
  "$CAFFEINE_UUID"
  "$GSCONNECT_UUID"
  "$SEARCHLIGHT_UUID"
  "$LOGOMENU_UUID"
  "$CUSTOMCMD_UUID"
  "$BAZAAR_UUID"
  "$LEGACY_THEME_UUID"
)
[[ "$ACCENT_DIRS" -eq 1 ]] && WANT+=("$ACCENT_DIRS_UUID")
[[ "$DOCK_DISABLED" -eq 0 ]] && WANT+=("$DOCK_UUID")

DROP_LIST="$FORGE_UUID"
[[ "$DOCK_DISABLED" -eq 1 ]] && DROP_LIST="$DROP_LIST,$DOCK_UUID"

persist_extensions "$DROP_LIST" "${WANT[@]}"

for uuid in "${WANT[@]}"; do
  gnome-extensions enable "$uuid" >/dev/null 2>&1 || true
done
# Forge de uma instalação anterior: desligo para não ficar tiling pela metade.
gnome-extensions disable "$FORGE_UUID" >/dev/null 2>&1 || true

# adw-gtk3: deixa os apps GTK3 com a mesma cara dos apps libadwaita (o
# "Adwaita novo"). Não existe no apt do Ubuntu, então vem do release do GitHub
# direto para /usr/share/themes. Só precisa de sudo para escrever lá.
ADW_THEME="adw-gtk3-dark"
ADW_DIR="${THEMES_DIR:-/usr/share/themes}"

if [[ -d "$ADW_DIR/adw-gtk3" && -d "$ADW_DIR/adw-gtk3-dark" ]]; then
  skip "adw-gtk3 já está em $ADW_DIR"
else
  if apt-cache show adw-gtk3 >/dev/null 2>&1; then
    apt_install adw-gtk3 || warn "não instalei o adw-gtk3 pelo apt (tento o GitHub)"
  fi
  if [[ ! -d "$ADW_DIR/adw-gtk3" ]]; then
    adw_tmp="$(mktemp -d)"
    adw_tag="$(github_latest_tag lassekongo83/adw-gtk3 || true)"
    adw_url="https://github.com/lassekongo83/adw-gtk3/releases/download/${adw_tag}/adw-gtk3${adw_tag}.tar.xz"
    if [[ -n "$adw_tag" ]] && run_quiet "baixando o adw-gtk3" fetch "$adw_url" "$adw_tmp/adw.tar.xz"; then
      if sudo mkdir -p "$ADW_DIR" && sudo tar -xJf "$adw_tmp/adw.tar.xz" -C "$ADW_DIR"; then
        ok "adw-gtk3 instalado em $ADW_DIR"
      else
        warn "não consegui extrair o adw-gtk3 em $ADW_DIR (pulei)"
      fi
    else
      warn "não baixei o adw-gtk3 (pulei)"
    fi
    rm -rf "$adw_tmp"
  fi
fi

# Visual: Adwaita puro, só ajeito alguns detalhes.
if [[ -d "$ADW_DIR/$ADW_THEME" ]]; then
  gs org.gnome.desktop.interface gtk-theme "$ADW_THEME"
  ok "tema GTK3: $ADW_THEME (a cara do Adwaita nos apps antigos)"
else
  gs org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  warn "adw-gtk3 ausente; mantive o Adwaita-dark"
fi
gs org.gnome.desktop.interface icon-theme   "Adwaita"

# O mesmo tema para os snaps. Os apps em snap (Firefox, Thunderbird...) leem os
# temas do snap gtk-common-themes, que não traz o adw-gtk3. Instalo o
# adw-gtk3-theme e ligo o plug gtk-3-themes de cada app que usa o
# gtk-common-themes também nesse snap. A conexão com o gtk-common-themes fica,
# então ícones, sons e os outros temas continuam disponíveis.
if ! command -v snap >/dev/null 2>&1; then
  skip "snapd não está instalado (pulei o tema dos snaps)"
else
  snap_install adw-gtk3-theme || true
  if snap list adw-gtk3-theme >/dev/null 2>&1; then
    snap_changed=0
    while IFS= read -r plug; do
      [[ -n "$plug" ]] || continue
      if snap connections 2>/dev/null | grep -qE "[[:space:]]${plug}[[:space:]].*adw-gtk3-theme:gtk-3-themes"; then
        skip "$plug já vê o adw-gtk3"
        continue
      fi
      if run_quiet "ligando $plug ao adw-gtk3-theme" sudo snap connect "$plug" adw-gtk3-theme:gtk-3-themes; then
        ok "$plug agora vê o adw-gtk3"
        snap_changed=1
      else
        warn "não liguei $plug ao adw-gtk3-theme (pulei)"
      fi
    done < <(snap connections 2>/dev/null \
      | grep 'gtk-common-themes:gtk-3-themes' \
      | grep -oE '[a-zA-Z0-9@._-]+:gtk-3-themes' \
      | grep -v '^gtk-common-themes:' | sort -u || true)
    if [[ "$snap_changed" -eq 1 ]]; then
      ok "reabra os apps em snap para pegar o tema"
    fi
  fi
fi

# O painel "Ubuntu Desktop" das Configurações usa o ícone
# preferences-ubuntu-panel, que só existe no Yaru. Como o tema de ícones é o
# Adwaita, copio só esse ícone para o hicolor (que o Adwaita herda), sem
# aplicar o Yaru. Vai com os dois nomes para funcionar em qualquer versão do
# g-c-c.
YARU_PANEL_ICON="/usr/share/icons/Yaru/scalable/categories/preferences-ubuntu-panel-symbolic.svg"
HICOLOR_ROOT="${HICOLOR_DIR:-/usr/share/icons/hicolor}"
HICOLOR_CATEGORIES="$HICOLOR_ROOT/scalable/categories"
if [[ -f "$YARU_PANEL_ICON" ]]; then
  YARU_PANEL_CHANGED=0
  for name in preferences-ubuntu-panel-symbolic.svg preferences-ubuntu-panel.svg; do
    dst="$HICOLOR_CATEGORIES/$name"
    if [[ -f "$dst" ]] && cmp -s "$YARU_PANEL_ICON" "$dst"; then
      skip "ícone do painel Ubuntu já está em $dst"
    elif run_quiet "instalando o ícone do painel Ubuntu" sudo install -Dm644 "$YARU_PANEL_ICON" "$dst"; then
      ok "ícone do painel Ubuntu em $dst"
      YARU_PANEL_CHANGED=1
    else
      warn "não instalei o ícone do painel Ubuntu em $dst (pulei)"
    fi
  done
  if [[ "$YARU_PANEL_CHANGED" -eq 1 ]] && command -v gtk-update-icon-cache >/dev/null 2>&1; then
    sudo gtk-update-icon-cache -f -t "$HICOLOR_ROOT" >/dev/null 2>&1 || true
  fi
else
  skip "ícone preferences-ubuntu-panel não está no Yaru (pulei)"
fi

gs org.gnome.desktop.interface cursor-theme "Adwaita"
gs org.gnome.desktop.interface color-scheme "prefer-dark"
gs org.gnome.desktop.interface clock-show-weekday true
gs org.gnome.desktop.interface clock-show-date false
gs org.gnome.desktop.interface enable-hot-corners false

# O Bluefin usa o acento slate, e eu fico com ele. O GNOME 46 do 24.04 não tem
# essa chave, então no 24.04 nem tento.
if gsettings list-keys org.gnome.desktop.interface 2>/dev/null | grep -x "accent-color" >/dev/null; then
  gs org.gnome.desktop.interface accent-color "'slate'"
fi

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
# Popups: o pipeline "Default rounded" é o padrão, senão os cantos ficam
# quadrados e com uns encaixes estranhos. O blur_has_pipeline antigo checava a
# lista de pipelines personalizados e dava falso para os de fábrica, então agora
# eu só confiro se a chave existe e aponto direto para o rounded.
# Nas versões mais novas, que arredondam por chave, rounded-corners 0 quer dizer
# "os quatro cantos" e o raio vem de corner-radius.
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup blur true
if ext_has_key "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup pipeline; then
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup pipeline "'pipeline_default_rounded'"
else
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup rounded-corners 0
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup corner-radius 18
fi
# Blur estático: o fundo é capturado uma vez e reaproveitado, em vez de refazer
# o blur a cada frame. Fica mais leve e o popup não cintila ao abrir.
if ext_has_key "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup static-blur; then
  ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.popup static-blur true
fi
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.overview blur true
ext_gs "$BLUR_UUID" org.gnome.shell.extensions.blur-my-shell.applications blur false
ok "Blur my Shell: barra e visão geral com blur, dock reto e popups arredondados com blur estático"

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

if ext_installed "$BAZAAR_UUID"; then
  ok "Bazaar Companion: botão direito em app Flatpak abre no Bazaar"
fi

# Accent Icons: só as pastas mudam de cor; os ícones dos apps continuam no
# Adwaita. Para colorir os apps também, ligue change-app-colors nas preferências
# da extensão.
if [[ "$ACCENT_DIRS" -eq 1 ]] && ext_installed "$ACCENT_DIRS_UUID"; then
  ext_gs "$ACCENT_DIRS_UUID" org.gnome.shell.extensions.accent-directories change-app-colors false
  ok "Accent Icons: pastas acompanham a cor do acento"

  # Se a extensão já rodou alguma vez, ela instalou os temas coloridos no home.
  # Aí eu já deixo o icon-theme certo, para um rerun não ficar no Adwaita.
  accent_now="$(gsettings get org.gnome.desktop.interface accent-color 2>/dev/null | tr -d "'")"
  accent_theme="$(ext_get "$ACCENT_DIRS_UUID" org.gnome.shell.extensions.accent-directories "${accent_now:-slate}-theme" || true)"
  if [[ -n "$accent_theme" && -d "$HOME/.local/share/icons/$accent_theme" ]]; then
    gs org.gnome.desktop.interface icon-theme "$accent_theme"
    ok "ícones no tema do acento: $accent_theme"
  fi
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
if desktop_exists "org.gnome.Ptyxis.desktop"; then add_fav "org.gnome.Ptyxis.desktop"
elif desktop_exists "kitty.desktop"; then add_fav "kitty.desktop"; fi
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
