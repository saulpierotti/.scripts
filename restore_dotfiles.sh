#!/bin/bash
# Substitute all the dotfiles in the system to the ones saved in .dotifiles
# This is useful for recreating my system configuration

if [ "$(whoami)" = "root" ]; then
    USER_HOME="$(eval echo "~${SUDO_USER}")"
else
    USER_HOME="$HOME"
fi

dotfiles_root="$USER_HOME/.dotfiles/root"

# include hidden files in globbing
shopt -s dotglob

explore() {
    for element in "$1"/*; do
        if [[ "$element" == "$dotfiles_root"/*.old ]]; then
            echo "Skipping: $element"
        elif [ -f "$element" ]; then
            process "$element"
        elif [ -d "$element" ]; then
            explore "$element"
        fi
    done
}

process() {
    FILE_IN_REPO="$1"
    # remove the prefix $dotfiles_root
    FILE_IN_SYSTEM="${1/#$dotfiles_root/}"
    echo "Linking $FILE_IN_REPO to $FILE_IN_SYSTEM"
    if [ "$FILE_IN_SYSTEM" == "/etc/fstab" ]; then
        echo "Refusing to symlink /etc/fstab"
    else
        ln -sf "$FILE_IN_REPO" "$FILE_IN_SYSTEM"
    fi
}

explore "$dotfiles_root"

# /etc/fstab does not work as a symlink
echo "Restoring /etc/fstab as a copy instead of symlink..."
rm "/etc/fstab"
cp "$USER_HOME/.dotfiles/fstab" "/etc/fstab"

shopt -u dotglob
