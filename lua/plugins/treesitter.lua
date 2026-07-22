-- ~/.config/nvim/lua/plugins/treesitter.lua

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

-- Disable markdown conceal
vim.g.markdown_syntax_conceal = 0
vim.g.markdown_minlines = 100
vim.g.markdown_fenced_languages = {
  'c', 'cpp', 'rust', 'go', 'javascript', 'typescript',
  'python', 'lua', 'bash=sh', 'vim', 'sql', 'yaml', 'json',
}
