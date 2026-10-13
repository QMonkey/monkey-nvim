local M = {}

-- Code intelligence infrastructure: treesitter + context + textobjects
M.spec = {
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter').setup({
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true,
      })
      require('nvim-treesitter.install').install({
        'c', 'cpp', 'zig', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua', 'bash', 'vim', 'vimdoc', 'markdown',
        'markdown_inline', 'yaml', 'json', 'sql',
      })
    end,
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup()
      vim.keymap.set('n', '[c', function() require('treesitter-context').go_to_context() end,
        { silent = true, desc = 'Jump to context' })
    end,
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          lookahead = true,
          selection_modes = { ['@function.outer'] = 'V', ['@class.outer'] = 'V' },
        },
        move = { set_jumps = true },
      })
      local select = require('nvim-treesitter-textobjects.select')
      local selects = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aP'] = '@parameter.outer',
        ['iP'] = '@parameter.inner',
        ['aL'] = '@loop.outer',
        ['iL'] = '@loop.inner',
        ['ad'] = '@conditional.outer',
        ['id'] = '@conditional.inner',
        ['aC'] = '@comment.outer',
        ['iC'] = '@comment.inner',
      }
      for lhs, query in pairs(selects) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { silent = true, desc = 'ts textobj ' .. lhs })
      end
      local move = require('nvim-treesitter-textobjects.move')
      local moves = {
        [']f'] = { move.goto_next_start, '@function.outer' },
        ['[f'] = { move.goto_previous_start, '@function.outer' },
        [']F'] = { move.goto_next_end, '@function.outer' },
        ['[F'] = { move.goto_previous_end, '@function.outer' },
        [']c'] = { move.goto_next_start, '@class.outer' },
        ['[c'] = { move.goto_previous_start, '@class.outer' },
        [']C'] = { move.goto_next_end, '@class.outer' },
        ['[C'] = { move.goto_previous_end, '@class.outer' },
        [']P'] = { move.goto_next_start, '@parameter.outer' },
        ['[P'] = { move.goto_previous_start, '@parameter.outer' },
        [']L'] = { move.goto_next_start, '@loop.outer' },
        ['[L'] = { move.goto_previous_start, '@loop.outer' },
      }
      for lhs, fn in pairs(moves) do
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          fn[1](fn[2], 'textobjects')
        end, { silent = true, desc = 'ts move ' .. lhs })
      end

      local swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', '<leader>x', function() swap.swap_next('@parameter.inner') end,
        { silent = true, desc = 'swap param forward' })
      vim.keymap.set('n', '<leader>X', function() swap.swap_previous('@parameter.inner') end,
        { silent = true, desc = 'swap param backward' })
    end,
  },
}

return M
