# 70-flatpaks
# O lado Flatpak do Bluefin: Flathub, Bazaar e os apps que dão personalidade
# ao sistema. Os apps do GNOME que o Ubuntu já traz como deb ficam como estão,
# para não aparecer tudo duplicado no menu.
#
# Para instalar também o conjunto completo de apps do GNOME em Flatpak:
#   OMAKUBA_FULL_FLATPAKS=1 ./install.sh 70-flatpaks

apt_install flatpak

if flatpak remote-list --user 2>/dev/null | grep '^flathub' >/dev/null; then
  skip "Flathub já está configurado"
else
  run_quiet "adicionando o Flathub" flatpak remote-add --if-not-exists --user flathub \
    https://flathub.org/repo/flathub.flatpakrepo \
    && ok "Flathub adicionado" \
    || warn "não consegui adicionar o Flathub (pulei)"
fi

if ! flatpak remote-list --user 2>/dev/null | grep '^flathub' >/dev/null; then
  warn "sem o Flathub eu não consigo instalar os apps (pulei)"
else
  run_quiet "atualizando o catálogo do Flatpak" flatpak update --user --appstream -y >/dev/null 2>&1 || true

  BASE_APPS=(
    be.alexandervanhee.gradia
    com.github.PintaProject.Pinta
    com.github.tchx84.Flatseal
    com.mattjakeman.ExtensionManager
    com.ranfdev.DistroShelf
    io.github.flattool.Ignition
    io.github.kolunmi.Bazaar
    io.gitlab.adhami3310.Impression
    io.missioncenter.MissionCenter
    page.tesk.Refine
    org.gtk.Gtk3theme.adw-gtk3
    org.gtk.Gtk3theme.adw-gtk3-dark
  )
  flatpak_install "${BASE_APPS[@]}"

  if [[ "${OMAKUBA_FULL_FLATPAKS:-0}" == "1" ]]; then
    FULL_APPS=(
      org.gnome.Calculator
      org.gnome.Calendar
      org.gnome.Characters
      org.gnome.Connections
      org.gnome.Contacts
      org.gnome.DejaDup
      org.gnome.FileRoller
      org.gnome.Firmware
      org.gnome.Logs
      org.gnome.Loupe
      org.gnome.Maps
      org.gnome.NautilusPreviewer
      org.gnome.Papers
      org.gnome.Showtime
      org.gnome.SimpleScan
      org.gnome.Snapshot
      org.gnome.Decibels
      org.gnome.TextEditor
      org.gnome.Weather
      org.gnome.baobab
      org.gnome.clocks
      org.gnome.font-viewer
      org.mozilla.firefox
      org.mozilla.thunderbird
    )
    flatpak_install "${FULL_APPS[@]}"
  fi
fi

info "o Bazaar, o Flatseal e o Extension Manager aparecem em Atividades."
info "se quiser o conjunto completo do GNOME em Flatpak: OMAKUBA_FULL_FLATPAKS=1 ./install.sh 70-flatpaks"
