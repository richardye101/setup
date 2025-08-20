vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Only open files if they were passed as arguments and no buffers are loaded
vim.schedule(function()
  if #vim.fn.argv() > 0 and vim.fn.bufnr('%') == 1 and vim.bo[1].filetype == '' then
    vim.cmd("edit " .. vim.fn.argv()[1])
  end
end)
vim.schedule(function()
  local args = vim.fn.argv()
  if #args > 0 then
    local stat = vim.loop.fs_stat(args[1])
    if stat and stat.type == "directory" then
      vim.cmd("cd " .. args[1])

      -- Load the plugin before using its API
      require("lazy").load { plugins = { "nvim-tree.lua" } }

      -- Open NvimTree using its Lua API
      require("nvim-tree.api").tree.open()
    elseif vim.fn.bufnr('%') == 1 and vim.bo[1].filetype == '' then
      vim.cmd("edit " .. args[1])
    end
  end
end)
