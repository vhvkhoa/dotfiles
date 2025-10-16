-- lua/configs/lsp_python.lua
-- Neovim 0.11+ native LSP config (vim.lsp.config / vim.lsp.start),
-- with a clean fallback to lspconfig for older environments.

-- ---------- Common helpers ----------
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
pcall(function()
  -- If cmp_nvim_lsp is present, enrich capabilities
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

local function already_attached(bufnr, name)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = name })
  return clients and #clients > 0
end

-- ---------- Server configs (shared) ----------
-- Ruff
local ruff_cfg = {
  name = "ruff",
  cmd = { "ruff", "server" },
  root_dir = python_root(vim.api.nvim_buf_get_name(0)),
  on_attach = function(client, bufnr)
    default_on_attach(client, bufnr)
    -- Let basedpyright own hover
    if client.server_capabilities then
      client.server_capabilities.hoverProvider = false
    end
  end,
  capabilities = caps,
  init_options = {
    settings = {
      args = { "--ignore", "ANN,F841,E501,F401" },
    },
  },
}

-- BasedPyright
local basedpyright_cfg = {
  name = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  root_dir = python_root(vim.api.nvim_buf_get_name(0)),
  on_attach = default_on_attach,
  capabilities = caps,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode   = "workspace",
        autoSearchPaths  = true,
        useLibraryCodeForTypes = false,
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

-- ---------- New API path (Neovim 0.11+) ----------
local HAS_NEW = (vim.lsp and type(vim.lsp.start) == "function")

if HAS_NEW then
  -- Define per-server configs using vim.lsp.config (if present) to register,
  -- and start them lazily on Python buffers.
  if type(vim.lsp.config) == "function" then
    vim.lsp.config("ruff", ruff_cfg)
    vim.lsp.config("basedpyright", basedpyright_cfg)
  end

  -- Autostart on Python files (no duplicates)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function(args)
      local bufnr = args.buf
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root  = python_root(fname)

      -- Refresh root_dir for this buffer
      ruff_cfg.root_dir = root
      basedpyright_cfg.root_dir = root

      if not already_attached(bufnr, "ruff") then
        vim.lsp.start(vim.tbl_extend("force", ruff_cfg, { bufnr = bufnr }))
      end
      if not already_attached(bufnr, "basedpyright") then
        vim.lsp.start(vim.tbl_extend("force", basedpyright_cfg, { bufnr = bufnr }))
      end
    end,
  })

else
  -- ---------- Fallback for older Neovim: use lspconfig without deprecation spam ----------
  -- Only require here, not at top-level (avoids the "framework deprecated" warning in newer lspconfig).
  local ok, lspconfig = pcall(require, "lspconfig")
  if ok then
    lspconfig.ruff.setup({
      cmd = ruff_cfg.cmd,
      on_attach = ruff_cfg.on_attach,
      capabilities = ruff_cfg.capabilities,
      init_options = ruff_cfg.init_options,
      root_dir = function(fname) return python_root(fname) end,
    })

    lspconfig.basedpyright.setup({
      cmd = basedpyright_cfg.cmd,
      on_attach = basedpyright_cfg.on_attach,
      capabilities = basedpyright_cfg.capabilities,
      settings = basedpyright_cfg.settings,
      root_dir = function(fname) return python_root(fname) end,
    })
  else
    vim.notify("Neither Neovim 0.11 LSP nor lspconfig available; Python LSP disabled.", vim.log.levels.WARN)
  end
end

-- (Optional) show only errors in UI globally
-- vim.diagnostic.config({
--   virtual_text  = { severity = { min = vim.diagnostic.severity.ERROR } },
--   signs         = { severity = { min = vim.diagnostic.severity.ERROR } },
--   underline     = true,
--   severity_sort = true,
-- })
