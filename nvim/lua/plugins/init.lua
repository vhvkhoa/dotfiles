return {
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
   	"nvim-treesitter/nvim-treesitter",
   	opts = {
   		ensure_installed = {
   			"vim", "lua", "vimdoc",
        "html", "css"
   		},
   	},
  },

  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        -- Optional settings
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion  = "<C-k>",
          accept_word       = "<C-j>",
          next_suggestion   = "<C-l>",
          prev_suggestion   = "<C-h>",
        },
        disable_inline_completion = false,
        disable_keymaps = false,
      })
    end,
  },
}
