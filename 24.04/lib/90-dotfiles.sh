# 90-dotfiles
# Copia os dotfiles do projeto. Se já existir algo no destino, guardo um
# backup antes de trocar.
deploy() {
  local src="$DOTFILES_DIR/$1" dest="$2"
  [[ -f "$src" ]] || { warn "dotfile ausente: $src"; return 0; }
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]] && cmp -s "$src" "$dest"; then
    skip "igual, não mexi: $dest"
    return 0
  fi
  if [[ -e "$dest" ]]; then
    backup_file "$dest"
  fi
  cp "$src" "$dest"
  ok "copiado: $dest"
}

deploy zshrc         "$HOME/.zshrc"
deploy vimrc         "$HOME/.vimrc"
deploy tmux.conf     "$HOME/.tmux.conf"
deploy kitty.conf    "$HOME/.config/kitty/kitty.conf"
deploy starship.toml "$HOME/.config/starship.toml"
# O settings.json do VS Code é mesclado no passo 40-vscode, não copiado aqui.

# Terminal preferido do sistema: o GNOME Terminal, que é o padrão do Ubuntu 24.04.
# O Kitty continua no atalho Super+Return e nos favoritos do dock.
XDG_TERM=""
if [[ -f /usr/share/applications/org.gnome.Terminal.desktop ]]; then
  XDG_TERM="org.gnome.Terminal.desktop"
elif command -v kitty >/dev/null; then
  XDG_TERM="kitty.desktop"
fi

if [[ -n "$XDG_TERM" ]]; then
  XDG_LIST="$HOME/.config/xdg-terminals.list"
  mkdir -p "$HOME/.config"
  if [[ -f "$XDG_LIST" ]] && grep -qxF "$XDG_TERM" "$XDG_LIST"; then
    skip "$XDG_TERM já é o terminal preferido"
  else
    [[ -f "$XDG_LIST" ]] && backup_file "$XDG_LIST"
    if [[ -f "$XDG_LIST" ]]; then
      {
        printf '%s\n' "$XDG_TERM"
        grep -vxE 'kitty(\.desktop)?|org\.gnome\.Ptyxis\.desktop|org\.gnome\.Terminal\.desktop' "$XDG_LIST" || true
      } > "$XDG_LIST.tmp"
      mv "$XDG_LIST.tmp" "$XDG_LIST"
    else
      printf '%s\n' "$XDG_TERM" > "$XDG_LIST"
    fi
    ok "$XDG_TERM marcado como terminal preferido"
  fi
fi

info "backups, se houve algum, estão em: $BACKUP_DIR"
