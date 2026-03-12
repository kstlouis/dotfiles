# Dotfiles

Personal configuration for zsh, tmux, git, oh-my-posh, and related tools. Uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management.

## Contents

| File / Dir             | Description                                               |
|------------------------|-----------------------------------------------------------|
| `.zshrc`               | Zsh configuration (Zinit, oh-my-posh, fzf, zoxide, etc.) |
| `.tmux.conf`           | Tmux config with TPM + Nord theme                         |
| `.gitconfig`           | Git configuration                                         |
| `.p10k.zsh`            | Powerlevel10k prompt theme                                |
| `.config/ohmyposh/`    | Oh-my-posh theme configs                                  |
| `.config/thefuck/`     | The Fuck alias settings                                   |

## Prerequisites

- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)

### Integrations

```bash
brew install fzf zoxide thefuck
```

### Font (for oh-my-posh)

```bash
brew install --cask font-hasklug-nerd-font
```

### Oh-my-posh

```bash
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

## Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/kstlouis/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Stow the dotfiles into `$HOME`:

   ```bash
   stow .
   ```

   Run from `~/.dotfiles`; this creates symlinks for all config files in your home directory.

3. Install tmux plugins (after first launch):

   - Start tmux and press `Prefix` + <kbd>I</kbd> to install TPM plugins

## Shell Setup

- **Zinit** – Plugin manager; auto-installs on first run
- **Oh-my-posh** – Prompt (used in iTerm; skipped in macOS Terminal)
- **Plugins** – zsh-syntax-highlighting, zsh-autosuggestions, fzf-tab, zoxide, thefuck
