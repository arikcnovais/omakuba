# 10-fonts
# JetBrainsMono Nerd Font. Uso no terminal, no VS Code e no GNOME.
FONT_ROOT="$HOME/.local/share/fonts"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font Mono"; then
  skip "JetBrainsMono Nerd Font já instalada"
else
  tmp="$(mktemp -d)"
  if run_quiet "baixando a JetBrainsMono Nerd Font" fetch \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$tmp/jbm.zip"; then
    mkdir -p "$FONT_ROOT/JetBrainsMono"
    run_quiet "instalando a fonte" unzip -oq "$tmp/jbm.zip" -d "$FONT_ROOT/JetBrainsMono"
    run_quiet "atualizando o cache de fontes" fc-cache -f
    ok "fonte instalada em ~/.local/share/fonts"
  else
    warn "o download da fonte falhou (pulei)"
  fi
  rm -rf "$tmp"
fi
