-- ~/.config/nvim/lua/plugins/auto-session.lua

require('auto-session').setup({
  log_level = 'error',
  auto_save_enabled = true,
  auto_restore_enabled = true,
  -- auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
})

vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<CR>', { silent = true })
vim.keymap.set('n', '<leader>rs', '<cmd>AutoSession delete<CR>', { silent = true })
