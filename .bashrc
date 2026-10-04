# ~/.bashrc — managed from ~/.shell-config/.bashrc
# Installed as a symlink by install.sh (ln -s <repo>/.bashrc ~/.bashrc)
#
# Load order:
#   1. this file              shared by every machine
#   2. ~/.bashrc.d/*.sh       per kind of machine (sorted, optional)
#   3. ~/.bashrc.local        this machine only, never committed (optional)

# ──────────────────────────────────────────────────────
# If not running interactively, don't do anything
# ──────────────────────────────────────────────────────
case $- in
    *i*) ;;
      *) return;;
esac

# ──────────────────────────────────────────────────────
# HISTORY
# ──────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T  "     # Timestamp each history entry
HISTCONTROL=ignoreboth        # Ignore duplicates and space-prefixed commands
shopt -s histappend           # Append to history file, don't overwrite

# ──────────────────────────────────────────────────────
# SHELL OPTIONS
# ──────────────────────────────────────────────────────
shopt -s autocd               # Type a directory name to cd into it
shopt -s cdspell              # Auto-correct minor typos in cd
shopt -s checkwinsize         # Update LINES/COLUMNS after each command
shopt -s globstar             # ** glob matches recursively

# ──────────────────────────────────────────────────────
# EDITOR
# Defaults only: an existing EDITOR/VISUAL (from the environment or a
# drop-in) wins. Skipped when vim isn't installed.
# ──────────────────────────────────────────────────────
if command -v vim >/dev/null 2>&1; then
    export EDITOR="${EDITOR:-vim}"
    export VISUAL="${VISUAL:-vim}"
fi

# ──────────────────────────────────────────────────────
# PROMPT (PS1)
# Colors: git branch is green when clean, red when dirty
# Format: user@host:dir (branch)$
# ──────────────────────────────────────────────────────
__git_branch_ps1() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    local dirty=""
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        dirty=1
    fi
    if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
        dirty=1
    fi
    if [[ -n $dirty ]]; then
        printf ' \001\033[0;31m\002(%s)\001\033[0m\002' "$branch"
    else
        printf ' \001\033[0;32m\002(%s)\001\033[0m\002' "$branch"
    fi
}

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_branch_ps1)\$ '

# ──────────────────────────────────────────────────────
# COLORS
# ──────────────────────────────────────────────────────
# Enable color support for ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Colorize grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Colorize man pages
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;33m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'

# ──────────────────────────────────────────────────────
# LS ALIASES
# ──────────────────────────────────────────────────────
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lah --color=auto --group-directories-first'
alias la='ls -A --color=auto --group-directories-first'
alias l='ls -CF --color=auto'

# ──────────────────────────────────────────────────────
# NAVIGATION
# ──────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Jump to the root of the current git repository
cdg() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not in a git repo"; return 1; }
    cd "$root"
}

# ──────────────────────────────────────────────────────
# FUNCTIONS
# ──────────────────────────────────────────────────────

# Create a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Universal extract function with optional destination directory
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <archive> [destination]"
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    local dest="$2"
    if [[ -n "$dest" ]]; then
        mkdir -p "$dest"
        case "$1" in
            *.tar.bz2)   tar xjf "$1" -C "$dest"           ;;
            *.tar.gz)    tar xzf "$1" -C "$dest"           ;;
            *.tar.xz)    tar xJf "$1" -C "$dest"           ;;
            *.tar.zst)   tar --zstd -xf "$1" -C "$dest"    ;;
            *.tar)       tar xf "$1" -C "$dest"            ;;
            *.bz2)       bunzip2 -c "$1" > "$dest/$(basename "${1%.bz2}")" ;;
            *.gz)        gunzip -c "$1" > "$dest/$(basename "${1%.gz}")" ;;
            *.zip)       unzip "$1" -d "$dest"             ;;
            *.Z)         uncompress -c "$1" > "$dest/$(basename "${1%.Z}")" ;;
            *.7z)        7z x "$1" -o"$dest"               ;;
            *.rar)       unrar x "$1" "$dest/"             ;;
            *.xz)        xz -c -d "$1" > "$dest/$(basename "${1%.xz}")" ;;
            *.zst)       unzstd "$1" -o "$dest/$(basename "${1%.zst}")" ;;
            *)           echo "Don't know how to extract '$1'" ;;
        esac
    else
        case "$1" in
            *.tar.bz2)   tar xjf "$1"      ;;
            *.tar.gz)    tar xzf "$1"      ;;
            *.tar.xz)    tar xJf "$1"      ;;
            *.tar.zst)   tar --zstd -xf "$1" ;;
            *.tar)       tar xf "$1"       ;;
            *.bz2)       bunzip2 "$1"      ;;
            *.gz)        gunzip "$1"       ;;
            *.zip)       unzip "$1"        ;;
            *.Z)         uncompress "$1"   ;;
            *.7z)        7z x "$1"         ;;
            *.rar)       unrar x "$1"      ;;
            *.xz)        unxz "$1"         ;;
            *.zst)       unzstd "$1"       ;;
            *)           echo "Don't know how to extract '$1'" ;;
        esac
    fi
}

# ──────────────────────────────────────────────────────
# COMPLETION
# Load bash-completion (as Ubuntu's default .bashrc does) unless it is
# already loaded or bash runs in POSIX mode.
# ──────────────────────────────────────────────────────
if ! shopt -oq posix && [[ -z ${BASH_COMPLETION_VERSINFO-} ]]; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        # shellcheck source=/dev/null
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        # shellcheck source=/dev/null
        source /etc/bash_completion
    fi
fi

# ──────────────────────────────────────────────────────
# OPTIONAL TOOLS (skipped silently when not installed)
# ──────────────────────────────────────────────────────
# zoxide: smarter cd (z <partial-name>)
command -v zoxide >/dev/null && eval "$(zoxide init bash)"

# ──────────────────────────────────────────────────────
# DROP-INS (per kind of machine, e.g. WSL or dev hosts)
# ──────────────────────────────────────────────────────
# Source every readable ~/.bashrc.d/*.sh in sorted order. These files are
# placed by provisioning tools or private dotfiles, not by this repo.
# No-op when the directory is missing or empty.
if [[ -d ~/.bashrc.d ]]; then
    for __bashrc_d_file in ~/.bashrc.d/*.sh; do
        # An unmatched glob stays literal and fails the -f test
        if [[ -f $__bashrc_d_file && -r $__bashrc_d_file ]]; then
            # shellcheck source=/dev/null
            source "$__bashrc_d_file"
        fi
    done
    unset __bashrc_d_file
fi

# ──────────────────────────────────────────────────────
# LOCAL OVERRIDES (machine-specific, not committed)
# Sourced last so it can override everything above.
# ──────────────────────────────────────────────────────
# Source a local bashrc for machine-specific settings that you
# don't want committed (e.g. secrets, PATH additions, work configs)
if [[ -f ~/.bashrc.local ]]; then
    source ~/.bashrc.local
fi
