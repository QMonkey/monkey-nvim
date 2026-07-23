-- --- auto-session ---
require('auto-session').setup({
  log_level = 'error',
  auto_save_enabled = true,
  auto_restore_enabled = true,
})

vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<CR>', { silent = true })
vim.keymap.set('n', '<leader>rs', '<cmd>AutoSession delete<CR>', { silent = true })

-- --- toggleterm.nvim ---
require('toggleterm').setup({
  size = 15,
  open_mapping = '<F3>',
  direction = 'horizontal',
})

-- --- gutentags ---
vim.g.gutentags_modules = { 'ctags' }
vim.g.gutentags_project_root = {
  '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout',
}
vim.g.gutentags_cache_dir = vim.fn.expand('$HOME/.cache/tags')
vim.g.gutentags_ctags_tagfile = '.tags'
vim.g.gutentags_ctags_auto_set_tags = 1
vim.g.gutentags_ctags_extra_args = {
  '--fields=+liaS',
  '--extras=+q',
  '--langmap=c:.c.h,vim:.vim.vimrc',
  '--c-kinds=+p',
  '--c++-kinds=+p',
  '--python-kinds=+i',
}
vim.g.gutentags_generate_on_missing = 1
vim.g.gutentags_generate_on_new = 0
vim.g.gutentags_generate_on_write = 1
vim.g.gutentags_background_update = 1
vim.g.gutentags_resolve_symlinks = 1
vim.g.gutentags_define_advanced_commands = 1

-- --- trouble.nvim ---
require('trouble').setup({
  auto_close = true,
  auto_refresh = true,
  height = 10,
})

vim.keymap.set('n', '<leader>q', '<cmd>Trouble quickfix toggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>l', '<cmd>Trouble loclist toggle<CR>', { silent = true })
