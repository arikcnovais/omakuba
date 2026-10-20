# omakuba

Setup que eu uso para deixar um Ubuntu pronto para trabalhar com web (Node e
TypeScript) e com C# (.NET), com as ferramentas e o jeito do Bluefin. A ideia
não é copiar a imagem do Bluefin, e sim trazer o que ele tem de bom para um
Ubuntu normal, com APT, deb e Flatpak. O código aqui é meu, feito com calma.

O Bluefin é uma imagem imutável da Universal Blue. O omakuba não segue esse
caminho: ele arruma um Ubuntu que você pode mexer, com os mesmos apps, as
extensões do GNOME e alguns atalhos. O dock é o do Ubuntu, na barra lateral
esquerda, com o blur do Blur my Shell. O resto é o conjunto que o Bluefin usa
no GNOME, mais algumas coisas que eu gosto de ter à mão. A loja gráfica é o
Bazaar; o snap fica para a linha de comando e para o tema dos apps em snap,
junto do APT e dos `.deb`.

O repositório tem duas versões, porque cada uma pede coisas diferentes:

| Pasta | Ubuntu | Tiling |
|---|---|---|
| `24.04/` | 24.04 LTS, GNOME 46 | conjunto do Bluefin mais o Forge como extra |
| `26.04/` | 26.04 LTS, GNOME 50 | conjunto do Bluefin, sem Forge |

Os dotfiles ficam em `dotfiles/` e são compartilhados pelas duas versões.
Assim eu não preciso manter duas cópias do wallpaper e dos arquivos de config.

Testei o script do 26.04 no Ubuntu 26.04.1.

## Como rodar

Na raiz do projeto:

```bash
./install.sh            # vê a versão do Ubuntu e chama a pasta certa
./install.sh --list     # lista os passos
./install.sh 50-gnome   # roda só um passo
```

Se preferir chamar direto:

```bash
./24.04/install.sh
./26.04/install.sh
```

O script pede a senha do sudo no começo. A única exceção é o passo
`90-dotfiles`, que só mexe no seu home e roda sem sudo. Pode rodar quantas vezes
quiser, porque cada passo confere o que já existe antes de mexer. Se você
estiver na versão errada do Ubuntu, ele avisa e para. Para insistir:

```bash
OMAKUBA_FORCE=1 ./26.04/install.sh
```

Cada passo aparece como `[n/total]` e os comandos mais demorados (downloads,
clones, instalações) mostram um spinner com o que está acontecendo. Se um passo
falha, ele anota, segue para o próximo e mostra o resumo no final, em vez de
abortar tudo.

## O que muda entre as duas versões

No 24.04 o Forge ainda funciona, então o setup ativa o tiling em árvore, com
gaps e atalhos no estilo i3. No 26.04 o Forge não acompanhou o GNOME 50, então
essa versão não instala nem configura tiling. Se ele tiver sobrado de uma
instalação antiga, o script desliga. O tiling-assistant do Ubuntu continua
ligado no 26.04; no 24.04 ele é desligado para não brigar com o Forge.

O resto é igual nas duas: Adwaita, Kitty, Zsh, Starship, workspaces fixos, o
dock do Ubuntu na barra lateral com a lixeira, o conjunto de extensões do
Bluefin, o Bazaar como loja, os ajustes de aparência e a identidade do omakuba
(o `os-release`, o logo e o fastfetch).

O 26.04 troca o GNOME Terminal pelo Ptyxis. O script ajusta a fonte, o cursor e
a opacidade do Ptyxis, que fica como terminal padrão do sistema: é ele que
aparece no dock e que o `xdg-terminal-exec` abre no `Ctrl+Alt+T`. O Kitty
continua instalado, no atalho `Super+Return`, e a paleta Breath fica nele, no
tmux e no prompt, porque o Ptyxis escolhe paleta por nome.

O .NET também muda um pouco. O 26.04 já traz o SDK 10 nos repositórios oficiais.
O SDK 8 não está lá, então o script tenta instalar e segue sem ele se não achar.
Se você precisar do 8 para um projeto antigo, o caminho é o feed da Microsoft,
explicado na página de instalação do .NET no Ubuntu.

