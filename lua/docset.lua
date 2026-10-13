local M = {}

-- Docset: :LspHover command and per-filetype keywordprg (:Man/:help)
M.config = function()
  -- Docset
  vim.api.nvim_create_user_command('LspHover', function() vim.lsp.buf.hover({ border = 'rounded' }) end,
    { nargs = '*', range = true })

  local docset_group = vim.api.nvim_create_augroup('DocSet', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = docset_group,
    pattern = { 'man', 'help' },
    callback = function()
      vim.wo.list = false
    end,
  })

  -- LSP-enabled file types prefer :LspHover over the default :Man
  vim.api.nvim_create_autocmd('FileType', {
    group = docset_group,
    pattern = { 'cpp', 'zig', 'rust', 'go', 'gomod', 'gowork', 'gosum', 'gotmpl',
      'javascript', 'typescript', 'python', 'lua', 'sh', 'markdown', 'yaml', 'json', 'jsonc' },
    callback = function()
      vim.bo.keywordprg = ':LspHover'
    end,
  })

  -- C keeps :Man but with a custom section order. Must set keywordprg explicitly
  -- (not leave it empty) so Neovim's LSP does not auto-map K to hover on attach.
  vim.api.nvim_create_autocmd('FileType', {
    group = docset_group,
    pattern = 'c',
    callback = function()
      vim.bo.keywordprg = ':Man'
      vim.env.MANSECT = '2:3:1:4:5:6:7:8:9'
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = docset_group,
    pattern = { 'vim', 'help' },
    callback = function()
      vim.bo.keywordprg = ':help!'
    end,
  })
end

return M
