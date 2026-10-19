# ── 40-vscode ───────────────────────────────────────────────────────────────
# VS Code minimalista e confortável: conjunto enxuto de extensões e settings
# enxutos que se MESCLAM com o que você já tiver (nada é sobrescrito).
VS_EXTENSIONS=(
  ms-dotnettools.csharp            # C# (LSP/OmniSharp)
  ms-dotnettools.csdevkit          # C# Dev Kit: debug, solution explorer, refatoração
  dbaeumer.vscode-eslint           # lint web
  esbenp.prettier-vscode           # formatação web
  EditorConfig.EditorConfig        # respeita .editorconfig do projeto
  christian-kohler.path-intellisense
  formulahendry.auto-rename-tag    # html/JSX
  ritwickdey.LiveServer            # html estático
  redhat.vscode-yaml               # yaml (docker/k8s/ci)
  ms-azuretools.vscode-docker      # dockerfile/compose
)

if command -v code >/dev/null; then
  existing="$(code --list-extensions 2>/dev/null || true)"
  for ext in "${VS_EXTENSIONS[@]}"; do
    if printf '%s\n' "$existing" | grep -qixF "$ext"; then
      skip "$ext já instalada"
    else
      code --install-extension "$ext" >/dev/null 2>&1 && ok "$ext instalada" || warn "$ext falhou"
    fi
  done

  # Merge das settings: o dotfile só preenche chaves ausentes; as suas
  # escolhas (tema, ícone, etc.) têm prioridade e nunca são sobrescritas.
  DEST="$HOME/.config/Code/User/settings.json"
  SRC="$ROOT/dotfiles/vscode-settings.json"
  mkdir -p "$(dirname "$DEST")"
  if [[ -f "$DEST" ]]; then
    backup_file "$DEST"
    if jq empty "$DEST" >/dev/null 2>&1; then
      jq -s '.[0] * .[1]' "$SRC" "$DEST" > "$DEST.omakuba" && mv "$DEST.omakuba" "$DEST"
      ok "settings.json mescladas (suas escolhas preservadas)"
    else
      cp "$SRC" "$DEST"
      warn "settings.json inválido (JSONC?) — substituído pelo dotfile (backup feito)"
    fi
  else
    cp "$SRC" "$DEST"
    ok "settings.json criada a partir do dotfile"
  fi
else
  warn "VS Code (code) não encontrado — pulando"
fi