## Passos

| Passo | O que faz |
|---|---|
| `00-base` | ferramentas do dia a dia via APT, Docker, lazygit e alguns extras do Bluefin que existem nos repositórios do Ubuntu |
| `05-store` | remove a Snap Store e o pacote `ubuntu-software`, mas mantém o `snapd` e o comando `snap` para a linha de comando |
| `10-fonts` | JetBrainsMono Nerd Font em `~/.local/share/fonts` |
| `15-branding` | o `/etc/os-release` com o nome Omakuba (configurável por `OMAKUBA_BRAND_NAME`), o logo do Bluefin, o logo do About do GNOME (o dodô, com backup dos originais do Ubuntu em `/usr/share/pixmaps/*.omakuba-backup`), o watermark do Plymouth e o fastfetch com o layout e as cores dele |
| `20-terminal` | Kitty, Zsh como shell padrão, Starship, plugins do Zsh e o terminal padrão do sistema (Ptyxis no 26.04, GNOME Terminal no 24.04) |
| `30-dev` | nvm, Node LTS, pnpm, yarn, .NET e ferramentas do dotnet |
| `40-vscode` | instala o VS Code pelo repositório da Microsoft, instala as extensões e faz o merge das settings |
| `50-gnome` | extensões do Bluefin, dock do Ubuntu, workspaces, atalhos, o tema adw-gtk3 nos apps GTK3 e nos snaps (via o snap `adw-gtk3-theme`), claro/escuro automático, a extensão Accent Icons e o ícone do painel Ubuntu no hicolor |
| `60-wallpapers` | instala e registra os wallpapers que você deixar em `dotfiles/backgrounds/`; não aplica nenhum, o seu continua |
| `65-bluefin-wallpapers` | baixa os wallpapers do Bluefin e da Universal Blue e registra todos, sem aplicar nenhum |
| `70-flatpaks` | Flathub, Bazaar, Flatseal, Mission Center, Gradia e os outros apps do Bluefin |
| `75-cli` | Homebrew e o pacote de ferramentas de linha de comando |
| `80-dx` | camada DX do Bluefin, com containers, VMs e Kubernetes. Só roda com `OMAKUBA_DX=1` |
| `85-updates` | comando `omakuba` e timer semanal para Flatpak e Homebrew |
| `90-dotfiles` | copia os dotfiles, com backup do que já existia |

## O que você recebe

