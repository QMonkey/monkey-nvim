-- ~/.config/nvim/lua/plugins/project.lua

-- Minimal project root detection — no external plugin needed.
-- Replaces airblade/vim-rooter

local M = {}

M.patterns = { '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout' }

function M.find_root()
  local path = vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
  local last = nil
  while path ~= last do
    for _, p in ipairs(M.patterns) do
      if vim.uv.fs_stat(vim.fs.joinpath(path, p)) then
        return path
      end
    end
    last = path
    path = vim.fn.fnamemodify(path, ':h')
  end
  return nil
end

function M.project_root()
  return M.find_root() or vim.fn.expand('%:p:h')
end

vim.keymap.set('n', '<leader>cr', function()
  local root = M.find_root()
  if root then
    vim.cmd('cd ' .. vim.fn.fnameescape(root))
  end
end, { silent = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ChangeRoot', { clear = true }),
  once = true,
  callback = function()
    local root = M.find_root()
    if root then
      vim.cmd('cd ' .. vim.fn.fnameescape(root))
    end
  end,
})

return M
