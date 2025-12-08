export TERM="xterm-256color"
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Plugins
ZSH_PLUGINS="$HOME/.zsh_plugins"

# Syntax Highlighting
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Autosuggestions
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

bindkey -v
bindkey '^R' history-incremental-search-backward

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# --- Vi-mode cursor shape indicator ---
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    # block cursor for NORMAL mode
    echo -ne '\e[2 q'
  else
    # beam cursor for INSERT mode
    echo -ne '\e[6 q'
  fi
}
function zle-line-init { zle -K viins; echo -ne '\e[6 q'; }
zle -N zle-keymap-select
zle -N zle-line-init

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

if command -v ls >/dev/null 2>&1; then
  if ls --color=auto -d . >/dev/null 2>&1; then
    # GNU coreutils (Linux, Homebrew coreutils 'gls' symlinked as ls)
    alias ls='ls --color=auto -F'
  else
    # BSD ls (macOS): use -G and CLICOLOR/LSCOLORS
    export CLICOLOR=1
    # Pleasant BSD palette; tweak to taste
    export LSCOLORS="Exfxcxdxbxegedabagacad"
    alias ls='ls -GF'
  fi
fi

# Friendly variants
alias ll='ls -lh'               # long, human sizes
alias la='ls -lAh'              # include dotfiles, skip . and ..
alias lS='ls -lhS'              # sort by size
alias lt='ls -lht'              # sort by mtime (newest first)
alias ltr='ls -lhtr'            # sort by mtime (oldest first)
alias lsd='ls -l | grep "^d"'   # only directories
alias l.='ls -d .*'             # only dotfiles/dirs
alias lf='ls -l | grep "^-" '   # only regular files
alias l1='ls -1'                # one per line
alias lsg='ls | grep'           # quick grep

alias g='git'
alias gs='git status -sb'                # Short status (shows branch + changes)
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -am'              # Commit with staged & tracked changes
alias gcm='git commit -m'               # Common pattern
alias gco='git checkout'
alias gcb='git checkout -b'             # Create and switch to new branch
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease' # Safer force push

alias grep='grep --color=auto'

# --- Safer pasting (prevents accidental execution; keeps paste editable) ---
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Ensure Backspace deletes across lines in vi insert mode
bindkey -M viins '^?' backward-delete-char

# Handy: edit the whole command in $EDITOR (default binding: Ctrl-X Ctrl-E)
autoload -Uz edit-command-line
zle -N edit-command-line
# Optional extra binding
bindkey -M viins '^[e' edit-command-line   # Alt-e to edit current line

# --- Colorful, interactive completion menu ---
zmodload zsh/complist

# Use a scrollable, selectable menu on Tab
zstyle ':completion:*' menu select

# Use LS_COLORS to color completion items (dir/file/etc.) and color matches
# If dircolors exists, prime LS_COLORS first
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi
zmodload zsh/complist
zstyle ':completion:*' menu select
# keep LS_COLORS for file types, but make the CURRENT selection white-on-blue & bold
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;27;38;5;231;1'

# Nice grouping headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{8}%d%f'

# Optional: vim-like movement in the completion menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

eval "$(starship init zsh)"