| Camada | Resultado |
|---|---|
| Janelas | no 24.04, Forge com tiling em árvore e gaps de 8px; no 26.04, o tiling padrão do GNOME |
| Desktop | Adwaita dark, com o acento slate (o mesmo do Bluefin) e o adw-gtk3 nos apps GTK3, que trocam sozinhos entre claro e escuro conforme o sistema; os apps em Flatpak e snap também usam o mesmo tema; as pastas acompanham a cor do acento pelo Accent Icons; dock do Ubuntu na barra lateral esquerda, altura total, auto-hide, lixeira e sem cantos quentes |
| Identidade | o sistema se chama Omakuba no `/etc/os-release`, o logo do Bluefin aparece no os-release e no About do GNOME (o dodô, sem texto), o watermark do Plymouth é o mesmo dodô e o fastfetch usa o layout, o logo e as cores do Bluefin |
| Profundidade | Blur my Shell na barra, no dock e na visão geral, com os popups no pipeline arredondado e blur estático |
| Extensões | AppIndicator, Dash to Dock, Blur my Shell, GSConnect, Search Light, Logo Menu, Caffeine, Custom Command Menu, Legacy (GTK3) Theme Scheme Auto Switcher, Bazaar Companion no 26.04 e Accent Icons no GNOME 47+ |
| Métricas | Vitals com CPU, memória, disco e rede na barra |
| Energia | Caffeine para o notebook não dormir durante builds longos |
| Loja | o Bazaar é a única loja gráfica; a Snap Store sai do caminho e o snap fica para a linha de comando e para o tema dos apps em snap, junto do APT e dos .deb |
| Flatpak | Bazaar, Flatseal, Extension Manager, Mission Center, Gradia, Pinta, Refine, DistroShelf, Ignition, Impression e os temas adw-gtk3 para os apps Flatpak (o tema do sistema entra pelo `50-gnome`) |
| Snap | o `snapd` e o comando `snap` continuam, e os apps em snap ganham o adw-gtk3 pelo snap `adw-gtk3-theme`, ligado ao `gtk-3-themes` de cada um; o `gtk-common-themes` fica, então ícones e sons não mudam |
| Terminal | Ptyxis como terminal padrão no 26.04 (é ele que fica no dock) e Kitty no atalho, com Zsh, Starship, autosuggestions e highlighting |
| Node | nvm com o Node LTS, pnpm, yarn, typescript e prettier |
| C# | .NET SDK 10 (e o 8 quando o repositório tem), dotnet-ef e csharpier |
| Docker | seu usuário no grupo docker, sem precisar de sudo no dia a dia |
| CLI | Homebrew com mise, chezmoi, topgrade, dysk e podman-tui, mais as ferramentas do dia a dia via APT |
| DX | Podman, Distrobox, virt-manager, Incus, Cockpit e as ferramentas de Kubernetes/CNCF, se você ligar a camada |
| Atualizações | `omakuba update` na mão e um timer semanal para Flatpak e Homebrew |
| Git | lazygit e tmux, mas o Git em si fica por sua conta |
| VS Code | extensões de web, C#, containers e SSH, com settings que se misturam às suas |
| Papel de parede | os wallpapers que você colocar em `dotfiles/backgrounds/` e os do Bluefin ficam registrados na galeria; nenhum é aplicado, o seu continua até você escolher outro |

## Atalhos

Valem nas duas versões:

| Atalho | O que faz |
|---|---|
| `Super+Return` | abre o Kitty |
| `Ctrl+Alt+T` | abre o terminal padrão (Ptyxis no 26.04, GNOME Terminal no 24.04) |
| `Ctrl+Alt+Return` | abre o terminal padrão pelo outro atalho |
| `Super+E` | abre o Nautilus numa janela nova |
| `Ctrl+Shift+Esc` | abre o Mission Center |
| `Super+Space` | abre o Search Light |
| `Super+1..5` | troca de workspace |
| `Super+Shift+1..5` | manda a janela para outro workspace |
| `Super+D` | mostra o desktop |
| `Super+Tab` | troca de aplicativo |

No 26.04 o ícone do terminal no dock é o Ptyxis; no 24.04 continua o Kitty.
| `Alt+Tab` | troca de janela |
| `Super+Down` | desmaximiza a janela |

Só no 24.04, com o Forge:

| Atalho | O que faz |
|---|---|
| `Super+h/j/k/l` | foca a janela da esquerda, de baixo, de cima ou da direita |
| `Super+Shift+h/j/k/l` | move a janela nessa direção |
| `Super+Alt+h/l` | redimensiona |

## Extensões do GNOME

O conjunto que o Bluefin usa no GNOME é este:

- AppIndicator, para os ícones de bandeja.
- Blur my Shell, para o blur da barra, do dock, dos popups e da visão geral.
- Dash to Dock, que no Ubuntu é o `ubuntu-dock@ubuntu.com`.
- GSConnect, para integrar com o KDE Connect no celular.
- Search Light, para a busca no meio da tela com `Super+Space`.
- Logo Menu, para o menu do logo no canto esquerdo.
- Caffeine, para não suspender a máquina em builds longos.
- Custom Command Menu, para uma lista de comandos rápidos na barra.
- Legacy (GTK3) Theme Scheme Auto Switcher, que troca o tema GTK3 entre
  `adw-gtk3` e `adw-gtk3-dark` conforme o claro/escuro do sistema.
