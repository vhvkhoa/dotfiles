-- lua/configs/lsp_python.lua

-- 1) keep NvChad's defaults (this is important for mappings like `gd`)
require("nvchad.configs.lspconfig").defaults()

-- 2) shared stuff
local caps = vim.lsp.protocol.make_client_capabilities()
pcall(function()
  caps = require("cmp_nvim_lsp").default_capabilities(caps)
end)

local function python_root(startpath)
  local dir = startpath or vim.api.nvim_buf_get_name(0)
  local root_file = vim.fs.find(
    { "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git" },
    { upward = true, path = vim.fs.dirname(dir) }
  )[1]
  return root_file and vim.fs.dirname(root_file) or vim.loop.cwd()
end

-- helper: keep only ERROR from a specific client
local function only_errors_handler(_, result, ctx, config)
  if result and result.diagnostics then
    local filtered = {}
    for _, d in ipairs(result.diagnostics) do
      if d.severity == vim.diagnostic.severity.ERROR then
        table.insert(filtered, d)
      end
    end
    result.diagnostics = filtered
  end
  return vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
end

-- 3) ruff config
local ruff_cfg = {
  name = "ruff",
  cmd = { "ruff", "server" },
  on_attach = function(client, bufnr)
    -- nvchad defaults already made the keymaps, so no need to redefine
    if client.server_capabilities then
      client.server_capabilities.hoverProvider = false
    end
    client.handlers["textDocument/publishDiagnostics"] = only_errors_handler
  end,
  capabilities = caps,
  init_options = {
    settings = {
      args = { "--ignore", "ANN,F841,E501,F401" },
    },
  },
}

-- 4) basedpyright config (with all the silencing)
local basedpyright_cfg = {
  name = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  on_attach = function(client, bufnr)
    client.handlers["textDocument/publishDiagnostics"] = only_errors_handler
  end,
  capabilities = caps,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode   = "workspace",
        autoSearchPaths  = true,
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportUnknownParameterType = "none",
          reportUnknownArgumentType  = "none",
          reportUnknownMemberType    = "none",
          reportUnknownVariableType  = "none",
          reportUnknownLambdaType    = "none",
          reportUnknownReturnType    = "none",
          reportAttributeAccessIssue = "none",
          reportIndexIssue           = "none",
          reportGeneralTypeIssues    = "none",
          reportArgumentType         = "none",
          reportCallIssue            = "none",
          reportFunctionMemberAccess = "none",
        },
      },
    },
  },
}

-- 5) register with the new API (your Neovim was warning about old one)
if vim.lsp and type(vim.lsp.config) == "function" then
  vim.lsp.config("ruff", ruff_cfg)
  vim.lsp.config("basedpyright", basedpyright_cfg)
end

-- 6) let NvChad actually START them
-- this is the part you were missing when `gd` became dumb
vim.lsp.enable({
  "ruff",
  "basedpyright",
})

-- 7) optional: tighten root dir per buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    local bufnr = args.buf
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root  = python_root(fname)

    -- update root for these servers
    for _, name in ipairs({ "ruff", "basedpyright" }) do
      local clients = vim.lsp.get_clients({ name = name, bufnr = bufnr })
      for _, c in ipairs(clients) do
        -- some versions let you set workspace folders; simplest is to leave it
        -- or just rely on root detection above
      end
    end
  end,
})

-- 8) last-resort filter for stubborn diagnostics
local orig_set = vim.diagnostic.set
vim.diagnostic.set = function(ns, bufnr, diags, opts)
  if diags and #diags > 0 then
    local filtered = {}
    for _, d in ipairs(diags) do
      local m = d.message or ""
      if not m:match("Argument of type 'Unknown'") and
         not m:match("no overloads for .* match the provided arguments") and
         not m:match("cannot be assigned to parameter")
      then
        table.insert(filtered, d)
      end
    end
    diags = filtered
  end
  return orig_set(ns, bufnr, diags, opts)
end

