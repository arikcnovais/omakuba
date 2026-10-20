# Dotfiles

Os arquivos ficam em `dotfiles/`, na raiz do projeto, e são compartilhados pelas
duas versões do omakuba. O passo `90-dotfiles` copia cada um para o lugar certo.
Se já existir algo no destino, o original é guardado antes em
`~/.omakuba-backup-<data>/`.

| Arquivo | Vai para | Para que serve |
|---|---|---|
| `zshrc` | `~/.zshrc` | histórico de 50 mil linhas, completion com menu, plugins, PATH com nvm, `~/.dotnet/tools` e Homebrew, ativação do mise, zoxide e direnv, aliases de dev (com eza quando existe) e o prompt do Starship. Coisas só suas cabem em `~/.zshrc.local`. |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | o Kitty do atalho `Super+Return` (o terminal padrão no 26.04 é o Ptyxis), com a fonte Nerd, a paleta Breath, scrollback de 10 mil linhas e atalhos de abas. |
| `starship.toml` | `~/.config/starship.toml` | prompt curto: pasta, branch, status, Node ou .NET. |
| `vimrc` | `~/.vimrc` | Vim de emergência: numeração, cursorline, busca inteligente, undo persistente e clipboard do sistema. |
| `tmux.conf` | `~/.tmux.conf` | sessões que sobrevivem à queda de conexão, mouse, histórico de 50 mil linhas, índices a partir de 1 e barra discreta. |
| `vscode-settings.json` | `~/.config/Code/User/settings.json` | settings de web e C#, com format on save, minimap desligado e telemetria off. O passo `40-vscode` faz merge e nunca sobrescreve o que você já escolheu. |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` | o fastfetch com o layout e as cores do Bluefin. Quem instala é o passo `15-branding`. |
| `fastfetch/settings.json` | `~/.config/omakuba/fastfetch.json` | liga o sorteio de logo e diz a cor padrão do fastfetch. |
| `bin/omakuba-fastfetch` | `~/.local/bin/omakuba-fastfetch` | o fastfetch do omakuba: sorteia um logo do Bluefin e segue o acento do GNOME. O `fastfetch` e o `neofetch` viram alias dele. |
| `bin/omakuba-image-info` | `~/.local/bin/omakuba-image-info` | a linha do fastfetch com o nome do sistema e a versão da base. Lê tudo do `os-release`, então é genérico e só mostra a base quando ela é diferente. |
| `backgrounds/` | `/usr/share/backgrounds/omakuba/` | seus wallpapers. O passo `60-wallpapers` instala todas as imagens da pasta e cria o XML que faz cada uma aparecer em Configurações, Aparência, Papel de parede. Nenhum é aplicado: o seu continua. Para aplicar um de uma vez, use `OMAKUBA_WALLPAPER=/caminho/da/imagem`. |
| `bin/omakuba` | `~/.local/bin/omakuba` | o comando do dia a dia: `update`, `dock on/off/status`, `store` e `doctor`. Quem instala é o passo `85-updates`. |
| `systemd/user/omakuba-update.service` | `~/.config/systemd/user/` | roda o `omakuba update` uma vez por semana, sem sudo, para Flatpak e Homebrew. |
| `systemd/user/omakuba-update.timer` | `~/.config/systemd/user/` | agenda o serviço acima. O `85-updates` liga o timer com `systemctl --user`. |

O ícone do Ptyxis fica em `dotfiles/icons/` e é a exceção: quem instala é o
`20-terminal`, porque o destino é `/usr/share/icons` e precisa de sudo. O mesmo
vale para o `/etc/os-release`, o `/usr/share/pixmaps/omakuba.png`, os logos do
About e o watermark do Plymouth, que o `15-branding` grava com sudo. Todo o
resto do branding (fastfetch, logos) fica no seu home, sem sudo.

## O que o script configura fora dos dotfiles

