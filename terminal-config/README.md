The plugins listed below are the ones I use currently:
- zsh-autosuggestions
- zsh-syntax-highlighting
- powerlevel10k
- thefuck
- navi
- fzf
- autojump

Some can be installed using `brew install plugin`, whereas the others (ones with folders in this directory) only need to be added into the `~/.zshrc` file like so:

```
source /Users/richardye/Documents/GitHub/setup/terminal-config/powerlevel10k/pow
erlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source /Users/richardye/Documents/GitHub/setup/terminal-config/zsh-autosuggestio
ns/zsh-autosuggestions.zsh
source /Users/richardye/Documents/GitHub/setup/terminal-config/zsh-syntax-highli
ghting/zsh-syntax-highlighting.zsh
eval $(thefuck --alias)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/
autojump.sh
``` 

# Wezterm Lua Config

Take the `.wezterm.lua` file, and move it to `$HOME/.config/wezterm/wezterm.lua`, create the folder if needed.
