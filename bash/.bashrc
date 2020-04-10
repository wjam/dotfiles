if [[ -f ~/dev/brew/bin ]]; then export PATH="$HOME/dev/brew/bin:$PATH"; fi

if [[ -f ~/.bash_aliases ]]; then . ~/.bash_aliases; fi

eval "$(direnv hook bash)"

if [[ -e ~/bin ]]; then export PATH="$PATH:$HOME/bin"; fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
if [[ -e ~/.rvm/bin ]]; then export PATH="$PATH:$HOME/.rvm/bin"; fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if [[ -e ~/.cargo/bin ]]; then export PATH="$HOME/.cargo/bin:$PATH"; fi
