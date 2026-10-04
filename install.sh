#!/usr/bin/env bash
# install.sh — symlink the files in this repo into $HOME
#
# Safe to re-run. For each target:
#   - already a symlink to this repo's file   -> left alone
#   - a symlink pointing somewhere else       -> replaced
#   - a real file or directory                -> moved to <target>.backup, then linked
#   - a real file AND <target>.backup exists  -> skipped with a warning
#     (an existing backup is never overwritten)
# Works from any clone location: paths are resolved from this script's directory.

set -euo pipefail

# ──────────────────────────────────────────────────────
# FILES TO LINK (repo file -> path under $HOME)
# ──────────────────────────────────────────────────────
LINKS=(
    ".bashrc:.bashrc"
    "inputrc:.inputrc"
    "vimrc:.vimrc"
    "tmux.conf:.tmux.conf"
)

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
failures=0

link_file() {
    local src="$REPO_DIR/$1"
    local dest="$HOME/$2"
    local backup="$dest.backup"

    if [[ ! -e $src ]]; then
        echo "missing  $src (not in repo)" >&2
        return 1
    fi

    # Already linked to this repo: nothing to do
    if [[ -L $dest && $dest -ef $src ]]; then
        echo "ok       $dest"
        return 0
    fi

    if [[ -L $dest ]]; then
        # Symlink to somewhere else (or dangling): no data to lose
        echo "relink   $dest (was -> $(readlink -- "$dest"))"
        rm -f -- "$dest"
    elif [[ -e $dest ]]; then
        # Real file or directory: back it up once
        if [[ -e $backup || -L $backup ]]; then
            echo "skip     $dest (real file in the way and $backup already exists)" >&2
            return 1
        fi
        mv -- "$dest" "$backup"
        echo "backup   $dest -> $backup"
    fi

    ln -s -- "$src" "$dest"
    echo "linked   $dest -> $src"
}

for entry in "${LINKS[@]}"; do
    link_file "${entry%%:*}" "${entry#*:}" || failures=$((failures + 1))
done

if (( failures > 0 )); then
    echo "$failures file(s) not linked; see messages above." >&2
    exit 1
fi
