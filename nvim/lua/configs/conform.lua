local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
    python = { "ruff_format", "black" },
  },

  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    if ft == "python" then
      return { timeout_ms = 1500, lsp_fallback = true }
    end
    -- return nil to disable autosave-format for other filetypes
  end,
  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
