# Create Symlinks
#--------------------------------------------------------------

set -euo pipefail

DOTFILES_DIR="${HOME}/software/dotfiles_desktop"

create_symlink()
{
    local source="${1}"
    local target="${2}"

    if [ -L "${target}" ]; then
        if [ "$(readlink "${target}")" = "${source}" ]; then
            echo "Already linked correctly, skipping: ${target}"
        else
            echo "WARNING: ${target} is a symlink but points to $(readlink "${target}") — skipping"
        fi
    elif [ -e "${target}" ]; then
        echo "WARNING: ${target} exists and is not a symlink — skipping"
    else
        ln -s "${source}" "${target}"
        echo "Linked: ${target}"
    fi
}

configs=(
    nvim waybar swaylock foot alacritty sway
    dunst kitty rofi yazi discord rainfrog
    spotify-player
)

for config in "${configs[@]}"; do
    create_symlink "${DOTFILES_DIR}/config/${config}" "${HOME}/.config/${config}"
done

create_symlink "${DOTFILES_DIR}/config/mimeapps.list" "${HOME}/.config/mimeapps.list"
