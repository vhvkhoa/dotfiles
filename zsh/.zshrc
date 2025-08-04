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

alias ls='ls --color=auto'
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
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} 'ma=1;36'  # match=cyan bold

# Nice grouping headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{8}%d%f'

# Optional: vim-like movement in the completion menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/khoavo/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/khoavo/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/khoavo/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/khoavo/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
