local lint = require "lint"

lint.linters_by_ft = {
    lua = { "luacheck" },
    python = { "mypy", "ruff" },
    -- haskell = { "hlint" },
    -- python = { "flake8" },
}

lint.linters.luacheck.args = {
    "--globals",
    "love",
    "vim",
    "--formatter",
    "plain",
    "--codes",
    "--ranges",
    "-",
}

lint.linters.mypy.args = {
    "--check-untyped-defs",
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
