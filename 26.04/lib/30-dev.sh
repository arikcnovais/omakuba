# 30-dev
# Node com nvm, gerenciadores de pacote, .NET e ferramentas do dotnet.
# No 26.04 o SDK 10 já vem nos repositórios oficiais do Ubuntu.
export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  skip "nvm já instalado"
else
  rm -rf "$NVM_DIR"
  if git clone --depth=1 https://github.com/nvm-sh/nvm.git "$NVM_DIR" >/dev/null 2>&1; then
    bash "$NVM_DIR/install.sh" >/dev/null 2>&1 || true
    ok "nvm instalado"
  else
    warn "nvm falhou (pulei)"
  fi
fi

# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" || true
if command -v nvm >/dev/null; then
  nvm install --lts >/dev/null 2>&1 && ok "Node LTS instalado: $(node --version)"
  nvm alias default lts/* >/dev/null 2>&1 || true
  nvm use default >/dev/null 2>&1 || true
else
  warn "nvm indisponível, então pulei a parte do Node"
fi

npm install -g pnpm typescript prettier >/dev/null 2>&1 \
  && ok "npm global: pnpm, typescript e prettier" \
  || warn "alguns pacotes globais do npm falharam"

# Yarn pelo corepack. Se o corepack não existir, tento o yarn classic.
if command -v corepack >/dev/null 2>&1; then
  corepack enable >/dev/null 2>&1 || true
  corepack prepare yarn@stable --activate >/dev/null 2>&1 || true
  ok "yarn habilitado pelo corepack"
else
  npm install -g yarn >/dev/null 2>&1 && ok "yarn classic instalado"
fi

# .NET 10 é o LTS que vem no 26.04. Tento o 8 também, para projetos antigos,
# mas ele não está nos repositórios padrão desta versão.
for sdk in dotnet-sdk-10.0 dotnet-sdk-8.0; do
  if apt-cache show "$sdk" >/dev/null 2>&1; then
    step "instalando $sdk"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$sdk" >/dev/null
    ok "$sdk instalado"
  else
    skip "$sdk não está nos repositórios do 26.04"
  fi
done

if command -v dotnet >/dev/null; then
  dotnet tool install --global dotnet-ef >/dev/null 2>&1 \
    && ok "dotnet-ef instalado" \
    || skip "dotnet-ef já estava instalado ou falhou"
  dotnet tool install --global csharpier >/dev/null 2>&1 \
    && ok "csharpier instalado" \
    || skip "csharpier já estava instalado ou falhou"
else
  warn "não encontrei o dotnet, então pulei as ferramentas globais"
fi
