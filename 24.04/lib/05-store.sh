# 05-store
# A loja gráfica do omakuba é o Bazaar, que entra pelo Flatpak no passo 70.
# Aqui eu tiro a Snap Store do caminho, mas deixo o snapd e o comando snap
# para quem usa snap pela linha de comando. O APT e os .deb continuam normais.

if command -v snap >/dev/null 2>&1; then
  if snap list snap-store >/dev/null 2>&1; then
    if run_quiet "removendo a Snap Store" sudo snap remove --purge snap-store; then
      ok "Snap Store removida"
    else
      warn "não consegui remover a Snap Store (pulei)"
    fi
  else
    skip "Snap Store já não está instalada"
  fi
else
  skip "snapd não está instalado; não tenho o que remover"
fi

# Em algumas versões o ubuntu-software é só um pacote de transição para a
# Snap Store. Removo o pacote, sem mexer no snapd.
if dpkg -s ubuntu-software >/dev/null 2>&1; then
  if run_quiet "removendo o pacote ubuntu-software" sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y ubuntu-software; then
    ok "ubuntu-software removido"
  else
    warn "não consegui remover o ubuntu-software (pulei)"
  fi
else
  skip "ubuntu-software já não está instalado"
fi

# Se sobrou o atalho da Snap Store de alguma remoção antiga, ele sai também.
if [[ -f /var/lib/snapd/desktop/applications/snap-store_snap-store.desktop ]]; then
  if sudo rm -f /var/lib/snapd/desktop/applications/snap-store_snap-store.desktop; then
    ok "atalho antigo da Snap Store removido"
  else
    warn "não consegui remover o atalho antigo da Snap Store (pulei)"
  fi
fi

if dpkg -s gnome-software >/dev/null 2>&1; then
  info "o gnome-software também está instalado; se quiser só o Bazaar: sudo apt remove gnome-software"
fi

if command -v snap >/dev/null 2>&1; then
  ok "o snap continua disponível como CLI"
else
  info "o snap não está instalado; o APT e os .deb continuam no comando"
fi

info "a loja gráfica é o Bazaar, instalado no passo 70-flatpaks"
info "o APT e os .deb continuam iguais, e o snap fica só para a linha de comando"
