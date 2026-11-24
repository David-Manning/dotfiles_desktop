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
        mkdir -p "$(dirname "${target}")"
        ln -s "${source}" "${target}"
        echo "Linked: ${target}"
    fi
}

configs=(
    nvim waybar swaylock foot alacritty sway
    dunst kitty rofi yazi discord rainfrog
    spotify-player vlc zshrc
)

for config in "${configs[@]}"; do
    create_symlink "${DOTFILES_DIR}/config/${config}" "${HOME}/.config/${config}"
done

create_symlink "${DOTFILES_DIR}/config/mimeapps.list" "${HOME}/.config/mimeapps.list"

# zsh only reads ~/.zshrc, so link the stub that sources ~/.config/zshrc/zshrc.zsh
rm -f "${HOME}/.zshrc"
create_symlink "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"

# CLAUDE.md default
create_symlink "${DOTFILES_DIR}/config/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
create_symlink "${DOTFILES_DIR}/config/claude/settings.json" "${HOME}/.claude/settings.json"
create_symlink "${DOTFILES_DIR}/config/claude/agents" "${HOME}/.claude/agents"

# Git config
rm -f "${HOME}/.gitconfig"
create_symlink "${DOTFILES_DIR}/config/gitconfig/gitconfig" "${HOME}/.gitconfig"

# SSH config
rm -f "${HOME}/.ssh/config"
create_symlink "${DOTFILES_DIR}/config/ssh/config" "${HOME}/.ssh/config"

