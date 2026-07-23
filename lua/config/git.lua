-- --- vim-fugitive ---
vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { silent = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiff<CR>', { silent = true })
vim.keymap.set('n', '<leader>gB', '<cmd>Git blame<CR>', { silent = true })

-- --- gitsigns.nvim ---
require('gitsigns').setup()
