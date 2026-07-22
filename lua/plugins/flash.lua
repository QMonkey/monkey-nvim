-- ~/.config/nvim/lua/plugins/flash.lua

require('flash').setup({
  labels = 'asdfghjklqwertyuiopzxcvbnm',
  search = {
    mode = 'fuzzy',
  },
  modes = {
    char = {
      enabled = false,
    },
  },
})

-- Replace stargate (f/F → flash)
vim.keymap.set({ 'n', 'x', 'o' }, 'f', function()
  require('flash').jump()
end)
vim.keymap.set({ 'n', 'x', 'o' }, 'F', function()
  require('flash').jump({ search = { mode = 'search' } })
end)
