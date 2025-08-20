require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "luals", "pyright", "mypy", "ruff" }
vim.lsp.enable(servers)
-- vim.lsp.enable({'luals', 'pyright', 'mypy', 'ruff'})

-- read :h vim.lsp.config for changing options of lsp servers 
