# dotfiles

Configs de Hyprland, Noctalia, kitty y zsh para Arch Linux.

## Instalar en un equipo nuevo

```sh
git clone <url-del-repo> ~/Repos/dotfiles
cd ~/Repos/dotfiles
./install.sh            # paquetes + symlinks + servicios
```

Opciones:

- `./install.sh --link` — solo crea symlinks y habilita `noctalia.service`
- `./install.sh --deps` — solo instala los paquetes de `packages.txt` (vía `paru`)

Cualquier config existente se mueve a `~/.dotfiles-backup/<fecha>/` antes de enlazar.

## Symlinks

| Destino | Repo |
|---|---|
| `~/.config/hypr` | `config/hypr` |
| `~/.config/kitty` | `config/kitty` |
| `~/.config/noctalia` | `config/noctalia` |
| `~/.config/uwsm` | `config/uwsm` |
| `~/.config/systemd/user/noctalia.service` | `config/systemd/user/noctalia.service` |
| `~/.zshrc` | `home/.zshrc` |
| `~/.p10k.zsh` | `home/.p10k.zsh` |

Al ser symlinks, `git pull` actualiza las configs al momento. Los cambios hechos
desde Noctalia (ajustes, colores) también se escriben en el repo: revisa `git status`.

## Notas

- `config/hypr/monitors.lua` lo genera `nwg-displays` y es específico de este equipo.
- Los plugins de zsh los descarga zinit solo en el primer arranque.
