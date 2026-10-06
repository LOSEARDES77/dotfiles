#!/usr/bin/env bash
# Replica el setup en Arch Linux: instala dependencias y enlaza las configs
# con symlinks hacia este repo (un `git pull` actualiza todo).
#
# Uso: ./install.sh            # paquetes + symlinks + servicios
#      ./install.sh --link     # solo symlinks + servicios
#      ./install.sh --deps     # solo paquetes
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# destino (relativo a $HOME) -> origen (relativo al repo)
LINKS=(
    ".config/hypr:config/hypr"
    ".config/kitty:config/kitty"
    ".config/noctalia:config/noctalia"
    ".config/uwsm:config/uwsm"
    ".config/systemd/user/noctalia.service:config/systemd/user/noctalia.service"
    ".zshrc:home/.zshrc"
    ".p10k.zsh:home/.p10k.zsh"
)

info() { printf '\e[1;34m::\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m!!\e[0m %s\n' "$*"; }

install_aur_helper() {
    command -v paru >/dev/null && return
    info "Instalando paru"
    sudo pacman -S --needed --noconfirm base-devel git
    if pacman -Si paru >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm paru
        return
    fi
    local tmp
    tmp="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
}

install_packages() {
    [[ -f /etc/arch-release ]] || { warn "No es Arch Linux, salto paquetes"; return; }
    install_aur_helper
    local pkgs
    mapfile -t pkgs < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$DOTFILES/packages.txt" | grep -v '^$')
    info "Instalando ${#pkgs[@]} paquetes"
    paru -Syu --needed --noconfirm "${pkgs[@]}"
}

link() {
    local dst="$HOME/$1" src="$DOTFILES/$2"
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        info "OK      ~/$1"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$1")"
        mv "$dst" "$BACKUP_DIR/$1"
        warn "Backup  ~/$1 -> $BACKUP_DIR/$1"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "Enlace  ~/$1 -> $src"
}

link_all() {
    for entry in "${LINKS[@]}"; do
        link "${entry%%:*}" "${entry#*:}"
    done
}

setup_services() {
    command -v systemctl >/dev/null || return
    systemctl --user daemon-reload || true
    systemctl --user enable noctalia.service || warn "No se pudo habilitar noctalia.service"
}

setup_shell() {
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    [[ -n "$zsh_path" ]] || return
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
        info "Cambiando shell por defecto a zsh"
        chsh -s "$zsh_path"
    fi
}

main() {
    local deps=1 links=1
    case "${1:-}" in
        --link) deps=0 ;;
        --deps) links=0 ;;
        "") ;;
        *) echo "Uso: $0 [--link|--deps]"; exit 1 ;;
    esac

    ((deps)) && install_packages
    if ((links)); then
        link_all
        setup_services
        setup_shell
    fi
    info "Listo. Inicia sesión con: uwsm start hyprland.desktop"
}

main "$@"