| Onde | O quê | Passo |
|---|---|---|
| `~/.config/xdg-terminals.list` | no 26.04 deixa o Ptyxis (`org.gnome.Ptyxis.desktop`) no topo, que é o terminal preferido do sistema; no 24.04, o GNOME Terminal (`org.gnome.Terminal.desktop`). O `20-terminal` do 26.04 também garante o `x-terminal-emulator` e o `x-scheme-handler/terminal` apontando para o Ptyxis | `20-terminal` e `90-dotfiles` |
| `/etc/os-release` | a marca do omakuba (`NAME`, `PRETTY_NAME`/`VERSION` com o codename da base, `LOGO`, `VARIANT`), mantendo `ID`, `VERSION_ID` e `UBUNTU_CODENAME` do Ubuntu. O `/usr/lib/os-release` continua o original | `15-branding` |
| `/usr/share/pixmaps/omakuba.png` | o logo do Bluefin, que o `LOGO=omakuba` do os-release usa | `15-branding` |
| `/usr/share/pixmaps/ubuntu-logo-text.svg` e `ubuntu-logo-text-dark.svg` (26.04) | o logo do About do GNOME: o dodô do Bluefin, sem texto. Os originais do Ubuntu ficam em `*.omakuba-backup` na mesma pasta | `15-branding` |
| `/usr/share/pixmaps/ubuntu-logo-text.png` e `ubuntu-logo-text-dark.png` (24.04) | o logo do About do GNOME: o dodô do Bluefin em 192x192, o mesmo desenho do SVG do 26.04 (o PNG vem de `dotfiles/branding/bluefin-about.png`). Os originais ficam em `*.omakuba-backup` na mesma pasta | `15-branding` |
| `/usr/share/plymouth/themes/spinner/watermark.png` | o watermark do Plymouth com o dodô do Bluefin. O original fica em `watermark.png.omakuba-backup` e o passo roda `update-initramfs -u` | `15-branding` |
| `~/.local/share/omakuba/branding/logos/` | os logos do Bluefin (símbolos ANSI e PNG) que o `omakuba-fastfetch` sorteia | `15-branding` |
| `~/.local/share/omakuba/branding/plymouth/watermark.png` | o watermark do Bluefin baixado para o Plymouth | `15-branding` |
| GNOME Terminal | perfil omakuba, com a paleta Breath, a Nerd Font e 8% de transparência. No 26.04 isso só acontece se você tiver instalado o GNOME Terminal por conta própria | `20-terminal` |
| Ptyxis | fonte, cursor, opacidade, scrollback e o `x-terminal-emulator`/`x-scheme-handler/terminal` apontando para ele. Só no 26.04, que é onde ele é o terminal padrão e o favorito do dock | `20-terminal` |
| `/usr/share/icons/hicolor/scalable/apps/org.gnome.Ptyxis.svg` | logo novo do Ptyxis, copiado de `dotfiles/icons/`, e cache do hicolor atualizado. O hicolor é o fallback que o Adwaita usa. Só no 26.04 | `20-terminal` |
| `/usr/share/themes/adw-gtk3` e `adw-gtk3-dark` | o tema adw-gtk3, baixado do release do GitHub e aplicado como tema GTK3 (`adw-gtk3-dark`). É o Adwaita para os apps GTK3, sem trocar o Adwaita do GNOME | `50-gnome` |
| snap `adw-gtk3-theme` | o mesmo tema para os apps em snap, ligado ao `gtk-3-themes` de cada app que usa o `gtk-common-themes` (que fica conectado, então ícones e sons não mudam) | `50-gnome` |
| `/usr/share/icons/hicolor/scalable/categories/preferences-ubuntu-panel*.svg` | só o ícone do painel "Ubuntu Desktop" copiado do Yaru, para o painel não ficar sem ícone com o Adwaita. O tema Yaru em si não é aplicado | `50-gnome` |
| gsettings e dconf | Adwaita dark, adw-gtk3 nos apps GTK3, dock do Ubuntu em barra lateral esquerda com blur e lixeira, 5 workspaces fixos, atalhos do Bluefin, favoritos do dock (Ptyxis no 26.04, Kitty no 24.04), relógio com dia da semana, desktop sem ícones, polimento de bateria, fontes e touchpad. Nenhum wallpaper é aplicado | `50-gnome`, `60-wallpapers` e `65-bluefin-wallpapers` |
| Extensões do GNOME | no 24.04: Forge como extra, Blur my Shell, Vitals, Caffeine, GSConnect, Search Light e Logo Menu. No 26.04: o mesmo conjunto sem o Forge. O Legacy (GTK3) Theme Scheme Auto Switcher alterna o GTK3 entre `adw-gtk3` e `adw-gtk3-dark` conforme o claro/escuro e entra nas duas versões. O Accent Icons entra no GNOME 47+ e deixa as pastas seguirem a cor do acento. O AppIndicator e o Dash to Dock são os pacotes do Ubuntu (`ubuntu-appindicators` e `ubuntu-dock`) | `50-gnome` |
| Loja gráfica | o Bazaar é a única loja; o passo `05-store` remove a Snap Store e o `ubuntu-software`, sem tirar o `snapd` nem o comando `snap`. O APT e os `.deb` continuam normais | `05-store` e `70-flatpaks` |
| Flatpak | Flathub, Bazaar, Flatseal, Extension Manager, Mission Center, Gradia, Pinta, Refine, DistroShelf, Ignition, Impression e os temas adw-gtk3 para os apps Flatpak (o tema do sistema vem do `50-gnome`). O conjunto completo do GNOME fica atrás de `OMAKUBA_FULL_FLATPAKS=1` | `70-flatpaks` |
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
