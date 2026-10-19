# ── 30-dev ──────────────────────────────────────────────────────────────────
# Stack: Node LTS (nvm), gerenciadores de pacote, .NET (C#) e ferramentas CLI.
export NVM_DIR="$HOME/.nvm"

# nvm (Node Version Manager) — instalação oficial via git clone.
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  skip "nvm já instalado"
else
  rm -rf "$NVM_DIR"
  if git clone --depth=1 https://github.com/nvm-sh/nvm.git "$NVM_DIR" >/dev/null 2>&1; then
    bash "$NVM_DIR/install.sh" >/dev/null 2>&1 || true
    ok "nvm instalado"
  else
    warn "nvm falhou (ignorado)"
  fi
fi

# shellcheck disable=SC1091
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" || true
if command -v nvm >/dev/null; then
  nvm install --lts >/dev/null 2>&1 && ok "Node LTS instalado: $(node --version)"
  nvm alias default lts/* >/dev/null 2>&1 || true
  nvm use default >/dev/null 2>&1 || true
else
  warn "nvm indisponível — pulando parte Node"
fi

# Globais de npm (sob o Node do nvm).
npm install -g pnpm typescript prettier >/dev/null 2>&1 \
  && ok "npm global: pnpm, typescript, prettier" || warn "npm global parcial"

# Yarn via corepack (ou yarn classic como fallback).
if command -v corepack >/dev/null 2>&1; then
  corepack enable >/dev/null 2>&1 || true
  corepack prepare yarn@stable --activate >/dev/null 2>&1 || true
  ok "yarn habilitado via corepack"
else
  npm install -g yarn >/dev/null 2>&1 && ok "yarn (classic) instalado"
fi

# .NET SDK — instala o LTS mais novo (10) e o 8 (legado comum em empresas).
for sdk in dotnet-sdk-10.0 dotnet-sdk-8.0; do
  if apt-cache show "$sdk" >/dev/null 2>&1; then
    step "instalando $sdk"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$sdk" >/dev/null
    ok "$sdk instalado"
  else
    skip "$sdk indisponível nos repos"
  fi
done

# Ferramentas globais do .NET (Entity Framework CLI + formatador C#).
if command -v dotnet >/dev/null; then
  dotnet tool install --global dotnet-ef  >/dev/null 2>&1 && ok "dotnet-ef (global)"  || skip "dotnet-ef já instalado ou falhou"
  dotnet tool install --global csharpier  >/dev/null 2>&1 && ok "csharpier (global)"  || skip "csharpier já instalado ou falhou"
else
  warn "dotnet ausente — pulando ferramentas globais"
fi