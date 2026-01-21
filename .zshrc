# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/Repos/setup/terminal-config/powerlevel10k/powerlevel10k.zsh-theme
source ~/Repos/setup/terminal-config/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/Repos/setup/terminal-config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# cd ~/
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

export JAVA_HOME=/opt/homebrew/Cellar/openjdk/20.0.1/libexec/openjdk.jdk/Contents/Home

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# setup fuzzy find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# setup keybindings, e.g ctrl+r to activate
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

source "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# Find the latexmk executable for making latex into pdfs
export PATH="/Library/TeX/texbin:$PATH"

# so that when i ssh into machines, they don't see `xterm-ghostty` since they may not recognize it.
export TERM=xterm-256color

# . "$HOME/.local/bin/env"

# add posgresql to path, homebrew doesn't actually do it because there could be other postgresql versions
# export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
export PATH="/Users/richardye/.local/bin:$PATH"


#### Work related items
setopt COMBINING_CHARS
export OPENAI_API_KEY=''
