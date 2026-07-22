-- ~/.config/nvim/lua/plugins/telescope.lua

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
  defaults = {
    file_ignore_patterns = { '.git/', '.hg/', '.svn/', '.bzr/' },
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
      },
    },
  },
  pickers = {
    live_grep = {
      additional_args = { '--hidden' },
    },
    find_files = {
      hidden = true,
    },
  },
})

local builtin = require('telescope.builtin')

-- File/buffer search (replaces LeaderF)
vim.keymap.set('n', '<C-p>', builtin.find_files, { silent = true })
vim.keymap.set('n', '<leader>b', builtin.buffers, { silent = true })
vim.keymap.set('n', '<leader>y', builtin.current_buffer_tags, { silent = true })

vim.keymap.set('n', '<leader>e', builtin.current_buffer_fuzzy_find, { silent = true })

vim.keymap.set('n', '<leader>f', function()
  builtin.lsp_document_symbols({ symbols = { 'function', 'method' } })
end, { silent = true })

vim.keymap.set('n', '<leader>a', function()
  builtin.grep_string({ default_text = vim.fn.expand('<cword>') })
end, { silent = true })
vim.keymap.set('v', '<leader>a', function()
  local saved_reg = vim.fn.getreg('"')
  local saved_regtype = vim.fn.getregtype('"')
  vim.cmd('normal! "vy"')
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', saved_reg, saved_regtype)
  builtin.grep_string({ default_text = text })
end, { silent = true })

vim.keymap.set('n', '<leader>gc', builtin.git_commits, { silent = true })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { silent = true })

vim.keymap.set('n', '<F1>', builtin.live_grep, { silent = true })
vim.keymap.set({ 'n', 'i' }, '<F2>', function()
  local state = require('telescope.state')
  local prompt_bufs = state.get_existing_prompt_bufnrs()
  if #prompt_bufs > 0 then
    actions.close(prompt_bufs[#prompt_bufs])
  else
    builtin.resume()
  end
end, { silent = true })
