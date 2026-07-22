-- ~/.config/nvim/lua/plugins/oil.lua

require('oil').setup({
  keymaps = {
    ['-'] = 'actions.parent',
    ['<CR>'] = 'actions.select',
    ['<C-s>'] = 'actions.select_vsplit',
    ['<C-v>'] = 'actions.select_split',
    ['<C-t>'] = 'actions.select_tab',
  },
})

-- Replace dirvish bindings
vim.keymap.set('n', '-', function()
  require('oil').open(vim.fn.expand('%:p:h'))
end, { silent = true })

vim.keymap.set('n', '~', function()
  local project = require('plugins.project')
  local root = project.find_root() or vim.fn.expand('~')
  require('oil').open(root)
end, { silent = true })
