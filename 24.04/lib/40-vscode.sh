# 40-vscode
# Extensões do VS Code e merge das settings.
VS_EXTENSIONS=(
  ms-dotnettools.csharp
  ms-dotnettools.csdevkit
  dbaeumer.vscode-eslint
  esbenp.prettier-vscode
  EditorConfig.EditorConfig
  christian-kohler.path-intellisense
  formulahendry.auto-rename-tag
  ritwickdey.LiveServer
  redhat.vscode-yaml
  ms-azuretools.vscode-docker
)

if command -v code >/dev/null; then
  existing="$(code --list-extensions 2>/dev/null || true)"
  for ext in "${VS_EXTENSIONS[@]}"; do
    if printf '%s\n' "$existing" | grep -qixF "$ext"; then
      skip "$ext já instalada"
    else
      code --install-extension "$ext" >/dev/null 2>&1 \
        && ok "$ext instalada" \
        || warn "$ext falhou"
    fi
  done

  # O dotfile só entra nas chaves que ainda não existem. O que você já
  # configurou, como tema e ícones, fica do jeito que está.
  DEST="$HOME/.config/Code/User/settings.json"
  SRC="$DOTFILES_DIR/vscode-settings.json"
  mkdir -p "$(dirname "$DEST")"
  if [[ -f "$DEST" ]]; then
    backup_file "$DEST"
    if jq empty "$DEST" >/dev/null 2>&1; then
      jq -s '.[0] * .[1]' "$SRC" "$DEST" > "$DEST.omakuba" && mv "$DEST.omakuba" "$DEST"
      ok "settings.json mesclado, suas escolhas continuam aí"
    else
      cp "$SRC" "$DEST"
      warn "settings.json não era um JSON válido, troquei pelo do projeto (com backup)"
    fi
  else
    cp "$SRC" "$DEST"
    ok "settings.json criado a partir do projeto"
  fi
else
  warn "não encontrei o VS Code (code), então pulei"
fi
