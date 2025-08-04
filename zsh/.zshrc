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

# Load bash_profile
if [ -f ~/.bash_profile ]; then
  . ~/.bash_profile
elif [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

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

