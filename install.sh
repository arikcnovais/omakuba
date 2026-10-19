#!/usr/bin/env bash
#
# Atalho para não precisar lembrar qual pasta usar.
# Ele olha a versão do Ubuntu e chama o install.sh certo.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
omakuba

  ./install.sh              escolhe o script pela versão do Ubuntu
  ./install.sh --list       mostra os passos da versão atual
  ./install.sh 50-gnome     roda só um passo

Também dá para chamar direto:
  ./24.04/install.sh
  ./26.04/install.sh
EOF
  exit 0
fi

VERSION_ID=""
if [[ -r /etc/os-release ]]; then
  VERSION_ID="$(. /etc/os-release; printf '%s' "${VERSION_ID:-}")"
fi

case "$VERSION_ID" in
  24.04|26.04)
    exec "$ROOT/$VERSION_ID/install.sh" "$@"
    ;;
  *)
    printf 'Não reconheci a versão do Ubuntu (%s).\n' "${VERSION_ID:-desconhecida}" >&2
    printf 'Escolha na mão: ./24.04/install.sh ou ./26.04/install.sh\n' >&2
    exit 1
    ;;
esac
