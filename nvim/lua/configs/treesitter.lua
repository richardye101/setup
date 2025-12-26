local options = {
    ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "fish",
        "javascript",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "printf",
        "python",
        "svelte",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
    },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        use_languagetree = true,
    },

    indent = { enable = true },
}
require("nvim-treesitter.configs").setup(options)
