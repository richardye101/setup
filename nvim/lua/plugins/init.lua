return {
  -- Navigation with tmux
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  -- for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "python",
        "javascript",
        "typescript",
        -- Add your desired language here
      },
      highlight = {
        enable = true,
      },
    }
  },
  -- for code formatting and linting
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "black",
        "mypy",
        "ruff",
        "pyright",
      }
    }
  },
  -- For linting and code formatting
  {
    "nvimtools/none-ls.nvim",
    ft = {"python"},
    opts = function ()
      return require "configs.none-ls"
    end,
    requires = { "nvim-lua/plenary.nvim" },
  },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    opts = {}
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
              unstaged = "~",  -- ← You can change this
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
  -- python debugging
  {
    "mfussenegger/nvim-dap",
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    }
  },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
