-- ~/.config/nvim/lua/plugins/trouble.lua

require('trouble').setup({
  auto_close = true,
  auto_refresh = true,
  height = 10,
})

-- Toggle quickfix / loclist
vim.keymap.set('n', '<leader>q', '<cmd>Trouble quickfix toggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>l', '<cmd>Trouble loclist toggle<CR>', { silent = true })
