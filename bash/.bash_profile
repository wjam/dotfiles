if [[ -f ~/.bashrc ]]; then . ~/.bashrc; fi

###
# Customise command prompt, primarily using powerline-go
###
function _update_ps1() {
  # __bp_last_ret_value will be present if iterm2 integration is in place
  lastError=${__bp_last_ret_value:-$?}
  export PS1="$(powerline-go -colorize-hostname -error ${lastError} -newline -modules 'user,host,ssh,cwd,git,jobs,exit,kube,aws' -max-width 100 -mode patched -cwd-mode fancy)"
  (exit ${lastError})
}

if [[ -e "${HOME}/.iterm2_shell_integration.bash" ]]; then
  # If iterm2 integration is in place, then we need to use the iterm2-specific `precmd_functions` variable to customise PS1
  #   otherwise the iterm2 integration will be broken
  precmd_functions+=(_update_ps1)
elif [[ "${TERM}" != "linux" ]]; then
  # $TERM is 'linux' when running via console (Ctrl+Alt+F7)
  PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
else
  PS1="\u@\h:\w\$ "
fi

##
# History configuration
##
# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=
export HISTFILESIZE=

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

if command -v brew > /dev/null && [[ -f $(brew --prefix bash-completion)/etc/bash_completion ]]; then
  . $(brew --prefix bash-completion)/etc/bash_completion
elif [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

if [[ -f ~/.iterm2_shell_integration.bash ]]; then . ~/.iterm2_shell_integration.bash; fi

# Shut Apple up about Bash being deprecated for Zsh
export BASH_SILENCE_DEPRECATION_WARNING=1

export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
