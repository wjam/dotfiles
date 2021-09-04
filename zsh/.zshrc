zmodload zsh/datetime

export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

if [[ -e $HOME/dev/brew/bin ]]; then
  export PATH="$HOME/dev/brew/bin:$PATH"
elif [[ -e /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi
if [[ -e ~/bin ]]; then export PATH="$PATH:$HOME/bin"; fi
if [[ -e ~/.cargo/bin ]]; then export PATH="$HOME/.cargo/bin:$PATH"; fi

if type brew &>/dev/null; then
  # Brew will by default not add `curl` to the path
  export PATH="$(brew --prefix)/opt/curl/bin:$PATH"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="iterm2-powerline-go"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt HIST_IGNORE_ALL_DUPS

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  direnv # direnv hook
  docker # completion
  docker-compose # completion
  golang # completion
  helm # completion
  kubectl # completion & `k` alias
  mvn # Maven completion
  rust # completion
  rustup # completion
  systemd # completion
  zsh-interactive-cd # interactive list of directories on `cd`
  zsh-autosuggestions # auto-suggest commands based on history
  zsh-syntax-highlighting # syntax highlighting for the typed command
  auto-notify # Send a notification when long running programs end
)
# TODO:
# https://github.com/zsh-users/zsh-completions?
# https://github.com/Sbodiu-pivotal/fly-zsh-autocomplete-plugin?


source $ZSH/oh-my-zsh.sh

AUTO_NOTIFY_IGNORE+=("docker run" "docker exec" "docker logs" "vi" "dive" "k9s" "stern" "terraform console")

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
    rm -f ~/.zcompdump; compinit
fi

# make `*` slightly easier to see
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold

bindkey "\e\e[D" backward-word
bindkey "\e\e[C" forward-word

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ll='ls -alF'

if [ -d "$HOME/.bookmarks" ]; then
  # `ln -s path/to/folder` ~/.bookmarks/@folder to create a new bookmark
  export CDPATH=".:$HOME/.bookmarks:/"
  alias goto="cd -P"
fi

# Support loading bash completions, kept to a minimum to avoid performance problems
autoload bashcompinit
bashcompinit

if which vault > /dev/null; then complete -C 'vault' vault; fi

if which terraform > /dev/null; then complete -C 'terraform' terraform; fi
