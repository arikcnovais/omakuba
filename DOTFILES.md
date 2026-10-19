# Dotfiles

Os arquivos ficam em `dotfiles/`, na raiz do projeto, e são compartilhados pelas
duas versões do omakuba. O passo `90-dotfiles` copia cada um para o lugar certo.
Se já existir algo no destino, o original é guardado antes em
`~/.omakuba-backup-<data>/`.

| Arquivo | Vai para | Para que serve |
|---|---|---|
| `zshrc` | `~/.zshrc` | histórico de 50 mil linhas, completion com menu, plugins, PATH com nvm, `~/.dotnet/tools` e Homebrew, ativação do mise, zoxide e direnv, aliases de dev (com eza quando existe) e o prompt do Starship. Coisas só suas cabem em `~/.zshrc.local`. |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | terminal principal do setup, com a fonte Nerd, a paleta Breath, scrollback de 10 mil linhas e atalhos de abas. |
| `starship.toml` | `~/.config/starship.toml` | prompt curto: pasta, branch, status, Node ou .NET. |
| `vimrc` | `~/.vimrc` | Vim de emergência: numeração, cursorline, busca inteligente, undo persistente e clipboard do sistema. |
| `tmux.conf` | `~/.tmux.conf` | sessões que sobrevivem à queda de conexão, mouse, histórico de 50 mil linhas, índices a partir de 1 e barra discreta. |
| `vscode-settings.json` | `~/.config/Code/User/settings.json` | settings de web e C#, com format on save, minimap desligado e telemetria off. O passo `40-vscode` faz merge e nunca sobrescreve o que você já escolheu. |
| `backgrounds/` | `/usr/share/backgrounds/omakuba/` | seus wallpapers. O passo `60-wallpapers` instala todas as imagens da pasta e cria o XML que faz cada uma aparecer em Configurações, Aparência, Papel de parede. O `green forest.jpg`, se estiver na pasta, vira o padrão; depois dele, o Bamboo; depois, a primeira imagem. Os wallpapers do Bluefin e da Universal Blue entram à parte, no passo `65-bluefin-wallpapers`. |
| `bin/omakuba` | `~/.local/bin/omakuba` | o comando do dia a dia: `update`, `dock on/off/status` e `doctor`. Quem instala é o passo `85-updates`. |
| `systemd/user/omakuba-update.service` | `~/.config/systemd/user/` | roda o `omakuba update` uma vez por semana, sem sudo, para Flatpak e Homebrew. |
| `systemd/user/omakuba-update.timer` | `~/.config/systemd/user/` | agenda o serviço acima. O `85-updates` liga o timer com `systemctl --user`. |

O ícone do Ptyxis fica em `dotfiles/icons/` e é a exceção: quem instala é o
`20-terminal`, porque o destino é `/usr/share/icons` e precisa de sudo.

## O que o script configura fora dos dotfiles

| Onde | O quê | Passo |
|---|---|---|
| `~/.config/xdg-terminals.list` | no 26.04 deixa o Ptyxis (`org.gnome.Ptyxis.desktop`) como terminal preferido do sistema. No 24.04, o GNOME Terminal (`org.gnome.Terminal.desktop`) | `90-dotfiles` |
| GNOME Terminal | perfil omakuba, com a paleta Breath, a Nerd Font e 8% de transparência. No 26.04 isso só acontece se você tiver instalado o GNOME Terminal por conta própria | `20-terminal` |
| Ptyxis | fonte, cursor, opacidade e scrollback. Só no 26.04, que é onde ele é o terminal padrão | `20-terminal` |
| `/usr/share/icons/hicolor/scalable/apps/org.gnome.Ptyxis.svg` | logo novo do Ptyxis, copiado de `dotfiles/icons/`, e cache do hicolor atualizado. O hicolor é o fallback que o Adwaita usa. Só no 26.04 | `20-terminal` |
| gsettings e dconf | Adwaita dark, dock do Ubuntu em barra lateral esquerda com blur, 5 workspaces fixos, atalhos do Bluefin, favoritos do dock, relógio com dia da semana, desktop sem ícones e o wallpaper padrão | `50-gnome` e `60-wallpapers` |
| Extensões do GNOME | no 24.04: Forge como extra, Blur my Shell, Vitals, Caffeine, GSConnect, Search Light e Logo Menu. No 26.04: o mesmo conjunto sem o Forge. O AppIndicator e o Dash to Dock são os pacotes do Ubuntu (`ubuntu-appindicators` e `ubuntu-dock`) | `50-gnome` |
| Flatpak | Flathub, Bazaar, Flatseal, Extension Manager, Mission Center, Gradia, Pinta, Refine, DistroShelf, Ignition, Impression e os temas adw-gtk3. O conjunto completo do GNOME fica atrás de `OMAKUBA_FULL_FLATPAKS=1` | `70-flatpaks` |
| CLI | Homebrew em `/home/linuxbrew/.linuxbrew`, com mise, chezmoi, topgrade, dysk e podman-tui; o resto vem do APT | `75-cli` |
| DX | Podman, Distrobox, virt-manager, Incus, Cockpit e as ferramentas de Kubernetes/CNCF. Só roda com `OMAKUBA_DX=1` | `80-dx` |
| Atualizações | comando `omakuba` e timer semanal para Flatpak e Homebrew | `85-updates` |
| Extensões do VS Code | C#, C# Dev Kit, ESLint, Prettier, EditorConfig, Docker, YAML, Remote Containers, Remote SSH e Containers | `40-vscode` |

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
