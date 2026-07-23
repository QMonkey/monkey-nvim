-- --- mason.nvim ---
require('mason').setup()

-- --- LSP keymaps (LspAttach) ---
local lsp_attach = vim.api.nvim_create_augroup('LspAttachKeymaps', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_attach,
  callback = function(args)
    local buf = args.buf
    local bufopts = { buffer = buf, silent = true }

    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gc', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

    vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gc', function() vim.lsp.buf.declaration({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gt', function() vim.lsp.buf.type_definition({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gi', function() vim.lsp.buf.implementation({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gr', function() vim.lsp.buf.references({ reuse_win = true }) end, bufopts)

    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '[D', function() vim.diagnostic.goto_prev({ count = 999 }) end, bufopts)
    vim.keymap.set('n', ']D', function() vim.diagnostic.goto_next({ count = 999 }) end, bufopts)
    vim.keymap.set('n', '<leader>gh', function() vim.diagnostic.open_float({ scope = 'cursor' }) end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  end,
})

-- --- Server: clangd (C/C++) ---
vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--background-index-priority=background',
    '--clang-tidy',
    '--cross-file-rename',
    '--all-scopes-completion=true',
    '--completion-style=detailed',
    '--function-arg-placeholders=true',
    '--header-insertion=iwyu',
    '--header-insertion-decorators',
    '--limit-references=0',
    '--limit-results=0',
  },
  filetypes = { 'c', 'cpp' },
  root_markers = { '.git' },
})

-- --- Server: rust-analyzer ---
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = { command = 'clippy' },
      procMacro = { enable = true },
      cargo = { allFeatures = true },
    },
  },
})

-- --- Server: gopls (Go) ---
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod' },
  settings = {
    gopls = {
      analyses = {
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hoverKind = 'FullDocumentation',
      gofumpt = true,
      completeUnimported = true,
      staticcheck = true,
      usePlaceholders = true,
      completionDocumentation = true,
      codelenses = {
        generate = true,
        test = true,
        run_vulncheck_exp = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- --- Server: ts_ls (TypeScript/JavaScript) ---
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'typescript' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json' },
  settings = {
    typescript = { suggest = { completeFunctionCalls = true } },
    javascript = { suggest = { completeFunctionCalls = true } },
  },
})

-- --- Server: pylsp (Python) ---
vim.lsp.config('pylsp', {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true },
        pylint = { enabled = false },
        pycodestyle = {
          enabled = true,
          maxLineLength = 120,
          ignore = { 'E501', 'W503' },
        },
        rope_autoimport = {
          enabled = true,
          completions = { enabled = true },
          code_actions = { enabled = true },
        },
      },
    },
  },
})

-- --- Server: lua_ls (Lua) ---
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { checkThirdParty = false },
    },
  },
})

-- --- Server: bashls ---
vim.lsp.config('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' },
  root_markers = { '.shellcheckrc', '.git' },
  settings = {
    bashIde = {
      globPattern = '**/*@(.sh|.inc|.bash|.command|.bashrc|.bash_profile|.profile)',
      includeAllWorkspaceSymbols = true,
    },
  },
})

-- --- Server: vimls ---
vim.lsp.config('vimls', {
  cmd = { 'vim-language-server', '--stdio' },
  filetypes = { 'vim' },
  root_markers = { '.git' },
})

-- --- Server: marksman (Markdown) ---
vim.lsp.config('marksman', {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown' },
  root_markers = { '.marksman.toml', '.git' },
})

-- --- Server: yamlls ---
vim.lsp.config('yamlls', {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
        url = 'https://www.schemastore.org/api/json/catalog.json',
      },
      completion = true,
      hover = true,
      validate = true,
    },
  },
})

-- --- Server: jsonls ---
vim.lsp.config('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json' },
  root_markers = { '.git' },
})

-- --- CMP capabilities ---
local ok_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities() or nil

local enabled = {
  'clangd', 'rust_analyzer', 'gopls', 'ts_ls', 'pylsp',
  'lua_ls', 'bashls', 'vimls', 'marksman', 'yamlls', 'jsonls',
}
for _, name in ipairs(enabled) do
  vim.lsp.enable(name, capabilities and { capabilities = capabilities } or {})
end

-- --- Format on save / diagnostics ---
vim.diagnostic.config({
  virtual_lines = { current_line = true },
})

local format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_augroup,
  callback = function(args)
    local clients = vim.lsp.get_clients({ bufnr = args.buf })
    if #clients == 0 then
      return
    end
    vim.lsp.buf.format({ async = true, timeout_ms = 5000 })
  end,
})
