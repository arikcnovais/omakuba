# 85-updates
# Deixa o comando omakuba no PATH e liga o timer semanal que atualiza Flatpak
# e Homebrew sem precisar de sudo.

SRC="$DOTFILES_DIR/bin/omakuba"
DST="$HOME/.local/bin/omakuba"
mkdir -p "$(dirname "$DST")"

if [[ -f "$SRC" ]]; then
  if [[ -f "$DST" ]] && cmp -s "$SRC" "$DST"; then
    skip "o comando omakuba já está atualizado"
  else
    install -Dm755 "$SRC" "$DST"
    ok "comando omakuba instalado em $DST"
  fi
else
  warn "não achei $SRC (pulei)"
fi

UNIT_SRC="$DOTFILES_DIR/systemd/user"
UNIT_DST="$HOME/.config/systemd/user"
mkdir -p "$UNIT_DST"

for unit in omakuba-update.service omakuba-update.timer; do
  if [[ -f "$UNIT_SRC/$unit" ]]; then
    if [[ -f "$UNIT_DST/$unit" ]] && cmp -s "$UNIT_SRC/$unit" "$UNIT_DST/$unit"; then
      skip "$unit já está atualizado"
    else
      install -Dm644 "$UNIT_SRC/$unit" "$UNIT_DST/$unit"
      ok "$unit instalado"
    fi
  fi
done

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload >/dev/null 2>&1 || true
  if systemctl --user enable --now omakuba-update.timer >/dev/null 2>&1; then
    ok "timer semanal do omakuba ligado"
  else
    warn "não consegui ligar o timer (o comando omakuba update funciona na mão)"
  fi
else
  warn "systemctl não existe, então não liguei o timer"
fi

info "atualizar na mão: omakuba update"
info "atualizar o sistema também: omakuba update --system"
