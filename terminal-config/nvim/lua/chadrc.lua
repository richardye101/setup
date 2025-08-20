-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.term = {
 winopts = { number = false },
 sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
 float = {
   row = 0.05, col = 0.08,
   height = 0.8, width = .8,
   border = "single",
 },
}

-- M.nvdash = { load_on_startup = true }
M.ui = {
  tabufline = {
     lazyload = false
  },
  nvimtree = {
    icons = {
      git_status = {
        symbols = {
          added     = "A",
          modified  = "M",
          deleted   = "D",
          renamed   = "R",
          untracked = "?",
          ignored   = "I",
          unstaged  = "U",  -- ← This was likely your "x"
          staged    = "✓",
          conflict  = "!",
        }
      }
    }
  }
}

return M
