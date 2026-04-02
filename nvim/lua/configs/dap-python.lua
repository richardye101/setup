-- local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
-- require("dap-python").setup "uv"
require("dap-python").setup ".venv/bin/python"

local map = vim.keymap.set

map("n", "<leader>dpr", function()
    require("dap-python").test_method()
end, { desc = "Run DAP Python test method" })
