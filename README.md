# shell-config

Personal shell configuration, managed as a git repo and symlinked into `$HOME`.
Tested on Ubuntu 22.04 and meant to work on any Linux host with bash. Optional tools (zoxide, vim, bash-completion) are used when installed and skipped silently when they aren't.

## Setup on a new machine

```bash
git clone https://github.com/jhomen368/shell-config.git ~/.shell-config
~/.shell-config/install.sh
source ~/.bashrc
```

## install.sh

`install.sh` symlinks each file below into `$HOME`. It finds the repo from its own location, so the clone can live anywhere.

| Repo file | Linked to |
|---|---|
| `.bashrc` | `~/.bashrc` |
| `inputrc` | `~/.inputrc` |
| `vimrc` | `~/.vimrc` |
| `tmux.conf` | `~/.tmux.conf` |

Running it again is safe. For each target:

| Target state | Action |
|---|---|
| Already a symlink to this repo | Left alone (`ok`) |
| Symlink pointing somewhere else | Replaced (`relink`) |
| Real file or directory | Moved to `<target>.backup`, then linked (`backup`) |
| Real file, and `<target>.backup` already exists | Skipped with a warning, exit code 1. A backup is never overwritten. |

## Three layers

Bash config loads in three layers. Later layers override earlier ones.

| Layer | Path | Scope | Where it comes from |
|---|---|---|---|
| 1 | `~/.bashrc` (this repo) | Every machine | `install.sh` |
| 2 | `~/.bashrc.d/*.sh` | One kind of machine (WSL, dev hosts, ...) | Provisioning (e.g. Ansible) or private dotfiles |
| 3 | `~/.bashrc.local` | This machine only | Created by hand, never committed |

This repo is public. Anything machine-specific or personal (hostnames, usernames, Windows paths, WSL aliases, tokens) goes in layer 2 or 3, not here.

### `~/.bashrc.d/`

Near the end of `.bashrc`, every readable `~/.bashrc.d/*.sh` file is sourced in sorted (glob) order. Prefix names with numbers to control the order:

```
~/.bashrc.d/
├── 10-wsl.sh
└── 50-dev-tools.sh
```

Files without the `.sh` suffix are ignored. A missing or empty directory does nothing.

Snippets run after the shared defaults, so they can override them, e.g. `export EDITOR=nano`. If a snippet changes `PROMPT_COMMAND`, append to it instead of replacing it so the zoxide hook keeps working.

### `~/.bashrc.local`

