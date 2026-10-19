# omakuba

**Setup de desenvolvimento para Ubuntu 24.04 (GNOME + Yaru), no estilo Omakub — escrito do zero, sem nenhum componente do Omakub.**

Um instalador único e idempotente que deixa a máquina pronta para
desenvolvedores **web (Node/TypeScript)** e **C# (.NET)**, com sensação de
gerenciador de janelas em tiles (i3) dentro do GNOME, mantendo o **Yaru** como
tema e deixando tudo minimalista.

```
./install.sh                 # instala tudo
./install.sh --list          # lista os passos
./install.sh 50-gnome        # instala só um passo
```

---

## O que você recebe

| Camada | Resultado |
|---|---|
| **Janelas (i3-like)** | Extensão **Forge**: tiling em árvore, navegação estilo vim (`Super`+`hjkl`), gaps de 8px, workspaces fixos como i3 |
| **Desktop minimal** | Yaru preservado (dark), dock enxuto com auto-hide sobre o wallpaper, sem cantos quentes, favoritos reduzidos |
| **Profundidade visual** | **Blur my Shell** (barra/dock/visão geral), **Vitals** (CPU/RAM/rede/disco na barra) |
| **Energia** | **Caffeine**: impede suspensão durante builds/testes longos |
| **Terminal** | **Kitty** (`Super+Return`) com a paleta **Breath** (Manjaro); **GNOME Terminal** com o mesmo visual (perfil “omakuba”); **Zsh** + **Starship** + autosuggestions/highlight; fonte **JetBrainsMono Nerd Font** |
| **Node/JS** | **nvm** + Node LTS, `pnpm`, `yarn`, `typescript`, `prettier` |
| **C#/.NET** | **SDK 10 + 8**, `dotnet-ef`, `csharpier` |
| **Docker** | usuário no grupo `docker` (builds com `docker compose` sem `sudo`) |
| **Git/fluxo** | **lazygit** (TUI), **tmux** para sessões longas |
| **VS Code** | conjunto enxuto de extensões (C#, ESLint, Prettier, Docker…) + settings minimalistas |
| **Fundo de tela** | pack de wallpapers **dinâmicos** (mudam com o horário), com um dark minimal aplicado por padrão |

---

## Passos

| Passo | O que faz |
|---|---|
| `00-base` | APT: ferramentas base (curl, jq, fzf, ripgrep, bat, tmux, vim…), Docker ativo, usuário no grupo `docker`, **lazygit** |
| `10-fonts` | **JetBrainsMono Nerd Font** em `~/.local/share/fonts` |
| `20-terminal` | **kitty** + **zsh** (como shell padrão) + **starship** + 3 plugins de zsh + perfil escuro do **GNOME Terminal** |
| `30-dev` | **nvm** + Node LTS + `pnpm`/`yarn`/`tsc`/`prettier`; **.NET SDK 10 + 8**; `dotnet-ef`; `csharpier` |
| `40-vscode` | extensões do VS Code + **merge** das settings (suas escolhas nunca são sobrescritas) |
| `50-gnome` | extensões (Forge, Blur my Shell, Vitals, Caffeine), dock/superfícies polidos, teclas estilo i3, `Super+Return` → kitty |
| `60-wallpapers` | instalador oficial dos wallpapers dinâmicos + aplica um dark minimal |
| `90-dotfiles` | deploy dos dotfiles versionados (com backup do que já existir) |

O instalador pode ser rodado **quantas vezes quiser**: tudo é idempotente.

---

## Atalhos (estilo i3)

| Atalho | Ação |
|---|---|
| `Super+Return` | abrir o **Kitty** |
| `Super+1..5` | trocar de workspace |
| `Super+Shift+1..5` | mandar a janela para outro workspace |
| `Super+h/j/k/l` | focar janela à esquerda/baixo/cima/direita (padrão do Forge) |
| `Super+Shift+h/j/k/l` | mover a janela nessa direção |
| `Super+Alt+h/l` | redimensionar (padrão do Forge — ajustável nas preferências) |

> As extensões do GNOME entram em vigor **após logout/login** (Wayland não
> reinicia o shell com `Alt+F2 → r`). Ao logar de novo o Forge começa ativo.

### Extensões escolhidas (só modernas)

- **Forge** — tiling em árvore, o "i3 dentro do GNOME".
- **Blur my Shell** — blur sutil na barra superior, dock e Visão Geral.
- **Vitals** — CPU, RAM, rede e disco na barra superior.
- **Caffeine** — impede a suspensão do laptop em builds longos.

O **tiling-assistant** (que já existia na máquina) é **desativado** para não
concorrer com o Forge. Para reativar:
`gnome-extensions enable tiling-assistant@ubuntu.com`.

### Cores do terminal: Breath (Manjaro)

Kitty, GNOME Terminal, tmux e o prompt usam a paleta **Breath** — o colorscheme
oficial do Konsole do Manjaro: fundo `#1e2229`, primeiro plano `#17a88b` e
destaques em `#1abc9c` / `#f67400` / `#1d99f3`. Os hexadecimais vivem em
`dotfiles/kitty.conf`, `dotfiles/tmux.conf` e no passo `lib/20-terminal.sh`,
então trocar de paleta é editar 3 lugares (ou só o `kitty.conf`, se você usa
apenas o Kitty).

---

## Depois de instalar

1. **Logout/login** (as extensões só entram em vigor no próximo login).
2. Dê um `Ctrl+Alt+T`… ou melhor: **`Super+Return`** para o Kitty.
3. Configure sua identidade do Git — o omakuba **não mexe** nisso (é pessoal):
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "voce@exemplo.com"
   ```
4. Mais wallpapers: **Configurações › Fundo de tela** (o pack é grande e
   vários são dinâmicos — mudam ao longo do dia).

---

## Dotfiles

Tudo que é gerenciado está versionado aqui em `dotfiles/` e catalogado em
**[DOTFILES.md](./DOTFILES.md)**. Arquivos seus existentes são salvos em
`~/.omakuba-backup-<data>/` antes de qualquer sobrescrita.

---

## Créditos

- Filosofia/inspiração: o formato "um comando deixa o ambiente pronto" do
  Omakub — porém **todo código aqui é próprio**, sem copy-paste dos scripts dele.
- Wallpapers dinâmicos: [Chillsmeit/linux-dynamic-wallpapers](https://github.com/Chillsmeit/linux-dynamic-wallpapers)
  (instalados pelo script oficial do próprio repositório).
- Paleta **Breath**: colorscheme oficial do Manjaro
  ([Manjaro Artwork › Breath](https://gitlab.manjaro.org/artwork/themes/breath)),
  convertido do formato do Konsole para os terminais usados aqui.
- Yaru é tema do Ubuntu e permanece intacto.