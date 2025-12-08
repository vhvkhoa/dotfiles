-- lua/configs/lsp_python.lua

-- ---------- common on_attach ----------
local function default_on_attach(_, bufnr)
  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
  end
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gD", vim.lsp.buf.declaration)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "K",  vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end)
end

-- ---------- capabilities ----------
local caps = vim.lsp.protocol.make_client_capabilities()
pcall(function()
  caps = require("cmp_nvim_lsp").default_capabilities(caps)
end)

-- ---------- root detector ----------
local function python_root(startpath)
  local dir = startpath or vim.api.nvim_buf_get_name(0)
  local root_file = vim.fs.find(
    { "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", ".git" },
    { upward = true, path = vim.fs.dirname(dir) }
  )[1]
  return root_file and vim.fs.dirname(root_file) or vim.loop.cwd()
end

-- ---------- ruff ----------
local ruff_cfg = {
  name = "ruff",
  cmd = { "ruff", "server" },
  on_attach = function(client, bufnr)
    default_on_attach(client, bufnr)
    -- let basedpyright own hover
    if client.server_capabilities then
      client.server_capabilities.hoverProvider = false
    end
  end,
  capabilities = caps,
  init_options = {
    settings = {
      -- you can change ignores here
      args = { "--ignore", "ANN,F841,E501,F401" },
    },
  },
}

-- ---------- basedpyright (de-noised) ----------
local basedpyright_cfg = {
  name = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  on_attach = default_on_attach,
  capabilities = caps,
  settings = {
    basedpyright = {
      analysis = {
        -- light check
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
          reportArgumentType         = "none",  -- "argument type doesn't match" or "no overloads match"
          reportCallIssue            = "none",  -- for mismatched positional/keyword argument errors
          reportFunctionMemberAccess = "none",  -- sometimes used for os.path and Path calls
        },
      },
    },
  },
}

-- ---------- register + start ----------
local HAS_NEW = (vim.lsp and type(vim.lsp.start) == "function")

if HAS_NEW and type(vim.lsp.config) == "function" then
  -- register configs
  vim.lsp.config("ruff", ruff_cfg)
  vim.lsp.config("basedpyright", basedpyright_cfg)

  -- autostart on python
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function(args)
      local bufnr = args.buf
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root  = python_root(fname)

      ruff_cfg.root_dir = root
      basedpyright_cfg.root_dir = root

      -- avoid duplicates
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      local have_ruff, have_bp = false, false
      for _, c in ipairs(clients) do
        if c.name == "ruff" then have_ruff = true end
        if c.name == "basedpyright" then have_bp = true end
      end

      if not have_ruff then
        vim.lsp.start(vim.tbl_extend("force", ruff_cfg, { bufnr = bufnr, root_dir = root }))
      end
      if not have_bp then
        vim.lsp.start(vim.tbl_extend("force", basedpyright_cfg, { bufnr = bufnr, root_dir = root }))
      end
    end,
  })
else
  -- older Neovim that doesn't have vim.lsp.config:
  -- just start the servers manually on FileType without touching nvim-lspconfig
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function(args)
      local bufnr = args.buf
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root  = python_root(fname)

      ruff_cfg.root_dir = root
      basedpyright_cfg.root_dir = root

      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      local have_ruff, have_bp = false, false
      for _, c in ipairs(clients) do
        if c.name == "ruff" then have_ruff = true end
        if c.name == "basedpyright" then have_bp = true end
      end

      if not have_ruff then
        vim.lsp.start(vim.tbl_extend("force", ruff_cfg, { bufnr = bufnr, root_dir = root }))
      end
      if not have_bp then
        vim.lsp.start(vim.tbl_extend("force", basedpyright_cfg, { bufnr = bufnr, root_dir = root }))
      end
    end,
  })
end

-- ---------- last-resort diagnostic filter ----------
-- in case some other plugin or rogue LSP still pushes those messages
do
  local orig_set = vim.diagnostic.set
  vim.diagnostic.set = function(namespace, bufnr, diags, opts)
    if diags and #diags > 0 then
      local filtered = {}
      for _, d in ipairs(diags) do
        local msg = d.message or ""
        -- kill the pyright-style unknown spam
        if not msg:match("Argument of type 'Unknown'") and
           not msg:match("cannot be assigned to parameter") then
          table.insert(filtered, d)
        end
      end
      diags = filtered
    end
    return orig_set(namespace, bufnr, diags, opts)
  end
end

