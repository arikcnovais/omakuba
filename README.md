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
Bazaar; o snap fica só para a linha de comando, junto do APT e dos `.deb`.

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
Bluefin, o Bazaar como loja e os ajustes de aparência.

O 26.04 troca o GNOME Terminal pelo Ptyxis. O script ajusta a fonte, o cursor e
a opacidade do Ptyxis, que fica como terminal padrão do sistema. O Kitty
continua sendo o terminal principal do setup, no atalho e no dock, e a paleta
Breath fica nele, no tmux e no prompt, porque o Ptyxis escolhe paleta por nome.

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
| `20-terminal` | Kitty, Zsh como shell padrão, Starship, plugins do Zsh e ajustes no terminal do sistema (Ptyxis no 26.04, GNOME Terminal no 24.04) |
| `30-dev` | nvm, Node LTS, pnpm, yarn, .NET e ferramentas do dotnet |
| `40-vscode` | instala o VS Code pelo repositório da Microsoft, instala as extensões e faz o merge das settings |
| `50-gnome` | extensões do Bluefin, dock do Ubuntu, workspaces e atalhos |
| `60-wallpapers` | instala os wallpapers que você deixar em `dotfiles/backgrounds/` e aplica o padrão (Sunrise se já existir; senão, green forest) |
| `65-bluefin-wallpapers` | baixa os wallpapers do Bluefin e da Universal Blue, registra todos e aplica o Sunrise como padrão |
| `70-flatpaks` | Flathub, Bazaar, Flatseal, Mission Center, Gradia e os outros apps do Bluefin |
| `75-cli` | Homebrew e o pacote de ferramentas de linha de comando |
| `80-dx` | camada DX do Bluefin, com containers, VMs e Kubernetes. Só roda com `OMAKUBA_DX=1` |
| `85-updates` | comando `omakuba` e timer semanal para Flatpak e Homebrew |
| `90-dotfiles` | copia os dotfiles, com backup do que já existia |

## O que você recebe

| Camada | Resultado |
|---|---|
| Janelas | no 24.04, Forge com tiling em árvore e gaps de 8px; no 26.04, o tiling padrão do GNOME |
| Desktop | Adwaita dark puro, dock do Ubuntu na barra lateral esquerda, altura total, auto-hide, lixeira e sem cantos quentes |
| Profundidade | Blur my Shell na barra, no dock e na visão geral |
| Extensões | AppIndicator, Dash to Dock, Blur my Shell, GSConnect, Search Light, Logo Menu, Caffeine, Custom Command Menu e Bazaar Companion no 26.04 |
| Métricas | Vitals com CPU, memória, disco e rede na barra |
| Energia | Caffeine para o notebook não dormir durante builds longos |
| Loja | o Bazaar é a única loja gráfica; a Snap Store sai do caminho e o snap fica só para a linha de comando, junto do APT e dos .deb |
| Flatpak | Bazaar, Flatseal, Extension Manager, Mission Center, Gradia, Pinta, Refine, DistroShelf, Ignition, Impression e os temas adw-gtk3 |
| Terminal | Kitty com a paleta Breath, Zsh, Starship, autosuggestions e highlighting |
| Node | nvm com o Node LTS, pnpm, yarn, typescript e prettier |
| C# | .NET SDK 10 (e o 8 quando o repositório tem), dotnet-ef e csharpier |
| Docker | seu usuário no grupo docker, sem precisar de sudo no dia a dia |
| CLI | Homebrew com mise, chezmoi, topgrade, dysk e podman-tui, mais as ferramentas do dia a dia via APT |
| DX | Podman, Distrobox, virt-manager, Incus, Cockpit e as ferramentas de Kubernetes/CNCF, se você ligar a camada |
| Atualizações | `omakuba update` na mão e um timer semanal para Flatpak e Homebrew |
| Git | lazygit e tmux, mas o Git em si fica por sua conta |
| VS Code | extensões de web, C#, containers e SSH, com settings que se misturam às suas |
| Papel de parede | o Sunrise da Universal Blue como padrão, mais os wallpapers que você colocar em `dotfiles/backgrounds/` e os do Bluefin. O `green forest.jpg` fica de reserva |

## Atalhos

Valem nas duas versões:

| Atalho | O que faz |
|---|---|
| `Super+Return` | abre o Kitty |
| `Ctrl+Alt+T` | abre o terminal do sistema (Ptyxis no 26.04, GNOME Terminal no 24.04) |
| `Ctrl+Alt+Return` | abre o terminal do sistema pelo outro atalho |
| `Super+E` | abre o Nautilus numa janela nova |
| `Ctrl+Shift+Esc` | abre o Mission Center |
| `Super+Space` | abre o Search Light |
| `Super+1..5` | troca de workspace |
| `Super+Shift+1..5` | manda a janela para outro workspace |
| `Super+D` | mostra o desktop |
| `Super+Tab` | troca de aplicativo |
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
ao 51, então entra nas duas versões.

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
passo `70-flatpaks`.

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

## Depois de instalar

1. Saia e entre de novo, para as extensões carregarem.
2. Rode `omakuba doctor` para ver o que entrou e o que ficou de fora.
3. Abra o Kitty com `Super+Return`.
4. Configure seu nome e e-mail no Git, que o omakuba não mexe nisso:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "voce@exemplo.com"
   ```
5. Seus wallpapers ficam em Configurações, Aparência, Papel de parede. Basta
   jogar as imagens em `dotfiles/backgrounds/` e rodar `./install.sh 60-wallpapers`.
   O padrão é o Sunrise da Universal Blue, que entra no `65-bluefin-wallpapers`;
   o `green forest.jpg` fica de reserva. Para escolher outro de uma vez:
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
- Os wallpapers pessoais ficam em `dotfiles/backgrounds/`.
- A paleta Breath vem do Manjaro
  ([Manjaro Artwork, Breath](https://gitlab.manjaro.org/artwork/themes/breath)).
- O Adwaita é o tema padrão do GNOME, sem customização.
