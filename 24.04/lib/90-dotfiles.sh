# 90-dotfiles
# Copia os dotfiles do projeto. Se já existir algo no destino, guardo um
# backup antes de trocar. O install_user_file vem do common.sh.
deploy() {
  install_user_file "$DOTFILES_DIR/$1" "$2"
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
[[ -n "$XDG_TERM" ]] && set_preferred_terminal "$XDG_TERM"

info "backups, se houve algum, estão em: $BACKUP_DIR"
