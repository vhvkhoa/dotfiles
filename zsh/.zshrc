export TERM="xterm-256color"
export PATH="$HOME/bin:$PATH"

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

eval "$(oh-my-posh init zsh --config ~/.poshthemes/khoa_theme.omp.json)"

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

alias ls='ls -CF'
alias ll='ls -lh'               # Long list with human-readable sizes
alias la='ls -lAh'              # Include hidden files, skip . and ..
alias lS='ls -lhS'              # Sort by size
alias lt='ls -lht'              # Sort by modification time, newest first
alias ltr='ls -lhtr'            # Sort by modification time, oldest first
alias lsd='ls -l | grep "^d"'   # List only directories
alias l.='ls -d .*'             # List hidden files/folders only
alias lf='ls -l | grep "^-" '   # List only regular files
alias l1='ls -1'                # List one file per line (good for scripting)
alias lsg='ls | grep'           # Quick grep through filenames

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

