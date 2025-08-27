require("mason-nvim-dap").setup {
    -- python is actually debugpy
    ensure_installed = { "python" },
    automatic_installation = { exclude = {} },
}
