require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<S-H>", "0", { desc = "move to beginning of line" })
map("n", "<S-L>", "<End>", { desc = "move to end of line" })
map("v", "<S-H>", "0", { desc = "move to beginning of line" })
map("v", "<S-L>", "<End>", { desc = "move to end of line" })
map("n", "<S-Q", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { desc = "Open quickfix with diagnostics" })
-- require("nvchad.term").toggle { pos = "sp", id = "xz" }
-- require("nvchad.term").toggle { pos = "float", id = "fa", cmd ='lazygit' }
-- require("nvchad.term").toggle { pos = "vsp", id = "floo", size = 0.3 }
--
-- -- always map it in "t" i.e terminal mode too
-- vim.keymap.set({ "n", "t" }, "<A-i>", function()
--    require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
-- end)
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