- Accent Icons, que faz as pastas acompanharem a cor do acento (GNOME 47+).
- Bazaar Companion, para abrir um app Flatpak direto no Bazaar.
- Gradia Capture, a integração de captura de tela do Gradia.

No Ubuntu eu uso os equivalentes que já vêm no sistema para o AppIndicator e
para o Dash to Dock: `ubuntu-appindicators@ubuntu.com` e
`ubuntu-dock@ubuntu.com`. O resto é instalado pelo próprio script, direto do
extensions.gnome.org ou do GitHub.

O Bazaar Companion só declara suporte a partir do GNOME 49, então no 24.04 ele
é pulado com um aviso. A extensão do Gradia não tem build para o GNOME 46 nem
para o 50; o app Gradia entra pelo Flatpak no passo `70-flatpaks`, e a
integração fica de fora com um aviso. O Custom Command Menu suporta do GNOME 45
ao 51, então entra nas duas versões. O Legacy (GTK3) Theme Scheme Auto Switcher
também vai do GNOME 45 ao 51, então entra nas duas; ele não tem schema, é só
instalar e ligar.

No 26.04 o Search Light vem do branch principal do GitHub, porque a versão que
está no extensions.gnome.org ainda declara suporte só até o GNOME 49. No 24.04
ele vem do extensions.gnome.org mesmo.

No 24.04 o Forge entra como extra. O tiling-assistant do Ubuntu é desligado
nessa versão, porque ele briga com o Forge. Se quiser ele de volta:
`gnome-extensions enable tiling-assistant@ubuntu.com`.

As extensões só entram no ar depois de sair e entrar de novo, porque no Wayland
não dá para reiniciar o shell na mão.

## Flatpak, CLI e DX

A loja gráfica é o Bazaar. O passo `05-store` remove a Snap Store e o pacote
`ubuntu-software`, mas não mexe no `snapd`: o `snap` continua disponível para
quem instala ferramentas de linha de comando. O APT e os `.deb` seguem iguais,
então você não perde nada do Ubuntu normal. O Bazaar entra pelo Flatpak no
passo `70-flatpaks`. O `50-gnome` ainda deixa os apps em snap com a mesma cara
dos outros: instala o snap `adw-gtk3-theme` e liga o `gtk-3-themes` de cada app
nele, sem tirar o `gtk-common-themes`.

O passo `70-flatpaks` configura o Flathub e instala o conjunto base do Bluefin.
Os apps do GNOME que o Ubuntu já traz como deb ficam como estão, para não
aparecer tudo duplicado no menu. Se você quiser o conjunto completo do GNOME em
Flatpak, incluindo Firefox e Thunderbird:

```bash
OMAKUBA_FULL_FLATPAKS=1 ./install.sh 70-flatpaks
```

O passo `75-cli` instala o Homebrew em `/home/linuxbrew/.linuxbrew` e usa ele
para o que não tem pacote no Ubuntu: mise, chezmoi, topgrade, dysk e
podman-tui. O resto vem do APT, com `bat`, `eza`, `fd`, `ripgrep`, `fzf`, `gh`,
`zoxide`, `direnv`, `tealdeer`, `trash-cli`, `yq`, `glow` e companhia. O `uv`
entra pelo instalador oficial. O Tailscale é opcional:

```bash
OMAKUBA_TAILSCALE=1 ./install.sh 75-cli
```

O passo `80-dx` é a camada de desenvolvimento mais pesada: Podman, Distrobox,
virt-manager, Incus, Cockpit, VS Code com dev containers e as ferramentas de
Kubernetes/CNCF. Ele fica desligado por padrão:

```bash
OMAKUBA_DX=1 ./install.sh 80-dx
```

O passo `85-updates` instala o comando `omakuba` e liga um timer semanal do
systemd, que roda como o seu usuário:

```bash
omakuba update            # Flatpak, Homebrew e extensões do VS Code
omakuba update --system   # inclui o APT, com sudo
omakuba doctor            # versões e estado do ambiente
omakuba dock on           # liga o dock
omakuba dock off          # desliga o dock
omakuba dock status       # mostra se o dock está ligado
omakuba store             # abre o Bazaar
```

