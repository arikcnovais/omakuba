# 10-fonts
# JetBrainsMono Nerd Font. Uso no terminal, no VS Code e no GNOME.
FONT_ROOT="$HOME/.local/share/fonts"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font Mono"; then
  skip "JetBrainsMono Nerd Font já instalada"
else
  tmp="$(mktemp -d)"
  if fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$tmp/jbm.zip" 2>/dev/null; then
    mkdir -p "$FONT_ROOT/JetBrainsMono"
    unzip -oq "$tmp/jbm.zip" -d "$FONT_ROOT/JetBrainsMono"
    fc-cache -f >/dev/null 2>&1
    ok "fonte instalada em ~/.local/share/fonts"
  else
    warn "o download da fonte falhou (pulei)"
  fi
  rm -rf "$tmp"
fi
