local wezterm = require 'wezterm';

local config = {}

config.keys = {
    {key = 'r',mods = 'CMD|SHIFT', action = wezterm.action.ReloadConfiguration},
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

config.font = wezterm.font 'JetBrains Mono'

return config
