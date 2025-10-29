require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<S-h>", "0", { desc = "move to beginning of line" })
map("n", "<S-l>", "<End>", { desc = "move to end of line" })
map("v", "<S-h>", "0", { desc = "move to beginning of line" })
map("v", "<S-l>", "<End>", { desc = "move to end of line" })
map("n", "<S-q>", function()
    vim.diagnostic.setqflist()
    vim.cmd "copen"
end, { desc = "Open quickfix with diagnostics" })

--- for nvchad users, this is in the ~/.config/nvim/lua/mappings.lua file

local unmap = vim.keymap.del

--- This fixes an issue with the vim-tmux-navigator + nvchad in which the base nvchad
--- mapping were conflicting with vim-tmux-navigator ones.
unmap("n", "<c-h>")
unmap("n", "<c-j>")
unmap("n", "<c-k>")
unmap("n", "<c-l>")
map("n", "<c-h>", "<cmd>:TmuxNavigateLeft<cr>")
map("n", "<c-j>", "<cmd>:TmuxNavigateDown<cr>")
map("n", "<c-k>", "<cmd>:TmuxNavigateUp<cr>")
map("n", "<c-l>", "<cmd>:TmuxNavigateRight<cr>")
map("n", "<c-\\>", "<cmd>:TmuxNavigatePrevious<cr>")

vim.api.nvim_set_keymap(
    "n",
    "<leader>Ao",
    ":AiderOpen<CR>",
    { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
    "n",
    "<leader>Am",
    ":AiderAddModifiedFiles<CR>",
    { noremap = true, silent = true }
)
-- require("nvchad.term").toggle { pos = "sp", id = "xz" }
-- require("nvchad.term").toggle { pos = "float", id = "fa", cmd ='lazygit' }
-- require("nvchad.term").toggle { pos = "vsp", id = "floo", size = 0.3 }
--
-- -- always map it in "t" i.e terminal mode too
-- vim.keymap.set({ "n", "t" }, "<A-i>", function()
--    require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
-- end)
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
