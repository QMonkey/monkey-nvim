local ft = vim.api.nvim_create_augroup('FileTypeSettings', { clear = true })

-- Tab indent, 4-wide: C, C++, Go, Bash, VimL, SQL (default: noexpandtab, ts=4)
-- Inherits global defaults

-- Space indent, 4-wide: Rust, Python, Markdown
vim.api.nvim_create_autocmd('FileType', {
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
vim.api.nvim_create_autocmd('FileType', {
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
vim.api.nvim_create_autocmd('FileType', {
  group = ft,
  pattern = { 'python', 'yaml' },
  callback = function()
    vim.wo.foldmethod = 'indent'
  end,
})

-- Quickfix window to bottom
vim.api.nvim_create_autocmd('FileType', {
  group = ft,
  pattern = 'qf',
  command = 'wincmd J',
})

-- docset keywordprg
vim.api.nvim_create_autocmd('FileType', {
  group = ft,
  pattern = { 'man', 'help' },
  callback = function()
    vim.wo.list = false
  end,
})

-- LspHover via K (replaces keywordprg, which doesn't support functions)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { silent = true })

vim.api.nvim_create_autocmd('FileType', {
  group = ft,
  pattern = { 'c', 'man' },
  callback = function()
    vim.bo.keywordprg = ':Man'
    pcall(vim.keymap.del, 'n', 'K', { buffer = true })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = ft,
  pattern = { 'vim', 'help' },
  callback = function()
    vim.bo.keywordprg = ':help'
    pcall(vim.keymap.del, 'n', 'K', { buffer = true })
  end,
})
