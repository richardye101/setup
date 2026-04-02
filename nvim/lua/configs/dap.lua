local map = vim.keymap.set

map(
    "n",
    "<leader>db",
    "<cmd> DapToggleBreakpoint <CR>",
    { desc = "Toggle DAP Breakpoint" }
)

map(
    "n",
    "<leader>dr",
    "<cmd> DapContinue <CR>",
    { desc = "Start or continue DAP" }
)

map("n", "<leader>di", "<cmd> DapStepInto <CR>", { desc = "DAP Step Into" })
map("n", "<leader>do", "<cmd> DapStepOver <CR>", { desc = "DAP Step Over" })
map("n", "<leader>dO", "<cmd> DapStepOut <CR>", { desc = "DAP Step Out" })
