# 80-dx
# A camada DX do Bluefin: containers, máquinas virtuais e as ferramentas de
# Kubernetes/CNCF. Ela é opcional porque instala bastante coisa:
#   OMAKUBA_DX=1 ./install.sh 80-dx

if [[ "${OMAKUBA_DX:-0}" != "1" ]]; then
  skip "camada DX desligada (use OMAKUBA_DX=1 ./install.sh)"
  return 0
fi

apt_install_optional \
  distrobox podman podman-compose buildah skopeo docker.io \
  virt-manager qemu-system-x86 libvirt-daemon-system virtinst \
  incus incus-client cockpit cockpit-machines cockpit-podman \
  flatpak-builder p7zip-full genisoimage numactl iotop sysprof bpftrace bcc \
  trace-cmd wtype ydotool adb fastboot edk2-ovmf libvirt-nss \
  qemu-user-static qemu-user-binfmt virt-viewer

# Grupos que dão acesso aos containers e às VMs sem sudo.
for group in docker libvirt kvm incus-admin; do
  if getent group "$group" >/dev/null 2>&1; then
    if id -nG "$USER" | tr ' ' '\n' | grep -x "$group" >/dev/null; then
      skip "você já está no grupo $group"
    else
      sudo usermod -aG "$group" "$USER"
      ok "adicionei '$USER' ao grupo $group (vale no próximo login)"
    fi
  fi
done

for svc in docker libvirtd incus; do
  if systemctl list-unit-files "$svc.service" 2>/dev/null | grep "$svc.service" >/dev/null; then
    sudo systemctl enable --now "$svc" >/dev/null 2>&1 \
      && ok "serviço $svc ativo" \
      || warn "não consegui ativar o $svc"
  fi
done

# Apps gráficos do DX.
if command -v flatpak >/dev/null 2>&1 && flatpak remote-list --user 2>/dev/null | grep '^flathub' >/dev/null; then
  DX_APPS=(
    de.leopoldluley.Clapgrep
    io.github.getnf.embellish
    io.podman_desktop.PodmanDesktop
    me.iepure.devtoolbox
    org.gnome.Builder
    com.github.tuna_os.Tavern
  )
  flatpak_install "${DX_APPS[@]}"
fi

# Ferramentas de Kubernetes/CNCF pelo Homebrew, como no Bluefin DX.
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  K8S_FORMULAS=(
    kubectl helm k9s kind kubectx k3d minikube argocd flux istioctl
    cilium-cli cosign syft grype kustomize kubeconform kubescape opa devcontainer
  )
  for f in "${K8S_FORMULAS[@]}"; do
    if brew list --formula "$f" >/dev/null 2>&1; then
      skip "$f já está no Homebrew"
    else
      run_quiet "brew install $f" brew install "$f" \
        && ok "$f instalado" \
        || warn "$f não instalou (pulei)"
    fi
  done
else
  warn "sem Homebrew eu não instalo as ferramentas de Kubernetes (pulei)"
fi

info "a camada DX só fica completa depois de sair e entrar de novo, por causa dos grupos."
