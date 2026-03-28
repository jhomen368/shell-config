# shell-config

Personal shell configuration, managed as a git repo and symlinked to `~/.bashrc`.

## Setup on a new machine

```bash
git clone https://github.com/jhomen368/shell-config.git ~/.shell-config
[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.backup   # backup existing bashrc (if any)
rm ~/.bashrc
ln -s ~/.shell-config/.bashrc ~/.bashrc
source ~/.bashrc
```

## Files

- `.bashrc` — main bash configuration (symlinked to `~/.bashrc`)
- `README.md` — this file
- `~/.bashrc.local` — **not committed** — machine-specific overrides (secrets, work configs, extra PATH entries)

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
| `autocd` | Type a directory path without `cd` to enter it: `~/repos/home-ops` |
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
cd ~/repos/home-ops/clusters/homenet-main/apps/jellyfin
cdg
# → ~/repos/home-ops
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

### Local overrides

If `~/.bashrc.local` exists, it is sourced at the end of `.bashrc`. Use it for machine-specific settings that should not be committed:
- API keys or tokens
- Work-specific PATH entries
- Aliases that only apply to one machine
- Private environment variables
