#!/usr/bin/env zsh

# Requires powerline-go from https://github.com/justjanne/powerline-go

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

  local __THEME="default"
  local __APPEARANCE="$(cat ~/.config/powerline-go/appearance.txt)"
  if [ "light" = "${__APPEARANCE}" ]; then
    __THEME="low-contrast"
  fi

  eval "$(powerline-go -theme $__THEME -duration $__DURATION -error $__ERRCODE -jobs $__JOBS)"
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

source ~/.oh-my-zsh_custom/themes/wezterm.sh
