# 30-dev
# Node com nvm, gerenciadores de pacote, .NET e ferramentas do dotnet.
export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  skip "nvm já instalado"
else
  rm -rf "$NVM_DIR"
  if run_quiet "baixando o nvm" git clone --depth=1 https://github.com/nvm-sh/nvm.git "$NVM_DIR"; then
    run_quiet "instalando o nvm" bash "$NVM_DIR/install.sh" || true
    ok "nvm instalado"
  else
    warn "nvm falhou (pulei)"
  fi
fi

# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" || true
if command -v nvm >/dev/null; then
  install_node() {
    nvm install --lts
    nvm alias default 'lts/*'
  }
  if run_quiet "instalando o Node LTS" install_node; then
    nvm use default >/dev/null 2>&1 || true
    ok "Node LTS instalado: $(node --version 2>/dev/null)"
  else
    warn "não consegui instalar o Node LTS"
  fi
else
  warn "nvm indisponível, então pulei a parte do Node"
fi

run_quiet "instalando pnpm, typescript e prettier" npm install -g pnpm typescript prettier \
  && ok "npm global: pnpm, typescript e prettier" \
  || warn "alguns pacotes globais do npm falharam"

# Yarn pelo corepack. Se o corepack não existir, tento o yarn classic.
if command -v corepack >/dev/null 2>&1; then
  run_quiet "habilitando o corepack" corepack enable
  run_quiet "preparando o yarn" corepack prepare yarn@stable --activate
  ok "yarn habilitado pelo corepack"
else
  run_quiet "instalando o yarn" npm install -g yarn && ok "yarn classic instalado"
fi

# .NET: instalo o SDK 10 (LTS atual) e o 8, que ainda aparece em projetos
# antigos. Se algum não estiver nos repositórios, sigo sem ele.
for sdk in dotnet-sdk-10.0 dotnet-sdk-8.0; do
  if apt-cache show "$sdk" >/dev/null 2>&1; then
    if run_quiet "instalando $sdk" sudo env DEBIAN_FRONTEND=noninteractive \
         apt-get install -y --no-install-recommends "$sdk"; then
      ok "$sdk instalado"
    else
      warn "$sdk não instalou"
    fi
  else
    skip "$sdk não está nos repositórios"
  fi
done

if command -v dotnet >/dev/null; then
  run_quiet "instalando dotnet-ef" dotnet tool install --global dotnet-ef \
    && ok "dotnet-ef instalado" \
    || skip "dotnet-ef já estava instalado ou falhou"
  run_quiet "instalando o csharpier" dotnet tool install --global csharpier \
    && ok "csharpier instalado" \
    || skip "csharpier já estava instalado ou falhou"
else
  warn "não encontrei o dotnet, então pulei as ferramentas globais"
fi
