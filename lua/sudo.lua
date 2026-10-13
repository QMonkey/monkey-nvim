local M = {}

-- :SudoWrite — write the current buffer as root via dd
M.config = function()
  -- sudo write
  -- Buffer content is staged into a temp file via :write, then written as root
  -- with dd: non-interactive first (only works with cached credentials), on
  -- failure retry with the password from inputsecret. stdin holds only the
  -- password line, so a wrong password costs exactly one attempt and nothing
  -- can leak. Failures notify and keep the buffer modified.
  vim.api.nvim_create_user_command('SudoWrite', function()
    local tmp = vim.fn.tempname()
    vim.cmd('silent write ' .. vim.fn.fnameescape(tmp))
    local dd = vim.fn.shellescape('if=' .. tmp) .. ' ' .. vim.fn.shellescape('of=' .. vim.fn.expand('%:p'))
    local errfile = vim.fn.tempname()
    vim.fn.system('sudo -p "" -n -- dd ' .. dd .. ' 2>' .. errfile)
    if vim.v.shell_error ~= 0 then
      vim.fn.inputsave()
      local ok, pass = pcall(vim.fn.inputsecret, 'sudo password: ')
      vim.fn.inputrestore()
      if not ok or pass == '' then
        vim.api.nvim_echo({ { '\nSudoWrite cancelled', 'WarningMsg' } }, false, {})
        vim.fn.delete(tmp)
        vim.fn.delete(errfile)
        return
      end
      vim.fn.system('sudo -p "" -S -- dd ' .. dd .. ' 2>' .. errfile, pass .. '\n')
    end
    vim.fn.delete(tmp)
    local error = ''
    if vim.fn.filereadable(errfile) == 1 then
      error = table.concat(vim.tbl_filter(function(l) return vim.trim(l) ~= '' end, vim.fn.readfile(errfile)), ' | ')
    end
    vim.fn.delete(errfile)
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo(
        { { '\nSudoWrite failed: ' .. (error ~= '' and error or ('exit ' .. vim.v.shell_error)) .. '\n', 'ErrorMsg' } },
        false, {})
      return
    end
    vim.bo.modified = false
    vim.bo.readonly = false
  end, {})
end

return M
