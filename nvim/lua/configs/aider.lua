-- require("aider").setup {
--     auto_manage_context = true,
--     default_bindings = true,
--     debug = true,
--     vim = true,
--     ignore_buffers = {},
--     border = {
--         style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }, -- or e.g. "rounded"
--         color = "#fab387",
--     },
--
--     -- only necessary if you want to change the default keybindings. <Leader>C is not a particularly good choice. It's just shown as an example.
--     vim.api.nvim_set_keymap(
--         "n",
--         "<leader>-",
--         ":AiderOpen --no-auto-commits<CR>",
--         { noremap = true, silent = true }
--     ),
-- }

local ok, aider = pcall(require, "aider")
if not ok then
    vim.notify "aider.nvim not found!"
    return
end

aider.setup {
    auto_manage_context = true,
    default_bindings = true,
    debug = true,
    vim = true,
    ignore_buffers = {},
    border = {
        style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        color = "#fab387",
    },
}

-- 🔹 Move keymap outside of setup
vim.api.nvim_set_keymap(
    "n",
    "<leader>-",
    ":AiderOpen --no-auto-commits<CR>",
    { noremap = true, silent = true }
)
