#!/usr/bin/env zsh

# Requires ~/.iterm2_shell_integration.zsh installed from https://iterm2.com/shell_integration/zsh
# and powerline-go from https://github.com/justjanne/powerline-go

zmodload zsh/datetime

function preexec() {
  __TIMER=$EPOCHREALTIME
}

function powerline_precmd() {
  local __ERRCODE=$?
  local __DURATION=0
  local __JOBS=${${(%):%j}:-0}

  if [ -n $__TIMER ]; then
    local __ERT=$EPOCHREALTIME
    __DURATION="$(($__ERT - ${__TIMER:-__ERT}))"
  fi
  eval "$(powerline-go -duration $__DURATION -error $__ERRCODE -jobs $__JOBS -shorten-eks-names)"
  unset __TIMER
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
    install_powerline_precmd
fi

# shellcheck source=../zsh/.iterm2_shell_integration.zsh
source ~/.iterm2_shell_integration.zsh
