-- --- nvim-treesitter ---
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if ok then
  configs.setup({
    ensure_installed = {
      'c', 'cpp', 'rust', 'go', 'javascript', 'typescript',
      'python', 'lua', 'bash', 'vim', 'vimdoc', 'markdown',
      'markdown_inline', 'yaml', 'json', 'sql',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end

-- --- markdown ---
vim.g.markdown_syntax_conceal = 0
vim.g.markdown_minlines = 100
vim.g.markdown_fenced_languages = {
  'c', 'cpp', 'rust', 'go', 'javascript', 'typescript',
  'python', 'lua', 'bash=sh', 'vim', 'sql', 'yaml', 'json',
}

-- --- matchit / matchup ---
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_matchparen_offscreen = {}

-- --- ufo (folding) ---
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup({
  provider_selector = function(_, ft, _)
    return { 'treesitter', 'indent' }
  end,
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = '  ' .. (endLnum - lnum) .. ' lines'
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
  end,
})

-- --- mini.indentscope ---
require('mini.indentscope').setup({
  draw = { delay = 0 },
})

-- --- mini.ai (text objects) ---
require('mini.ai').setup()

-- --- mini.surround ---
require('mini.surround').setup()

-- --- commentary (Comment.nvim) ---
require('Comment').setup()

-- --- nvim-autopairs ---
local npairs = require('nvim-autopairs')
npairs.setup()

local rule = require('nvim-autopairs.rule')
npairs.add_rule(rule('"', '"', 'vim'):with_pair(function()
  return false
end))

-- --- substitute.nvim ---
require('substitute').setup()

vim.keymap.set('n', 's', require('substitute').operator, { silent = true })
vim.keymap.set('x', 's', require('substitute').visual, { silent = true })
vim.keymap.set('n', 'ss', require('substitute').line, { silent = true })
vim.keymap.set('n', 'S', require('substitute').eol, { silent = true })

-- --- vim-visual-multi ---
vim.cmd([[
  let g:VM_maps = {}
  let g:VM_maps['Select Operator'] = 'gs'
  let g:VM_set_statusline = 0
  let g:VM_silent_exit = 1
  let g:VM_show_warnings = 0
]])

-- --- highlighted-yank ---
vim.g.highlightedyank_highlight_duration = 200
