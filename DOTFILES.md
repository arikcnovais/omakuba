# Catálogo de dotfiles — omakuba

Todos os dotfiles ficam versionados na pasta `dotfiles/` deste projeto e são
instalados pelo passo `90-dotfiles` do `./install.sh` (com backup automático em
`~/.omakuba-backup-<data>/` quando já existe um arquivo seu no destino).

| # | Origem (projeto) | Destino (sua máquina) | Finalidade |
|---|---|---|---|
| 1 | `dotfiles/zshrc` | `~/.zshrc` | Shell padrão: histórico de 50k linhas compartilhado, completion com menu, plugins (autosuggestions, syntax highlighting, busca por histórico), `PATH` com nvm/`~/.dotnet/tools`, aliases de dev/git/docker, prompt starship, atalhos fzf. Sobrescritas locais em `~/.zshrc.local`. |
| 2 | `dotfiles/kitty.conf` | `~/.config/kitty/kitty.conf` | Terminal padrão (`Super+Return`): JetBrainsMono Nerd Font 12, paleta **Breath** (Manjaro), scrollback 10k, tabs powerline discretas, atalhos de abas/janelas. |
| 3 | `dotfiles/starship.toml` | `~/.config/starship.toml` | Prompt minimalista: pasta → branch git → status → **Node** → **.NET** → seta. |
| 4 | `dotfiles/vimrc` | `~/.vimrc` | Vim de emergência/terminal: numeração, cursorline, busca inteligente, undo persistente, clipboard do sistema, paleta sóbria (habamax). |
| 5 | `dotfiles/tmux.conf` | `~/.tmux.conf` | Sessões que sobrevivem a queda de conexão: mouse, histórico 50k, índices a partir de 1, divisões com `|` e `-`, barra discreta. |
| 6 | `dotfiles/vscode-settings.json` | `~/.config/Code/User/settings.json` | Settings minimalistas de dev (web + C#): fonte Nerd com ligatures, format on save, minimap off, rulers 80/120, terminal integrado em zsh, telemetry off. **Merge preservando suas escolhas** (tema/ícones nunca são sobrescritos). |

## Configurações gerenciadas por script (não são dotfiles)

| Onde | O quê | Passo |
|---|---|---|
| `~/.config/xdg-terminals.list` | Define o **kitty** como terminal preferido do sistema | `90-dotfiles` |
| GNOME Terminal (dconf) | Perfil **omakuba**: paleta **Breath** (Manjaro), Nerd Font 12, 8% de transparência, cursor `ibeam`, scrollback 10k — mesmo visual do kitty | `20-terminal` |
| dconf/gsettings (org.gnome.*) | Yaru preservado (dark), dock clássico refinado (altura total, DOTS, 72% opacidade dinâmica, auto-hide), Blur my Shell, Vitals, 5 workspaces fixos, teclas `Super+1..5`, `Super+Return` → kitty, favoritos do dock, relógio mínimo, desktop sem ícones, wallpaper | `50-gnome` / `60-wallpapers` |
| Extensões do GNOME | Forge, Blur my Shell, Vitals, Caffeine (instaladas em `~/.local/share/gnome-shell/extensions`) | `50-gnome` |
| Extensões do VS Code | C#, C# Dev Kit, ESLint, Prettier, EditorConfig, Docker, YAML, etc. | `40-vscode` |

> **Git é intencionalmente NÃO configurado** — identidade (nome/e-mail),
> branch padrão,Aliases etc. são escolhas pessoais: configure com
> `git config --global --edit`. O setup só te dá o **lazygit** e o **tmux**.

## Reinstalar / ajustar

```bash
./install.sh 90-dotfiles          # re-deploya os dotfiles (idempotente)
vim ~/.zshrc                      # tweak pessoal: use ~/.zshrc.local
```

Backups ficam em `~/.omakuba-backup-<data-hora>/` com o caminho original
preservado — algo que foi sobrescrito pode ser recuperado de lá.