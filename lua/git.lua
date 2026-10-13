local M = {}

-- Git: gitsigns + mini.git (setup, keymaps and the :G alias)
M.spec = {
  {
    src = 'https://github.com/lewis6991/gitsigns.nvim',
    config = function()
      local gitsigns = require('gitsigns')
      gitsigns.setup({ preview_config = { border = 'rounded' } })

      vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', { silent = true })
      vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', { silent = true })
      vim.keymap.set('n', '<leader>gB', '<cmd>Gitsigns blame<CR>', { silent = true })

      vim.keymap.set('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { silent = true })
      vim.keymap.set('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hq', '<cmd>Gitsigns setqflist<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hQ', '<cmd>Gitsigns setqflist all<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hl', '<cmd>Gitsigns setloclist<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hp', '<cmd>Gitsigns preview_hunk_inline<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hP', '<cmd>Gitsigns preview_hunk<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', { silent = true })
      vim.keymap.set('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>', { silent = true })
    end,
  },
  {
    src = 'https://github.com/nvim-mini/mini-git',
    config = function()
      require('mini.git').setup({ command = { split = 'horizontal' } })

      vim.keymap.set('n', '<leader>gl', '<cmd>tab Git log --oneline --follow -- %<CR>', { silent = true })
      vim.keymap.set('n', '<leader>gL', '<cmd>tab Git log --oneline --graph --all<CR>', { silent = true })
      vim.keymap.set({ 'n', 'x' }, '<leader>gS', function() MiniGit.show_at_cursor() end,
        { silent = true, desc = 'Git show at cursor (line/range history or commit)' })
      vim.keymap.set('n', '<leader>gF', function() MiniGit.show_diff_source() end,
        { silent = true, desc = 'Git open file at commit under cursor' })
      vim.keymap.set('n', '<leader>gD', '<cmd>tab Git diff<CR>', { silent = true })

      -- `:G` alias for `:Git` (fugitive-style): forwards modifiers, bang and args;
      -- completion delegates to `:Git`'s context-aware completion by rewriting the
      -- cmdline (e.g. `:G log --<Tab>` completes as `:Git log --<Tab>`)
      local function g_complete(_, cmd_line, cursor_pos)
        local lead = cmd_line:match('^%S+')
        local git_line = cmd_line:gsub('^%S+', 'Git', 1)
        return vim.fn.getcompletion(git_line, 'cmdline', cursor_pos + ('Git'):len() - lead:len())
      end
      vim.api.nvim_create_user_command('G', function(input)
        vim.cmd(('%s Git%s %s'):format(input.mods, input.bang and '!' or '', input.args))
      end, { bang = true, nargs = '+', bar = true, complete = g_complete, desc = 'Alias for :Git' })
    end,
  },
}

return M
