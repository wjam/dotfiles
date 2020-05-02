alias k='kubectl'
complete -o default -F __start_kubectl k

alias ll='ls -alF'

if [[ -x $(command -v terraform) ]]; then
  complete -C $(which terraform) terraform
fi

if [[ -x $(command -v packer) ]]; then
  complete -C $(which packer) packer
fi

if [[ -x $(command -v aws_finder) ]]; then
  complete -C $(which aws_finder) aws_finder
fi
