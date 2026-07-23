-- Relative number toggle in active normal mode
local relnum = vim.api.nvim_create_augroup('RelativeNumber', { clear = true })
vim.api.nvim_create_autocmd({ 'WinEnter', 'InsertLeave' }, {
  group = relnum,
  command = 'set relativenumber',
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'InsertEnter' }, {
  group = relnum,
  command = 'set norelativenumber number',
})

-- Cursorline toggle (disabled in insert mode)
local curline = vim.api.nvim_create_augroup('CursorLine', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = curline,
  command = 'set nocursorline',
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = curline,
  command = 'set cursorline',
})

-- Paste mode (disable on leaving insert)
local paste = vim.api.nvim_create_augroup('PasteMode', { clear = true })
vim.api.nvim_create_autocmd('InsertLeave', {
  group = paste,
  command = 'setlocal nopaste',
})

-- AutoInsertFileHead (.sh, .py)
local filehead = vim.api.nvim_create_augroup('FileHead', { clear = true })
vim.api.nvim_create_autocmd('BufNewFile', {
  group = filehead,
  pattern = '*.sh',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash', '' })
  end,
})
vim.api.nvim_create_autocmd('BufNewFile', {
  group = filehead,
  pattern = '*.py',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3', '', '' })
  end,
})

-- Restore cursor position
local cursor = vim.api.nvim_create_augroup('RestoreCursorPosition', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
  group = cursor,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Clear jumplist on startup
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('Jumplist', { clear = true }),
  command = 'clearjumps',
})

-- Resize splits on VimResized
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('AutoResize', { clear = true }),
  command = 'tabdo wincmd =',
})

-- Check file changes
local checkfile = vim.api.nvim_create_augroup('CheckFileChanges', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufWinEnter', 'WinEnter', 'CursorHold' }, {
  group = checkfile,
  callback = function()
    if vim.fn.getcmdtype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- .tags filetype
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  group = vim.api.nvim_create_augroup('Ctags', { clear = true }),
  pattern = '*.tags',
  command = 'setfiletype tags',
})
