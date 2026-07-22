-- ~/.config/nvim/lua/core/filetypes.lua

local api = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

local ft = augroup('FileTypeSettings', { clear = true })

-- Tab indent, 4-wide: C, C++, Go, Bash, VimL, SQL (default: noexpandtab, ts=4)
-- Inherits global defaults

-- Space indent, 4-wide: Rust, Python, Markdown
autocmd('FileType', {
  group = ft,
  pattern = { 'rust', 'python', 'markdown' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- Space indent, 2-wide: JavaScript, TypeScript, Lua, YAML, JSON, Markdown
autocmd('FileType', {
  group = ft,
  pattern = { 'json', 'yaml', 'javascript', 'typescript', 'lua' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

-- Fold method per filetype
autocmd('FileType', {
  group = ft,
  pattern = { 'python', 'yaml' },
  callback = function()
    vim.wo.foldmethod = 'indent'
  end,
})

-- Quickfix window to bottom
autocmd('FileType', {
  group = ft,
  pattern = 'qf',
  command = 'wincmd J',
})

-- docset keywordprg
autocmd('FileType', {
  group = ft,
  pattern = { 'man', 'help' },
  callback = function()
    vim.wo.list = false
  end,
})

-- LspHover via K (replaces keywordprg, which doesn't support functions)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { silent = true })

autocmd('FileType', {
  group = ft,
  pattern = { 'c', 'man' },
  callback = function()
    vim.bo.keywordprg = ':Man'
    pcall(vim.keymap.del, 'n', 'K', { buffer = true })
  end,
})

autocmd('FileType', {
  group = ft,
  pattern = { 'vim', 'help' },
  callback = function()
    vim.bo.keywordprg = ':help'
    pcall(vim.keymap.del, 'n', 'K', { buffer = true })
  end,
})