Sourced last, after `~/.bashrc.d/`, so it can override everything. See [Local overrides](#local-overrides).

---

## Features

### Prompt

Format: `user@host:dir (branch)$`

The git branch is shown in **green** when the working tree is clean, and **red** when there are uncommitted changes or untracked files.

---

### History

| Setting | Value | Effect |
|---|---|---|
| `HISTSIZE` | 10,000 | Number of commands kept in memory |
| `HISTFILESIZE` | 20,000 | Number of commands saved to disk |
| `HISTTIMEFORMAT` | `"%F %T  "` (two trailing spaces) | Each entry is timestamped (e.g. `2026-03-28 20:00:00  command`) |
| `HISTCONTROL` | `ignoreboth` | Ignores duplicates and commands prefixed with a space |
| `histappend` | enabled | New sessions append to history instead of overwriting it |

Prefix a command with a space to prevent it from being saved to history — useful for one-off secrets:
```bash
 MY_SECRET_TOKEN=abc123 some-command   # leading space → not saved
```

---

### Shell Options

| Option | What it does |
|---|---|
| `autocd` | Type a directory path without `cd` to enter it: `~/repos/jhomen368/home-ops` |
| `cdspell` | Auto-corrects minor typos in `cd` paths: `cd reops` → `repos` |
| `globstar` | `**` matches files recursively: `ls **/*.yaml` lists all yaml files at any depth |
| `checkwinsize` | Keeps `$LINES`/`$COLUMNS` accurate so `less`, `man`, `vim` render correctly after terminal resize |

---

### Aliases

#### Navigation
| Alias | Expands to | Description |
|---|---|---|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `.....` | `cd ../../../..` | Go up four directories |

#### File listing
| Alias | Expands to | Description |
|---|---|---|
| `ls` | `ls --color=auto --group-directories-first` | Colorized output, folders before files |
| `ll` | `ls -lah ...` | Long format, all hidden files, human-readable sizes (KB/MB/GB) |
| `la` | `ls -A ...` | All files including hidden, skips `.` and `..` |
| `l` | `ls -CF ...` | Compact columnar list, `/` appended to directories |

#### Search
| Alias | Expands to | Description |
|---|---|---|
| `grep` | `grep --color=auto` | Highlights matched text in the output |
| `fgrep` | `fgrep --color=auto` | Fixed-string search (no regex, faster for literal text) |
| `egrep` | `egrep --color=auto` | Extended regex search |

---

### Functions

#### `cdg`
Jump to the root of the current git repository from anywhere inside it:
```bash
cd ~/repos/jhomen368/home-ops/some/deeply/nested/folder
cdg
# → ~/repos/jhomen368/home-ops
```

#### `mkcd <dir>`
Create a directory (including any missing parents) and immediately `cd` into it:
```bash
mkcd my-new-project
# Same as: mkdir -p my-new-project && cd my-new-project
```

#### `extract <archive> [destination]`
Universal archive extractor — automatically detects the format and runs the correct tool.

Supported formats: `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.tar.zst`, `.tar`, `.gz`, `.bz2`, `.zip`, `.Z`, `.7z`, `.rar`, `.xz`, `.zst`

```bash
extract archive.tar.gz              # extract to current directory
extract archive.tar.gz ./my-folder  # extract to a specific directory (created if needed)
```

> **Tip:** Before extracting an unknown archive, check its contents first to avoid "tarbombs" (archives that dump files directly into the current directory):
> ```bash
> tar -tzf archive.tar.gz   # list contents of .tar.gz
> unzip -l archive.zip      # list contents of .zip
> ```

---

### Colorized `man` pages

`man` pages are rendered with colors via `LESS_TERMCAP_*` variables — bold text in yellow, underlines in green, status bar highlighted.

---

### Editor

`EDITOR` and `VISUAL` default to `vim`. A value already in the environment wins, and a `~/.bashrc.d/` snippet or `~/.bashrc.local` can set something else. If vim isn't installed, both stay unset and programs use their own fallback.

---

### Tab completion

`.bashrc` loads bash-completion (`/usr/share/bash-completion/bash_completion`, or `/etc/bash_completion` on older systems), as Ubuntu's stock `.bashrc` does. It skips this if bash-completion is already loaded, isn't installed, or bash runs in POSIX mode. Completions for individual commands such as `git` load the first time you press Tab after them.

`inputrc` adds these readline settings on top of `/etc/inputrc`:

| Setting | Effect |
|---|---|
| `completion-ignore-case on` | `cd doc<Tab>` completes `Documents` |
| `show-all-if-ambiguous on` | One Tab lists all matches (default needs two) |
| Up / Down arrows | Search history for commands that start with what you've typed. On an empty line they work as usual. |

---

### zoxide

If [zoxide](https://github.com/ajeetdsouza/zoxide) is installed, `z` jumps to frequently used directories by partial name (`z home-ops`). Without zoxide, nothing is loaded and nothing is printed.

---

### vim

`vimrc` sets minimal defaults and uses no plugins: syntax highlighting and filetype indent, line numbers, 4-space indent with spaces, incremental and highlighted search, and case-insensitive search unless the pattern has a capital letter. The syntax and filetype lines are wrapped in `if has(...)`, so `vim.tiny` loads the file without errors.

---

### tmux

`tmux.conf` sets minimal defaults and uses no plugins. It needs tmux 2.1 or newer.

| Setting | Effect |
|---|---|
| `mouse on` | Click to select panes and windows, drag to resize, scroll to see history |
| `history-limit 50000` | Scrollback per pane (default 2000) |
| `base-index 1`, `pane-base-index 1` | Windows and panes are numbered from 1 |
| `renumber-windows on` | Closing a window renumbers the rest, so there are no gaps |

---

### Local overrides

If `~/.bashrc.local` exists, `.bashrc` sources it last, after `~/.bashrc.d/`, so it overrides everything else. Use it for settings that belong to this one machine and must not be committed:
- API keys or tokens
- Work-specific PATH entries
- Aliases that only apply to one machine
- Private environment variables
