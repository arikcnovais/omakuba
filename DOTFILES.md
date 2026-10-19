# Dotfiles

Os arquivos ficam em `dotfiles/`, na raiz do projeto, e são compartilhados pelas
duas versões do omakuba. O passo `90-dotfiles` copia cada um para o lugar certo.
Se já existir algo no destino, o original é guardado antes em
`~/.omakuba-backup-<data>/`.

| Arquivo | Vai para | Para que serve |
|---|---|---|
| `zshrc` | `~/.zshrc` | histórico de 50 mil linhas, completion com menu, plugins, PATH com nvm e `~/.dotnet/tools`, aliases de dev e o prompt do Starship. Coisas só suas cabem em `~/.zshrc.local`. |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | terminal padrão do setup, com a fonte Nerd, a paleta Breath, scrollback de 10 mil linhas e atalhos de abas. |
| `starship.toml` | `~/.config/starship.toml` | prompt curto: pasta, branch, status, Node ou .NET. |
| `vimrc` | `~/.vimrc` | Vim de emergência: numeração, cursorline, busca inteligente, undo persistente e clipboard do sistema. |
| `tmux.conf` | `~/.tmux.conf` | sessões que sobrevivem à queda de conexão, mouse, histórico de 50 mil linhas, índices a partir de 1 e barra discreta. |
| `vscode-settings.json` | `~/.config/Code/User/settings.json` | settings de web e C#, com format on save, minimap desligado e telemetria off. O passo `40-vscode` faz merge e nunca sobrescreve o que você já escolheu. |
| `backgrounds/Bamboo_wallpaper.png` | `/usr/share/backgrounds/omakuba/Bamboo_wallpaper.png` | papel de parede padrão do projeto. O XML que o passo `60-wallpapers` cria faz ele aparecer em Configurações, Aparência, Papel de parede. |

## O que o script configura fora dos dotfiles

| Onde | O quê | Passo |
|---|---|---|
| `~/.config/xdg-terminals.list` | deixa o Kitty como terminal preferido do sistema, com a entrada `kitty.desktop` | `90-dotfiles` |
| GNOME Terminal | perfil omakuba, com a paleta Breath, a Nerd Font e 8% de transparência. No 26.04 isso só acontece se você tiver instalado o GNOME Terminal por conta própria | `20-terminal` |
| Ptyxis | fonte, cursor, opacidade e scrollback. Só no 26.04, que é onde ele é o terminal padrão | `20-terminal` |
| gsettings e dconf | Yaru dark, dock enxuto, 5 workspaces fixos, `Super+Return`, favoritos do dock, relógio curto, desktop sem ícones e o wallpaper Bamboo | `50-gnome` e `60-wallpapers` |
| Extensões do GNOME | no 24.04: Forge, Blur my Shell, Vitals e Caffeine. No 26.04: Blur my Shell, Vitals e Caffeine | `50-gnome` |
| Extensões do VS Code | C#, C# Dev Kit, ESLint, Prettier, EditorConfig, Docker, YAML e mais algumas | `40-vscode` |

O Git é de propósito não configurado. Nome, e-mail, branch padrão e aliases são
coisa pessoal. O setup só entrega o lazygit e o tmux. Para configurar:

```bash
git config --global --edit
```

## Para rodar de novo

```bash
./install.sh 90-dotfiles     # copia os dotfiles outra vez
./24.04/install.sh 90-dotfiles
./26.04/install.sh 90-dotfiles
```

Esse passo não precisa de sudo, então dá para rodar só ele a qualquer momento
para puxar as mudanças dos dotfiles.

Os backups ficam em `~/.omakuba-backup-<data-hora>/`, com o caminho original
preservado dentro. Se algo foi trocado e você quer de volta, é só olhar lá.
