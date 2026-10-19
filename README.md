# omakuba

Setup que eu uso para deixar um Ubuntu pronto para trabalhar com web (Node e
TypeScript) e com C# (.NET). A ideia veio do Omakub, mas o código aqui é meu,
feito com calma e sem copiar os scripts de lá.

O repositório tem duas versões, porque cada uma pede coisas diferentes:

| Pasta | Ubuntu | Tiling |
|---|---|---|
| `24.04/` | 24.04 LTS, GNOME 46 | Forge, para quem gosta do estilo i3 |
| `26.04/` | 26.04 LTS, GNOME 50 | sem Forge, o GNOME fica do jeito padrão |

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
essa versão não instala nem configura tiling. O GNOME fica com o comportamento
padrão dele.

O resto é igual nas duas: Adwaita, Kitty, Zsh, Starship, workspaces fixos, o atalho
do Kitty e os ajustes de aparência.

O 26.04 troca o GNOME Terminal pelo Ptyxis. O script ajusta a fonte, o cursor e
a opacidade do Ptyxis, mas o terminal principal do setup continua sendo o Kitty.
A paleta Breath fica no Kitty, no tmux e no prompt, porque o Ptyxis escolhe
paleta por nome.

O .NET também muda um pouco. O 26.04 já traz o SDK 10 nos repositórios oficiais.
O SDK 8 não está lá, então o script tenta instalar e segue sem ele se não achar.
Se você precisar do 8 para um projeto antigo, o caminho é o feed da Microsoft,
explicado na página de instalação do .NET no Ubuntu.

## Passos

| Passo | O que faz |
|---|---|
| `00-base` | ferramentas do dia a dia via APT, Docker e lazygit |
| `10-fonts` | JetBrainsMono Nerd Font em `~/.local/share/fonts` |
| `20-terminal` | Kitty, Zsh como shell padrão, Starship, plugins do Zsh e um ajuste no terminal do sistema |
| `30-dev` | nvm, Node LTS, pnpm, yarn, .NET e ferramentas do dotnet |
| `40-vscode` | extensões do VS Code e merge das settings |
| `50-gnome` | extensões do GNOME, dock, workspaces e o atalho do Kitty |
| `60-wallpapers` | instala os wallpapers que você deixar em `dotfiles/backgrounds/` e aplica o Bamboo como padrão |
| `90-dotfiles` | copia os dotfiles, com backup do que já existia |

## O que você recebe

| Camada | Resultado |
|---|---|
| Janelas | no 24.04, Forge com tiling em árvore e gaps de 8px; no 26.04, o tiling padrão do GNOME |
| Desktop | Adwaita dark puro, dock enxuto com auto-hide, sem cantos quentes |
| Profundidade | Blur my Shell na barra, no dock e na visão geral |
| Métricas | Vitals com CPU, memória, disco e rede na barra |
| Energia | Caffeine para o notebook não dormir durante builds longos |
| Terminal | Kitty com a paleta Breath, Zsh, Starship, autosuggestions e highlighting |
| Node | nvm com o Node LTS, pnpm, yarn, typescript e prettier |
| C# | .NET SDK 10 (e o 8 quando o repositório tem), dotnet-ef e csharpier |
| Docker | seu usuário no grupo docker, sem precisar de sudo no dia a dia |
| Git | lazygit e tmux, mas o Git em si fica por sua conta |
| VS Code | extensões de web e C#, com settings que se misturam às suas |
| Papel de parede | os wallpapers que você colocar em `dotfiles/backgrounds/`, com o Bamboo como padrão |

## Atalhos

Valem nas duas versões:

| Atalho | O que faz |
|---|---|
| `Super+Return` | abre o Kitty |
| `Super+1..5` | troca de workspace |
| `Super+Shift+1..5` | manda a janela para outro workspace |

Só no 24.04, com o Forge:

| Atalho | O que faz |
|---|---|
| `Super+h/j/k/l` | foca a janela da esquerda, de baixo, de cima ou da direita |
| `Super+Shift+h/j/k/l` | move a janela nessa direção |
| `Super+Alt+h/l` | redimensiona |

## Extensões do GNOME

No 24.04:

- Forge, o tiling em árvore.
- Blur my Shell, para o blur da barra, do dock e da visão geral.
- Vitals, para as métricas na barra.
- Caffeine, para não suspender a máquina em builds longos.

O tiling-assistant do Ubuntu é desligado nessa versão, porque ele briga com o
Forge. Se quiser ele de volta: `gnome-extensions enable tiling-assistant@ubuntu.com`.

No 26.04:

- Blur my Shell.
- Vitals.
- Caffeine.

Essa versão não instala o Forge. Se ele tiver sobrado de uma instalação antiga,
o script desliga. O tiling-assistant do Ubuntu fica como está, porque agora não
tem conflito com nada.

No Blur my Shell eu deixo o dock com o pipeline padrão, sem os cantos
arredondados, e os popups com o pipeline arredondado, para não ficar aquele
quadrado com encaixes tortos. Em versões mais novas da extensão, que arredondam
por chave em vez de pipeline, o script usa as chaves de canto.

As extensões só entram no ar depois de sair e entrar de novo, porque no Wayland
não dá para reiniciar o shell na mão.

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
2. Abra o Kitty com `Super+Return`.
3. Configure seu nome e e-mail no Git, que o omakuba não mexe nisso:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "voce@exemplo.com"
   ```
4. Seus wallpapers ficam em Configurações, Aparência, Papel de parede. Basta
   jogar as imagens em `dotfiles/backgrounds/` e rodar `./install.sh 60-wallpapers`.
   O Bamboo, se estiver na pasta, vira o padrão.

## Dotfiles

Tudo que é gerenciado fica em `dotfiles/` e está listado em
[DOTFILES.md](./DOTFILES.md). Se já existir um arquivo seu no destino, ele é
guardado antes em `~/.omakuba-backup-<data>/`.

## Créditos

- A filosofia de "um comando e o ambiente está pronto" veio do Omakub, mas o
  código aqui é próprio.
- Os wallpapers são seus, colocados em `dotfiles/backgrounds/`.
- A paleta Breath vem do Manjaro
  ([Manjaro Artwork, Breath](https://gitlab.manjaro.org/artwork/themes/breath)).
- O Adwaita é o tema padrão do GNOME, sem customização.
