-- ~/.config/nvim/lua/plugins/substitute.lua

require('substitute').setup()

-- Match monkey-vim subversive bindings
vim.keymap.set('n', 's', require('substitute').operator, { silent = true })
vim.keymap.set('x', 's', require('substitute').visual, { silent = true })
vim.keymap.set('n', 'ss', require('substitute').line, { silent = true })
vim.keymap.set('n', 'S', require('substitute').eol, { silent = true })