O timer não usa sudo. Quem cuida das atualizações de segurança do sistema é o
`unattended-upgrades` do Ubuntu, que já vem ligado.

## Cores do terminal

O Kitty, o tmux e o prompt usam a paleta Breath, que é o colorscheme que vinha
no Konsole do Manjaro. O fundo é `#1e2229`, o texto é `#17a88b` e os destaques
usam `#1abc9c`, `#f67400` e `#1d99f3`.

No 24.04 o GNOME Terminal também recebe essa paleta, com o perfil omakuba. No
26.04 o terminal padrão é o Ptyxis, que trabalha com paletas por nome, então
lá eu só ajusto fonte, cursor e opacidade.

Se quiser trocar de paleta, os hexadecimais ficam em `dotfiles/kitty.conf`,
`dotfiles/tmux.conf` e em `26.04/lib/20-terminal.sh` ou `24.04/lib/20-terminal.sh`.

## Identidade: os-release, logos, Plymouth e fastfetch

O passo `15-branding` dá nome ao sistema. Ele troca o `/etc/os-release` do
Ubuntu por um com a marca do omakuba:

```
NAME="Omakuba"
PRETTY_NAME="Omakuba Resolute Raccoon"
VERSION="Omakuba Resolute Raccoon (base Ubuntu 26.04.1 LTS)"
LOGO=omakuba
VARIANT="Omakuba"
```

O codename vem da base: no 24.04 fica `Omakuba Noble Numbat`; no 26.04,
`Omakuba Resolute Raccoon`. O `NAME` continua `Omakuba`, e o `ID`, o `VERSION_ID`
e o `UBUNTU_CODENAME` ficam como estavam, senão o APT e o resto do sistema se
perdem. No Ubuntu o `/etc/os-release` é um link para o
`/usr/lib/os-release`; o script troca o link por um arquivo de verdade, então o
`/usr/lib/os-release` continua sendo o do Ubuntu. É de lá que o
`omakuba-image-info` tira a linha "base Ubuntu ..." que aparece no fastfetch.

O logo é o do Bluefin, que entra em `/usr/share/pixmaps/omakuba.png`. Os logos
do fastfetch ficam no seu home, em `~/.local/share/omakuba/branding/logos/`, e o
`omakuba-fastfetch` sorteia um a cada execução. A config é a mesma do Bluefin,
com o mesmo layout e as mesmas cores; o que muda é a cor do acento, que segue o
acento do GNOME. O omakuba usa o acento `slate`, o mesmo do Bluefin. Para forçar
outra cor:

```bash
FASTFETCH_THEME=blue omakuba-fastfetch   # OMAKUBA_FASTFETCH_THEME também vale
omakuba fetch            # o mesmo comando, pelo atalho do omakuba
```

O mesmo dodô vira o logo do About do GNOME, sem texto. No 26.04 o
`gnome-control-center` usa `/usr/share/pixmaps/ubuntu-logo-text.svg` e
`ubuntu-logo-text-dark.svg`; no 24.04, os PNGs `ubuntu-logo-text.png` e
`ubuntu-logo-text-dark.png`. O passo grava o dodô nos dois arquivos da sua
versão e guarda os originais do Ubuntu na mesma pasta, como
`*.omakuba-backup`.

O Plymouth segue a ideia do Bluefin: o watermark do tema `spinner` vira o
dodô. No Ubuntu o tema padrão é o `bgrt`, que usa as imagens do `spinner`,
então não é preciso trocar o tema padrão. O passo roda `update-initramfs -u`
para a imagem entrar no initramfs e guarda o original em
`/usr/share/plymouth/themes/spinner/watermark.png.omakuba-backup`.

A marca também não é cravada: por padrão é `Omakuba`, mas dá para trocar sem
editar o script. O `VARIANT` sai do nome em minúsculas se você não informar:

```bash
OMAKUBA_BRAND_NAME="Meu Sistema" OMAKUBA_BRAND_VARIANT=meusistema ./install.sh 15-branding
```

