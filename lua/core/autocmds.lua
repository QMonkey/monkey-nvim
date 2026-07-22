local api = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

-- Relative number toggle in active normal mode
local relnum = augroup('RelativeNumber', { clear = true })
autocmd({ 'WinEnter', 'InsertLeave' }, {
  group = relnum,
  command = 'set relativenumber',
})
autocmd({ 'WinLeave', 'InsertEnter' }, {
  group = relnum,
  command = 'set norelativenumber number',
})

-- Cursorline toggle (disabled in insert mode)
local curline = augroup('CursorLine', { clear = true })
autocmd('InsertEnter', {
  group = curline,
  command = 'set nocursorline',
})
autocmd('InsertLeave', {
  group = curline,
  command = 'set cursorline',
})

-- Paste mode (disable on leaving insert)
local paste = augroup('PasteMode', { clear = true })
autocmd('InsertLeave', {
  group = paste,
  command = 'setlocal nopaste',
})

-- AutoInsertFileHead (.sh, .py)
local filehead = augroup('FileHead', { clear = true })
autocmd('BufNewFile', {
  group = filehead,
  pattern = '*.sh',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash', '' })
  end,
})
autocmd('BufNewFile', {
  group = filehead,
  pattern = '*.py',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3', '', '' })
  end,
})

-- Restore cursor position
local cursor = augroup('RestoreCursorPosition', { clear = true })
autocmd('BufReadPost', {
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
autocmd('VimEnter', {
  group = augroup('Jumplist', { clear = true }),
  command = 'clearjumps',
})

-- Resize splits on VimResized
autocmd('VimResized', {
  group = augroup('AutoResize', { clear = true }),
  command = 'tabdo wincmd =',
})

-- Check file changes
local checkfile = augroup('CheckFileChanges', { clear = true })
autocmd({ 'FocusGained', 'BufWinEnter', 'WinEnter', 'CursorHold' }, {
  group = checkfile,
  callback = function()
    if vim.fn.getcmdtype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- .tags filetype
autocmd({ 'BufNewFile', 'BufRead' }, {
  group = augroup('Ctags', { clear = true }),
  pattern = '*.tags',
  command = 'setfiletype tags',
})
