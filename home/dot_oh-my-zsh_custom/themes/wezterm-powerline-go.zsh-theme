#!/usr/bin/env zsh

# Requires powerline-go from https://github.com/justjanne/powerline-go

zmodload zsh/datetime

# Emit a user var for WezTerm to pick up - https://wezfurlong.org/wezterm/config/lua/pane/get_user_vars.html
function userVar() {
  printf "\033]1337;SetUserVar=%s=%s\007" "$1" `echo -n "$2" | base64`
}

function preexec() {
  __TIMER=$EPOCHREALTIME
}

function wezterm_uservars_precmd() {
  userVar "WEZTERM_HOME" "${HOME:-}"
  if [[ "${SSH_CLIENT:-}" == "" ]]; then
    userVar "WEZTERM_SSH" "false"
  else
    userVar "WEZTERM_SSH" "true"
  fi
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
  precmd_functions+=(wezterm_uservars_precmd)
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
    install_powerline_precmd
fi

source ~/.oh-my-zsh_custom/themes/wezterm.sh
