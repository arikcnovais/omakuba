# ── 10-fonts ────────────────────────────────────────────────────────────────
# JetBrainsMono Nerd Font: uma fonte só para código/terminal, com ícones
# (glifos Nerd Font) para o starship e para o terminal.
FONT_ROOT="$HOME/.local/share/fonts"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font Mono"; then
  skip "JetBrainsMono Nerd Font já instalada"
else
  tmp="$(mktemp -d)"
  if fetch "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$tmp/jbm.zip" 2>/dev/null; then
    mkdir -p "$FONT_ROOT/JetBrainsMono"
    unzip -oq "$tmp/jbm.zip" -d "$FONT_ROOT/JetBrainsMono"
    fc-cache -f >/dev/null 2>&1
    ok "JetBrainsMono Nerd Font instalada em ~/.local/share/fonts"
  else
    warn "download da Nerd Font falhou (ignorado)"
  fi
  rm -rf "$tmp"
fi