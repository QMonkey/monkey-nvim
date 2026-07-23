-- Editing
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set({ 'n', 'v' }, 'j', 'gj')
vim.keymap.set({ 'n', 'v' }, 'k', 'gk')
vim.keymap.set({ 'n', 'v' }, 'H', '^')
vim.keymap.set({ 'n', 'v' }, 'L', '$')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set({ 'n', 'v' }, ';', ':')
vim.keymap.set('n', 'U', '<C-r>')

-- Insert mode movement
vim.keymap.set('i', '<C-p>', '<Up>')
vim.keymap.set('i', '<C-n>', '<Down>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-h>', '<BackSpace>')
vim.keymap.set('i', '<C-d>', '<Del>')

-- Command mode movement
vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-h>', '<BackSpace>')
vim.keymap.set('c', '<C-d>', '<Del>')

-- Smart quit
vim.keymap.set('n', 'q', function()
  local last_winnr = vim.fn.winnr('#')
  local ftype = vim.bo.filetype
  local is_diff = vim.wo.diff
  local is_qf = ftype == 'qf'
  local is_preview = vim.wo.previewwindow

  if is_diff and tonumber(last_winnr) > 0 then
    local bufname = vim.fn.bufname(vim.fn.winbufnr(tonumber(last_winnr)))
    if bufname:match('^fugitive:') then
      vim.cmd(last_winnr .. 'wincmd w')
      vim.cmd('quit')
      return
    end
  end

  vim.cmd('quit')

  if is_qf or is_preview then
    if tonumber(last_winnr) > 0 and vim.fn.win_id2win(vim.fn.win_getid(tonumber(last_winnr))) ~= 0 then
      pcall(vim.cmd, last_winnr .. 'wincmd w')
    end
  end
end, { silent = true })

vim.keymap.set('n', '<S-q>', '<cmd>quitall<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, 't', 'q')

-- Splits
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<leader>s', function()
  local name = vim.fn.input('New split name: ', '', 'file')
  if name ~= '' then
    vim.cmd('split ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '<leader>v', function()
  local name = vim.fn.input('New vsplit name: ', '', 'file')
  if name ~= '' then
    vim.cmd('vsplit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })

-- Buffers
vim.keymap.set('n', '<leader>o', function()
  local name = vim.fn.input('New buffer name: ', '', 'file')
  if name ~= '' then
    vim.cmd('edit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { silent = true })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { silent = true })

-- Tabs
vim.keymap.set('n', '<leader>t', function()
  local name = vim.fn.input('New tab name: ', '', 'file')
  if name ~= '' then
    vim.cmd('tabnew ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '[t', '<cmd>tabprevious<CR>', { silent = true })
vim.keymap.set('n', ']t', '<cmd>tabnext<CR>', { silent = true })
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt')
end
vim.keymap.set('n', '<leader>[', '<cmd>tabfirst<CR>', { silent = true })
vim.keymap.set('n', '<leader>]', '<cmd>tablast<CR>', { silent = true })

-- Toggle
vim.keymap.set('n', 'cod', function()
  vim.cmd(vim.wo.diff and 'diffoff' or 'diffthis')
end, { silent = true })
vim.keymap.set('n', 'cop', '<cmd>set invpaste<CR>', { silent = true })
vim.keymap.set('n', 'col', '<cmd>set invlist<CR>', { silent = true })
vim.keymap.set('n', 'con', function()
  vim.cmd.nohlsearch()
end, { silent = true })
vim.keymap.set('n', '<leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:nohlsearch<CR>', { silent = true })
vim.keymap.set('n', '<leader><leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:%s/\\r$//e<CR>:nohlsearch<CR>', { silent = true })

-- Zoom toggle
vim.keymap.set('n', '<leader>z', function()
  if vim.g.zoomed then
    vim.cmd(vim.g.zoom_winrestcmd)
    vim.g.zoomed = false
  else
    vim.g.zoom_winrestcmd = vim.fn.winrestcmd()
    vim.cmd('resize')
    vim.cmd('vertical resize')
    vim.g.zoomed = true
  end
end, { silent = true })
