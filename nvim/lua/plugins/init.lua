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
      require "configs.lsp_python"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "basedpyright",
        "ruff",
        "black",
      }
    }
  },

  {
   	"nvim-treesitter/nvim-treesitter",
   	opts = {
   		ensure_installed = {
   			"vim", "lua", "vimdoc",
        "html", "css", "python",
   		},
   	},
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      local ok_luasnip, luasnip = pcall(require, "luasnip")
      local sm = require("supermaven-nvim.completion_preview")

      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        elseif ok_luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<C-]>"] = cmp.mapping(function(fallback)
        if sm and sm.has_suggestion() then
          sm.on_accept_suggestion()
        elseif cmp.visible() then
          cmp.confirm({ select = true })
        elseif ok_luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif ok_luasnip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" })

      -- Optional: Enter just inserts a newline
      opts.mapping["<CR>"] = cmp.mapping(function(fallback)
        fallback()
      end, { "i", "s" })

      return opts
    end,
  },

  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        -- Optional settings
        keymaps = {
          accept_suggestion = "<C-]>",
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
