-- lua/configs/lsp_python.lua
local lspconfig = require("lspconfig")

-- Fallback on_attach with sane LSP keymaps
local function default_on_attach(_, bufnr)
  local map = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true }) end
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gD", vim.lsp.buf.declaration)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "K",  vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end)
end

local caps = vim.lsp.protocol.make_client_capabilities()
pcall(function() caps = require("cmp_nvim_lsp").default_capabilities(caps) end)

-- Ruff (built‑in LSP)
lspconfig.ruff.setup{
  cmd = { "ruff", "server" },
  on_attach = function(client, bufnr)
    default_on_attach(client, bufnr)
    client.server_capabilities.hoverProvider = false -- let basedpyright own hover
  end,
  capabilities = caps,

  init_options = {
    settings = {
      args = {
        "--ignore", "ANN,F841,E501,F401",
      }
    },
  },
}

-- BasedPyright (quiet unknown-* + milder mode)
lspconfig.basedpyright.setup{
  on_attach = on_attach,
  capabilities = caps,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",      -- global default strictness
        diagnosticMode   = "workspace",
        autoSearchPaths  = true,
        useLibraryCodeForTypes = false,

        -- globally silence the "type/return is unknown" family
        diagnosticSeverityOverrides = {
          reportUnknownParameterType = "none",
          reportUnknownArgumentType  = "none",
          reportUnknownMemberType    = "none",
          reportUnknownVariableType  = "none",
          reportUnknownLambdaType    = "none",
          reportUnknownReturnType    = "none",
        },
      },
    },
  },
}

-- (Optional) show only errors in UI globally
-- vim.diagnostic.config({
--   virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
--   signs        = { severity = { min = vim.diagnostic.severity.ERROR } },
--   underline    = true,
--   severity_sort = true,
-- })

