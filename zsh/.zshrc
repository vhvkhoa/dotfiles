export TERM="xterm-256color"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

plugins=(git)

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

