# shell-config

Personal shell configuration files, managed as a git repo.

## Files

- `.bashrc` — main bash configuration

## Setup on a new machine

```bash
git clone <this-repo-url> ~/.shell-config
# Back up existing bashrc if needed
cp ~/.bashrc ~/.bashrc.backup
rm ~/.bashrc
ln -s ~/.shell-config/.bashrc ~/.bashrc
source ~/.bashrc
```
