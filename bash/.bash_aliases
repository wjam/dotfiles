alias k='kubectl'
complete -o default -F __start_kubectl k

alias ll='ls -alF'

if [[ -x $(command -v terraform) ]]; then
  complete -C /usr/local/bin/terraform terraform
fi

if [[ -x $(command -v packer) ]]; then
  complete -C /usr/local/bin/packer packer
fi
