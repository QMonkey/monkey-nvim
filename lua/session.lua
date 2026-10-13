local M = {}

-- Project-scoped session save/restore (mksession per project root)
M.config = function()
  local util = require('util')

  -- Session / Restore
  vim.opt.sessionoptions:remove({ 'blank', 'options', 'folds', 'terminal' })

  -- oil buffers are unlisted "oil://" nofile buffers and terminal buffers have
  -- 'buftype' terminal: mksession cannot represent them, so a session persisted
  -- while such a window is focused loses the window and the surrounding layout.
  -- Windows showing an excluded filetype/buftype are closed (or, when it is the
  -- last remaining window, switched back to a real buffer) before writing.
  local session_excluded_filetypes = { 'oil' }
  local session_excluded_buftypes = { 'terminal' }

  local function is_session_excluded(bufnr)
    return vim.tbl_contains(session_excluded_filetypes, vim.bo[bufnr].filetype)
        or vim.tbl_contains(session_excluded_buftypes, vim.bo[bufnr].buftype)
  end

  local function session_file()
    local root = vim.fs.root(vim.uv.cwd(), util.root_patterns) or vim.env.HOME
    return vim.fn.stdpath('data') .. '/sessions/' .. util.path_to_name(root) .. '-session.vim'
  end

  local function dir_exists(path)
    if vim.fn.isdirectory(path) == 1 then return true end
    -- mksession writes the path via fnameescape(): spaces become "my\ dir",
    -- so also try the unescaped form before giving up.
    return vim.fn.isdirectory((path:gsub('\\(%S)', '%1'))) == 1
  end

  local function clean_session_excluded_windows()
    -- Fallback: the first listed, named buffer that is not excluded.
    local fallback
    for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if not is_session_excluded(info.bufnr) and vim.api.nvim_buf_get_name(info.bufnr) ~= '' then
        fallback = info.bufnr
        break
      end
    end
    if not fallback then return end
    local alt = vim.fn.bufnr('#')

    -- Quitting the sole window of a tab closes the tab as well. The last window
    -- of the last tab cannot be quit, so its buffer is switched instead.
    local wins = vim.fn.getwininfo()
    for i = #wins, 1, -1 do
      local w = wins[i]
      if vim.api.nvim_win_is_valid(w.winid) and is_session_excluded(vim.api.nvim_win_get_buf(w.winid)) then
        local pos = vim.fn.win_id2tabwin(w.winid)
        if vim.fn.tabpagenr('$') == 1 and pos[1] == 1 and pos[2] == 1 and vim.fn.tabpagewinnr(1, '$') == 1 then
          -- Last remaining window: switching is the only safe option.
          local target = fallback
          if alt > 0 and vim.bo[alt].buflisted and not is_session_excluded(alt) then
            target = alt
          end
          vim.api.nvim_win_set_buf(w.winid, target)
        else
          vim.fn.win_execute(w.winid, 'quit')
        end
      end
    end
  end

  local function sanitize_session_file(file)
    -- Drop cd/lcd lines whose target directory no longer exists
    if vim.fn.filereadable(file) == 0 then return end
    local lines = vim.fn.readfile(file)
    local sanitized = {}
    for _, line in ipairs(lines) do
      local _, path = line:match('^(cd|lcd) (%S+)$')
      if path == nil or dir_exists(path) then
        table.insert(sanitized, line)
      end
    end
    if table.concat(sanitized, '\n') ~= table.concat(lines, '\n') then
      vim.fn.writefile(sanitized, file)
    end
  end

  local function write_session(file)
    file = file or session_file()
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':h'), 'p')
    clean_session_excluded_windows()
    vim.cmd('mksession! ' .. vim.fn.fnameescape(file))
    vim.v.this_session = file
    sanitize_session_file(file)
  end

  local function restore_session()
    local file = session_file()
    if vim.fn.argc() == 0 and vim.fn.filereadable(file) == 1 then
      local ok, err = pcall(vim.cmd, 'source ' .. vim.fn.fnameescape(file))
      if not ok then vim.notify('Failed to restore session: ' .. err, vim.log.levels.ERROR) end
    end
  end

  local function delete_session()
    local session = vim.v.this_session
    if session == '' or vim.fn.filereadable(session) == 0 then
      vim.notify('No session to delete', vim.log.levels.WARN)
      return
    end
    if vim.fn.confirm('Delete session ' .. vim.fn.fnamemodify(session, ':~') .. '?', '&Yes\n&No', 2) == 1 then
      vim.fn.delete(session)
      vim.v.this_session = ''
    end
  end

  vim.keymap.set('n', '<leader>ws', function()
    write_session()
    vim.notify('Session saved: ' .. vim.fn.fnamemodify(vim.v.this_session, ':~'))
  end, { silent = true, desc = 'Save session' })
  vim.keymap.set('n', '<leader>rs', delete_session, { desc = 'Delete session' })

  local session_group = vim.api.nvim_create_augroup('Session', { clear = true })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = session_group,
    callback = function()
      if vim.v.this_session ~= '' then write_session(vim.v.this_session) end
    end
  })
  vim.api.nvim_create_autocmd('VimEnter', { group = session_group, nested = true, callback = restore_session })
end

return M
