local M = {}

-- LSP: highlight links, LspAttach keymaps, server configs and enable list
M.config = function()
  -- LSP
  vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'Search' })
  vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'Search' })
  vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'Search' })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('Lsp', { clear = true }),
    callback = function(args)
      local buf = args.buf
      local bufopts = { buffer = buf, silent = true }

      vim.keymap.set('n', 'gh', function() vim.lsp.buf.hover({ border = 'rounded' }) end, bufopts)

      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'gc', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', 'gr', function() vim.lsp.buf.references({ includeDeclaration = true }) end, bufopts)

      vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, bufopts)
      vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, bufopts)
      vim.keymap.set('n', '[D', function() vim.diagnostic.jump({ count = -999 }) end, bufopts)
      vim.keymap.set('n', ']D', function() vim.diagnostic.jump({ count = 999 }) end, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)

      local has_highlight = false
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        if client:supports_method('textDocument/documentHighlight') then
          has_highlight = true
          break
        end
      end
      if has_highlight then
        vim.api.nvim_create_autocmd('CursorHold', {
          buffer = buf,
          group = vim.api.nvim_create_augroup('Lsp', { clear = false }),
          callback = function()
            if vim.fn.getcmdtype() ~= '' then
              return
            end
            vim.lsp.buf.document_highlight()
          end,
        })
        vim.api.nvim_create_autocmd('CursorMoved', {
          buffer = buf,
          group = vim.api.nvim_create_augroup('Lsp', { clear = false }),
          callback = vim.lsp.buf.clear_references,
        })
      end
    end,
  })

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

  vim.lsp.config('zls', {
    cmd = { 'zls' },
    filetypes = { 'zig' },
    root_markers = { 'build.zig', 'build.zig.zon' },
    settings = {
      zls = {
        enable_inlay_hints = true,
        enable_snippets = true,
      },
    },
  })

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

  vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gosum', 'gotmpl' },
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

  vim.lsp.config('typescript-language-server', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'typescript' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json' },
    settings = {
      typescript = { suggest = { completeFunctionCalls = true } },
      javascript = { suggest = { completeFunctionCalls = true } },
    },
  })

  vim.lsp.config('pylsp', {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
    settings = {
      pylsp = {
        plugins = {
          black = { enabled = true },
          pylint = { enabled = false },
          -- jedi is prefix-only by default: typing a mid-word fragment like
          jedi_completion = { fuzzy = true },
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

  vim.lsp.config('lua-language-server', {
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

  vim.lsp.config('bash-language-server', {
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

  vim.lsp.config('vim-language-server', {
    cmd = { 'vim-language-server', '--stdio' },
    filetypes = { 'vim' },
    root_markers = { '.git' },
  })

  vim.lsp.config('marksman', {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown' },
    root_markers = { '.marksman.toml', '.git' },
  })

  vim.lsp.config('efm-langserver', {
    cmd = { 'efm-langserver' },
    filetypes = { 'markdown' },
    root_markers = { '.git' },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = false,
      documentDiagnostics = true,
      codeAction = false,
    },
  })

  vim.lsp.config('yaml-language-server', {
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

  vim.lsp.config('vscode-json-language-server', {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    root_markers = { '.git' },
    init_options = { provideFormatter = true },
    settings = {
      json = {
        validate = { enable = true },
      },
    },
  })

  vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

  local enabled = {
    'clangd', 'zls', 'rust_analyzer', 'gopls', 'typescript-language-server', 'pylsp', 'lua-language-server',
    'bash-language-server', 'vim-language-server', 'marksman', 'efm-langserver', 'yaml-language-server',
    'vscode-json-language-server',
  }
  for _, name in ipairs(enabled) do
    vim.lsp.enable(name)
  end

  vim.diagnostic.config({ virtual_lines = { current_line = true } })

  local format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = format_augroup,
    callback = function(args)
      local clients = vim.lsp.get_clients({ bufnr = args.buf })
      if #clients == 0 then return end
      vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
    end,
  })
end

return M
