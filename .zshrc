# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# cd ~/
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

export JAVA_HOME=/opt/homebrew/Cellar/openjdk/20.0.1/libexec/openjdk.jdk/Contents/Home
export DOCKER_HOST=unix:///$HOME/.colima/docker.sock

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/Repos/setup/terminal-config/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/Repos/setup/terminal-config/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/Repos/setup/terminal-config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# setup fuzzy find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# setup keybindings, e.g ctrl+r to activate
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
setopt COMBINING_CHARS
export OPENAI_API_KEY=''

export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# Find the latexmk executable for making latex into pdfs
export PATH="/Library/TeX/texbin:$PATH"

. "$HOME/.local/bin/env"
