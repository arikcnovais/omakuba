# 40-vscode
# Instala o VS Code pelo repositório da Microsoft, instala as extensões e faz
# o merge das settings.
if ! command -v code >/dev/null 2>&1; then
  step "adicionando o repositório do VS Code"
  sudo install -d -m 0755 /etc/apt/keyrings
  if run_quiet "baixando a chave da Microsoft" bash -c \
       'curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null'; then
    printf 'deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main\n' \
      | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
    apt_install code || warn "não consegui instalar o VS Code (pulei)"
  else
    warn "não consegui baixar a chave do VS Code (pulei)"
  fi
fi

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
  ms-vscode-remote.remote-containers
  ms-vscode-remote.remote-ssh
  ms-azuretools.vscode-containers
)

if command -v code >/dev/null; then
  existing="$(code --list-extensions 2>/dev/null || true)"
  for ext in "${VS_EXTENSIONS[@]}"; do
    if printf '%s\n' "$existing" | grep -ixF "$ext" >/dev/null; then
      skip "$ext já instalada"
    else
      run_quiet "instalando $ext" code --install-extension "$ext" \
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
