# ── 90-dotfiles ─────────────────────────────────────────────────────────────
# Deploy dos dotfiles versionados neste projeto. Nada é sobrescrito sem backup.
deploy() {
  local src="$ROOT/dotfiles/$1" dest="$2"
  [[ -f "$src" ]] || { warn "dotfile ausente: $src"; return 0; }
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]] && cmp -s "$src" "$dest"; then
    skip "idêntico: $dest"
    return 0
  fi
  if [[ -e "$dest" ]]; then
    backup_file "$dest"
  fi
  cp "$src" "$dest"
  ok "deploy: $dest"
}

deploy zshrc            "$HOME/.zshrc"
deploy vimrc            "$HOME/.vimrc"
deploy tmux.conf        "$HOME/.tmux.conf"
deploy kitty.conf       "$HOME/.config/kitty/kitty.conf"
deploy starship.toml    "$HOME/.config/starship.toml"
# (settings.json do VS Code é mesclado no passo 40-vscode, não copiado aqui)

# Kitty como terminal preferido do sistema (apps usam `kitty`).
if command -v kitty >/dev/null; then
  mkdir -p "$HOME/.config"
  if [[ ! -f "$HOME/.config/xdg-terminals.list" ]] || ! grep -q kitty "$HOME/.config/xdg-terminals.list"; then
    backup_file "$HOME/.config/xdg-terminals.list" 2>/dev/null || true
    printf 'kitty\n' > "$HOME/.config/xdg-terminals.list"
    ok "terminal preferido: kitty"
  fi
fi

info "backups (se houve) em: $BACKUP_DIR"