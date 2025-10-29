return {
    {
        "joshuavial/aider.nvim",
        lazy = false,
        opts = {
            -- your configuration comes here
            -- if you don't want to use the default settings
            auto_manage_context = true, -- automatically manage buffer context
            default_bindings = true, -- use default <leader>A keybindings
            debug = false, -- enable debug logging
        },
        config = function()
            require "configs.aider"
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require "configs.lspconfig"
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "nvim-lspconfig" },
        config = function()
            require "configs.mason-lspconfig"
        end,
    },

    -- Navigation with tmux
    {
        "christoomey/vim-tmux-navigator",
        lazy = false,
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.lint"
        end,
    },
    -- for syntax highlighting

    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.treesitter"
        end,
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.lint"
        end,
    },

    {
        "rshkarin/mason-nvim-lint",
        event = "VeryLazy",
        dependencies = { "nvim-lint" },
        config = function()
            require "configs.mason-lint"
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require "configs.conform"
        end,
    },

    {
        "zapling/mason-conform.nvim",
        event = "VeryLazy",
        dependencies = { "conform.nvim" },
        config = function()
            require "configs.mason-conform"
        end,
    },
    {
        "mfussenegger/nvim-dap",
        config = function()
            require "configs.dap"
        end,
    },
    {
        "nvim-neotest/nvim-nio",
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require "configs.dap-ui"
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = {
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        config = function()
            require "configs.dap-python"
        end,
    },
    -- Used to automatically install debug-py, which is needed for python dap
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        config = function()
            require "configs.mason-dap"
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        opts = {},
    },
    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            git = {
                enable = true,
                ignore = false,
            },
            renderer = {
                icons = {
                    -- git_placement = "signcolumn",
                    glyphs = {
                        git = {
                            unstaged = "~", -- ← You can change this
                            staged = "", --"✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                },
            },
        },
    },
    -- test new blink
    -- { import = "nvchad.blink.lazyspec" },

    -- For linting and code formatting
    -- {
    --   "nvimtools/none-ls.nvim",
    --   ft = {"python"},
    --   opts = function ()
    --     return require "configs.none-ls"
    --   end,
    --   requires = { "nvim-lua/plenary.nvim" },
    -- },
}
