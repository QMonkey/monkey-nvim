local M = {}

-- Terminal management (global terminal, F3/F4/F5) and send-to-pane (tmux panes + nvim terminal fallback, ,s group)
M.config = function()
  -- Terminal
  -- Ensure the global terminal exists and is on screen in the current tab,
  -- creating it if missing or showing it if hidden. Returns the terminal buf
  -- and whether it was just created. Focus is left on the terminal window.
  local function ensure_terminal(vertical)
    vim.cmd('stopinsert')
    local buf = vim.g.terminal_bufnr or 0
    local running = buf > 0 and vim.api.nvim_buf_is_valid(buf) and vim.b[buf].terminal_job_id ~= nil
        and vim.fn.jobwait({ vim.b[buf].terminal_job_id }, 0)[1] == -1
    if not running then
      if vertical then
        vim.cmd('botright vnew | terminal')
      else
        vim.cmd('botright 20new | terminal')
      end
      buf = vim.api.nvim_get_current_buf()
      vim.g.terminal_bufnr = buf
      return buf, true
    end
    local tab = vim.fn.tabpagenr()
    local wins = vim.fn.win_findbuf(buf)
    for _, wid in ipairs(wins) do
      if vim.fn.win_id2tabwin(wid)[1] == tab then
        return buf, false
      end
    end
    for _, wid in ipairs(wins) do
      vim.api.nvim_win_call(wid, function() vim.cmd('hide') end)
    end
    if vertical then
      vim.cmd('botright vertical sbuffer ' .. buf)
    else
      vim.cmd('botright sbuffer ' .. buf)
      vim.cmd('resize 20')
    end
    return buf, false
  end

  local function terminal_toggle(vertical)
    vim.cmd('stopinsert')
    local buf = vim.g.terminal_bufnr or 0
    local running = buf > 0 and vim.api.nvim_buf_is_valid(buf) and vim.b[buf].terminal_job_id ~= nil
        and vim.fn.jobwait({ vim.b[buf].terminal_job_id }, 0)[1] == -1
    if running then
      local tab = vim.fn.tabpagenr()
      for _, wid in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.fn.win_id2tabwin(wid)[1] == tab then
          vim.api.nvim_win_call(wid, function() vim.cmd('hide') end)
          return
        end
      end
    end
    local _, created = ensure_terminal(vertical)
    if created then
      vim.schedule(function() vim.cmd('startinsert') end)
    else
      vim.cmd('startinsert')
    end
  end

  vim.keymap.set('n', '<F3>', ':botright 20new | terminal<Space>', { desc = 'Open a terminal at the bottom' })
  vim.keymap.set({ 'n', 't' }, '<F4>', function() terminal_toggle(false) end,
    { silent = true, desc = 'Toggle the global terminal at the bottom' })
  vim.keymap.set({ 'n', 't' }, '<F5>', function() terminal_toggle(true) end,
    { silent = true, desc = 'Toggle the global terminal on the right' })
  vim.keymap.set('t', '<ScrollWheelUp>', '<C-\\><C-n><ScrollWheelUp>', { silent = true })
  vim.keymap.set('t', '<ScrollWheelDown>', '<C-\\><C-n><ScrollWheelDown>', { silent = true })
  -- A-; as a universal "back to normal mode": <C-\><C-n> is a no-op in normal
  -- mode and Esc-like everywhere else, terminal mode included.
  vim.keymap.set({ 'n', 'i', 'v', 's', 'c', 'o', 't' }, '<A-;>', '<C-\\><C-n>', { silent = true })

  -- `r` followed by a special key (e.g. <A-;>) must abort like <Esc>: the
  -- builtin `r` cannot be reached by mappings in its char prompt, so a special
  -- key would replace the character (a modifier-stripped char in nvim). `r` is
  -- therefore mapped to read the char itself and cancel on <Esc>/special keys.
  -- Special keys are the internal keycodes starting with the 0x80 byte.
  vim.keymap.set('n', 'r', function()
    local c = vim.fn.getcharstr()
    if c == '\27' or c:byte(1) == 128 then
      return
    end
    vim.cmd.normal({ args = { vim.v.count1 .. 'r' .. c }, bang = true })
  end, { silent = true })

  local term_group = vim.api.nvim_create_augroup('TerminalSettings', { clear = true })
  vim.api.nvim_create_autocmd('TermOpen', {
    group = term_group,
    callback = function(args)
      if vim.api.nvim_buf_get_name(args.buf):find('fzf') == nil then
        vim.bo[args.buf].buflisted = false
        vim.bo[args.buf].bufhidden = 'hide'
      end
    end,
  })

  -- Window-local opts must be (re)applied on every display: each new window
  -- showing a terminal buffer inherits the global number/list settings again.
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = term_group,
    callback = function(args)
      if vim.bo[args.buf].buftype == 'terminal' and vim.api.nvim_buf_get_name(args.buf):find('fzf') == nil then
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.list = false
        vim.wo.scrolloff = 0
      end
    end,
  })

  -- Send to pane
  -- ,s group: deliver text to a tmux pane or the global terminal — REPLs, AI
  -- CLIs, build panes, anything. Targets are dynamic: fzf-picked tmux panes
  -- with per-project attach state (shada), or the F4/F5 global terminal.
  -- ,sa attaches a pane (survives restarts), ,sd detaches; `submit` false =
  -- paste only, leaving the target free to compose around the text.
  -- Attachment is verified against a uuid stored as a pane option: generated
  -- once per pane, shared by all nvims attaching it, and dying with the pane —
  -- so a reused %N id after tmux restart/restore can't be mistaken for the old pane.
  local function new_uuid()
    local f = io.open('/dev/urandom', 'rb')
    if not f then
      math.randomseed(os.time() + vim.fn.getpid())
      return string.format('%08x%08x', math.random(0, 2 ^ 31 - 1), math.random(0, 2 ^ 31 - 1))
    end
    local bytes = f:read(16)
    f:close()
    return (bytes:gsub('.', function(c) return string.format('%02x', c:byte()) end))
  end

  local function pane_uuid(pane)
    local existing = vim.fn.system({ 'tmux', 'display-message', '-p', '-t', pane, '#{@send-pane-uuid}' })
    if vim.v.shell_error == 0 then
      existing = vim.trim(existing)
      if existing ~= '' then
        return existing
      end
    end
    local uuid = new_uuid()
    vim.fn.system({ 'tmux', 'set-option', '-p', '-t', pane, '@send-pane-uuid', uuid })
    return uuid
  end

  local function attach_pane(pane)
    vim.g.SEND_PANE_ID = pane
    vim.g.SEND_PANE_UUID = pane_uuid(pane)
  end

  local function detach_pane()
    vim.g.SEND_PANE_ID = nil
    vim.g.SEND_PANE_UUID = nil
  end

  local function open_pane_picker(on_pane)
    local panes = {}
    -- exclude the pane running this nvim: pasting into our own terminal is always a mistake
    local self_pane = vim.env.TMUX_PANE
    local out = vim.fn.system(
      'tmux list-panes -a -F "#{pane_id}|#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_current_path}"')
    for line in vim.gsplit(out, '\n', { plain = true, trimempty = true }) do
      local id, sess, cmd, path = line:match('^([^|]+)|([^|]+)|([^|]+)|(.*)$')
      if id and id ~= self_pane then
        -- mark the currently attached pane so re-attach is visible
        local mark = vim.g.SEND_PANE_ID == id and '* ' or ''
        panes[#panes + 1] = mark .. ('%s %s [%s] %s'):format(sess, path, cmd, id)
      end
    end
    if #panes == 0 then
      vim.notify('send-to-pane: no other tmux panes', vim.log.levels.WARN)
      return
    end
    require('fzf-lua').fzf_exec(panes, {
      prompt = 'Pane> ',
      actions = {
        ['default'] = function(sel)
          local pane = sel[1]:match('(%%%S+)$')
          if pane then
            -- picking a pane attaches it: the next send skips the picker
            attach_pane(pane)
            on_pane(pane)
          end
        end,
      },
    })
  end

  local function tmux_send(pane, text, submit)
    if text ~= '' then
      vim.fn.system({ 'tmux', 'load-buffer', '-' }, text)
      -- Always bracketed paste (-p): without it tmux sends each byte as a typed
      -- key, and a literal Tab in the text hits the target TUI's own Tab binding
      -- (e.g. opencode's plan-mode switch). -r only for multi-line so embedded
      -- LFs arrive as one paste instead of Enter per line.
      local args = { 'tmux', 'paste-buffer', '-t', pane, '-p' }
      if text:find('\n', 1, true) then
        table.insert(args, '-r')
      end
      vim.fn.system(args)
    end
    if submit then
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane, 'Enter' })
    end
  end

  local function send_to_terminal(text, submit)
    local prev_win = vim.api.nvim_get_current_win()
    local buf = ensure_terminal(true)
    local chan = vim.b[buf].terminal_job_id
    vim.fn.chansend(chan, text)
    if submit then
      vim.fn.chansend(chan, '\n')
    end
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_set_current_win(prev_win)
    end
  end

  local function send_to_pane(text, submit)
    if vim.fn.empty(vim.fn.getenv('TMUX')) == 0 then
      local pane = vim.g.SEND_PANE_ID
      local uuid = vim.g.SEND_PANE_UUID
      if pane then
        local check = uuid and vim.fn.system({ 'tmux', 'display-message', '-p', '-t', pane, '#{@send-pane-uuid}' }) or ''
        if uuid and vim.v.shell_error == 0 and check:find(uuid, 1, true) then
          return tmux_send(pane, text, submit)
        end
        detach_pane()
        vim.notify('send-to-pane: attached pane changed or is gone, detached', vim.log.levels.WARN)
      end
      return open_pane_picker(function(p) tmux_send(p, text, submit) end)
    end

    -- No tmux: fall back to the global terminal (F5-style vsplit)
    send_to_terminal(text, submit)
  end

  -- ,sa attach a pane so sends skip the picker
  -- ,sd detach
  vim.keymap.set('n', '<leader>sa', function()
    if vim.fn.empty(vim.fn.getenv('TMUX')) == 1 then
      vim.notify('send-to-pane: attach only applies to tmux', vim.log.levels.WARN)
      return
    end
    open_pane_picker(function(pane)
      attach_pane(pane)
      vim.notify('send-to-pane: attached ' .. pane)
    end)
  end, { desc = 'Attach pane' })
  vim.keymap.set('n', '<leader>sd', function()
    vim.notify('send-to-pane: detached ' .. (vim.g.SEND_PANE_ID or 'nothing'))
    detach_pane()
  end, { desc = 'Detach pane' })

  -- ,ss sends the visual selection / current line
  -- ,sf sends the file path
  -- ,sp sends a typed prompt
  -- ,sm only submits (Enter) the message composed in the target pane
  vim.keymap.set('x', '<leader>ss', function()
    vim.cmd('silent normal! y')
    send_to_pane(vim.fn.getreg('"'), false)
  end, { silent = true, desc = 'Send selection to pane' })
  vim.keymap.set('n', '<leader>ss', function() send_to_pane(vim.fn.getline('.'), false) end,
    { silent = true, desc = 'Send line to pane' })
  vim.keymap.set('n', '<leader>sf', function() send_to_pane(vim.fn.expand('%:p'), false) end,
    { silent = true, desc = 'Send filepath to pane' })
  vim.keymap.set('n', '<leader>sp', function()
    local prompt = vim.fn.input('Prompt> ')
    if prompt ~= '' then
      send_to_pane(prompt, false)
    end
  end, { desc = 'Send prompt to pane' })
  vim.keymap.set('n', '<leader>sm', function() send_to_pane('', true) end,
    { silent = true, desc = 'Submit (Enter) in pane' })
end

return M
