-- ~/.config/nvim/lua/core/keys.lua

local map = vim.keymap.set

-- Editing
map('n', 'Y', 'y$')
map({ 'n', 'v' }, 'j', 'gj')
map({ 'n', 'v' }, 'k', 'gk')
map({ 'n', 'v' }, 'H', '^')
map({ 'n', 'v' }, 'L', '$')
map('v', '<', '<gv')
map('v', '>', '>gv')
map({ 'n', 'v' }, ';', ':')
map('n', 'U', '<C-r>')

-- Insert mode movement
map('i', '<C-p>', '<Up>')
map('i', '<C-n>', '<Down>')
map('i', '<C-b>', '<Left>')
map('i', '<C-f>', '<Right>')
map('i', '<C-a>', '<Home>')
map('i', '<C-e>', '<End>')
map('i', '<C-h>', '<BackSpace>')
map('i', '<C-d>', '<Del>')

-- Command mode movement
map('c', '<C-p>', '<Up>')
map('c', '<C-n>', '<Down>')
map('c', '<C-b>', '<Left>')
map('c', '<C-f>', '<Right>')
map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
map('c', '<C-h>', '<BackSpace>')
map('c', '<C-d>', '<Del>')

-- Smart quit
map('n', 'q', function()
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

map('n', '<S-q>', '<cmd>quitall<CR>', { silent = true })
map({ 'n', 'v' }, 't', 'q')

-- Splits
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')
map('n', '<leader>s', function()
  local name = vim.fn.input('New split name: ', '', 'file')
  if name ~= '' then
    vim.cmd('split ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
map('n', '<leader>v', function()
  local name = vim.fn.input('New vsplit name: ', '', 'file')
  if name ~= '' then
    vim.cmd('vsplit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })

-- Buffers
map('n', '<leader>o', function()
  local name = vim.fn.input('New buffer name: ', '', 'file')
  if name ~= '' then
    vim.cmd('edit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
map('n', '[b', '<cmd>bprevious<CR>', { silent = true })
map('n', ']b', '<cmd>bnext<CR>', { silent = true })

-- Tabs
map('n', '<leader>t', function()
  local name = vim.fn.input('New tab name: ', '', 'file')
  if name ~= '' then
    vim.cmd('tabnew ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
map('n', '[t', '<cmd>tabprevious<CR>', { silent = true })
map('n', ']t', '<cmd>tabnext<CR>', { silent = true })
for i = 1, 9 do
  map('n', '<leader>' .. i, i .. 'gt')
end
map('n', '<leader>[', '<cmd>tabfirst<CR>', { silent = true })
map('n', '<leader>]', '<cmd>tablast<CR>', { silent = true })

-- Toggle
map('n', 'cod', function()
  vim.cmd(vim.wo.diff and 'diffoff' or 'diffthis')
end, { silent = true })
map('n', 'cop', '<cmd>set invpaste<CR>', { silent = true })
map('n', 'col', '<cmd>set invlist<CR>', { silent = true })
map('n', 'con', function()
  vim.cmd.nohlsearch()
  vim.fn.setreg('/', '')
end, { silent = true })
map('n', '<leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:nohlsearch<CR>', { silent = true })
map('n', '<leader><leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:%s/\\r$//e<CR>:nohlsearch<CR>', { silent = true })

-- Zoom toggle
map('n', '<leader>z', function()
  if vim.g.monkey_zoomed then
    vim.cmd(vim.g.monkey_zoom_winrestcmd)
    vim.g.monkey_zoomed = false
  else
    vim.g.monkey_zoom_winrestcmd = vim.fn.winrestcmd()
    vim.cmd('resize')
    vim.cmd('vertical resize')
    vim.g.monkey_zoomed = true
  end
end, { silent = true })
