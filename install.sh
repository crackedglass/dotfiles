#!/usr/bin/env bash
#
# install.sh — symlink these dotfiles into ~/.config
#
# Usage:
#   ./install.sh           # install, backing up any existing configs
#   ./install.sh --force   # install, overwriting existing configs (no backup)
#
# Existing targets that are already correct symlinks are left untouched.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
    FORCE=1
elif [[ -n "${1:-}" ]]; then
    echo "Usage: $0 [--force]" >&2
    exit 2
fi

# Each line maps a path relative to the repo (source) to a path relative to
# $CONFIG_HOME (destination). Fields are separated by a tab.
MAPPINGS="$(cat <<'EOF'
alacritty/alacritty.toml	alacritty/alacritty.toml
alacritty/themes	alacritty/themes
helix/config.toml	helix/config.toml
helix/languages.toml	helix/languages.toml
yazi/package.toml	yazi/package.toml
yazi/theme.toml	yazi/theme.toml
yazi/flavors	yazi/flavors
zellij/config.kdl	zellij/config.kdl
EOF
)"

link_path() {
    local src="$1" dst="$2"

    mkdir -p "$(dirname "$dst")"

    # Already correctly linked — nothing to do.
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        echo "OK      $dst"
        return 0
    fi

    # Target exists (real file/dir or a symlink to somewhere else).
    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ "$FORCE" == "1" ]]; then
            rm -rf "$dst"
            echo "REPLACE $dst"
        else
            local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
            mv "$dst" "$backup"
            echo "BACKUP  $dst -> $backup"
        fi
    fi

    ln -s "$src" "$dst"
    echo "LINK    $dst -> $src"
}

while IFS=$'\t' read -r src dst; do
    [[ -z "$src" ]] && continue
    link_path "$REPO_ROOT/$src" "$CONFIG_HOME/$dst"
done <<< "$MAPPINGS"

echo
echo "Done. Configs installed to $CONFIG_HOME"
echo "Note: alacritty/alacritty.toml imports themes from ~/.config/alacritty/themes directly."