O `omakuba-image-info` também é genérico: ele lê o nome e a versão do
`/etc/os-release` e só mostra a base quando ela é diferente.

O `fastfetch` normal e o `neofetch` viram um alias para o `omakuba-fastfetch` no
shell novo. Se um upgrade do `base-files` devolver o `os-release` ou os logos
do About, ou um upgrade do Plymouth devolver o watermark, basta rodar o passo
de novo:

```bash
./install.sh 15-branding
```

Se quiser voltar ao original, o backup do `os-release` está em
`~/.omakuba-backup-<data>/etc/` (ou no próprio `/usr/lib/os-release`); os logos
do About e o watermark do Plymouth ficam nos `*.omakuba-backup` ao lado dos
arquivos.

## Depois de instalar

1. Saia e entre de novo, para as extensões carregarem.
2. Rode `omakuba doctor` para ver o que entrou e o que ficou de fora.
3. Abra o terminal com `Super+Return` (Kitty) ou `Ctrl+Alt+T` (o padrão do
   sistema: Ptyxis no 26.04, GNOME Terminal no 24.04).
4. Configure seu nome e e-mail no Git, que o omakuba não mexe nisso:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "voce@exemplo.com"
   ```
5. Seus wallpapers ficam em Configurações, Aparência, Papel de parede. Basta
   jogar as imagens em `dotfiles/backgrounds/` e rodar `./install.sh 60-wallpapers`.
   Nenhum wallpaper é aplicado: o que você já usa continua, e você escolhe o
   novo quando quiser. Para aplicar um de uma vez:
   `OMAKUBA_WALLPAPER=/caminho/da/imagem ./install.sh 60-wallpapers`.
6. Na primeira vez, o Flatpak e o Homebrew podem baixar runtimes e fórmulas.
   Isso é normal e só acontece uma vez.

## Dotfiles

Tudo que é gerenciado fica em `dotfiles/` e está listado em
[DOTFILES.md](./DOTFILES.md). Se já existir um arquivo seu no destino, ele é
guardado antes em `~/.omakuba-backup-<data>/`.

## Créditos

- A filosofia de "um comando e o ambiente está pronto" veio do Omakub, mas o
  código aqui é próprio.
- O conjunto de extensões e a ideia do desktop vêm do
  [Bluefin](https://projectbluefin.io/) e da
  [Universal Blue](https://universal-blue.org/).
- Os wallpapers do Bluefin e da Universal Blue vêm do repositório
  [ublue-os/artwork](https://github.com/ublue-os/artwork).
- O `os-release`, os logos e a config do fastfetch vêm do
  [projectbluefin/common](https://github.com/projectbluefin/common), o mesmo
  lugar de onde o Bluefin tira os dele.
- Os wallpapers pessoais ficam em `dotfiles/backgrounds/`.
- A paleta Breath vem do Manjaro
  ([Manjaro Artwork, Breath](https://gitlab.manjaro.org/artwork/themes/breath)).
- O Adwaita é o tema padrão do GNOME, com o acento slate que o Bluefin usa.
- O [adw-gtk3](https://github.com/lassekongo83/adw-gtk3) deixa os apps GTK3 com
  a cara do Adwaita novo; ele vai para `/usr/share/themes`. Para os apps em
  snap, o [adw-gtk3-theme](https://snapcraft.io/adw-gtk3-theme) traz o mesmo
  tema para o `gtk-common-themes`.
- O [Accent Icons](https://github.com/taiwbi/gnome-accent-directories) faz as
  pastas acompanharem a cor do acento.
- O [Legacy (GTK3) Theme Scheme Auto Switcher](https://github.com/mukul29/legacy-theme-auto-switcher-gnome-extension)
  troca o `gtk-theme` entre `adw-gtk3` e `adw-gtk3-dark` conforme o claro/escuro.
- O ícone `preferences-ubuntu-panel` vem do tema Yaru, mas só ele é copiado para
  o hicolor; o Yaru em si não é aplicado.
