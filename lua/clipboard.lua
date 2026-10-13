local M = {}

-- Clipboard backend selection (+/* registers; OSC 52 over ssh)
M.config = function()
  local util = require('util')

  -- Clipboard
  -- Choose the clipboard backend for the +/* registers.
  -- Over ssh, prefer OSC 52 so yanks reach the local clipboard; the remote
  -- X11/Wayland clipboard is otherwise unreachable from here.
  local is_physical_console = (vim.env.TERM or ''):match('^linux') ~= nil
      or util.root_terminal == 'kmscon' or util.root_terminal == 'tty' or util.root_terminal == 'physical_console'
  local is_ssh = vim.fn.empty(vim.fn.getenv('SSH_CONNECTION')) == 0
      or vim.fn.empty(vim.fn.getenv('SSH_CLIENT')) == 0
      or vim.fn.empty(vim.fn.getenv('SSH_TTY')) == 0
      or util.root_terminal == 'remote_ssh'
  local has_display = vim.fn.empty(vim.fn.getenv('DISPLAY')) == 0
  local has_wayland = vim.fn.empty(vim.fn.getenv('WAYLAND_DISPLAY')) == 0
  local has_mac = vim.fn.has('mac') == 1
  local has_tmux = vim.fn.empty(vim.fn.getenv('TMUX')) == 0
  local has_osc52 = pcall(require, 'vim.ui.clipboard.osc52')

  -- Set g:clipboard BEFORE any has('clipboard')/has('unnamedplus') call, since
  -- those trigger provider initialization and would ignore a later g:clipboard.
  if is_ssh and has_osc52 then
    -- osc52 provider (nvim 0.10+): yanks to the local clipboard via OSC 52.
    -- In tmux, only force osc52 when the remote tmux has set-clipboard on
    -- (it answers the OSC52 paste query, so `p` won't block); otherwise fall
    -- back to the tmux provider. Outside tmux, rely on nvim's built-in OSC 52
    -- auto-detection.
    if has_tmux then
      local sc = vim.fn.trim(vim.fn.system('tmux show-options -s set-clipboard 2>/dev/null'))
      vim.g.clipboard = sc:match('on') and 'osc52' or 'tmux'
    else
      vim.g.clipboard = 'osc52'
    end
  elseif not is_physical_console and (has_display or has_wayland or has_mac) then
    -- GUI clipboard: leave g:clipboard unset for auto-detection.
  elseif has_tmux then
    vim.g.clipboard = 'tmux'
  end

  local has_unnamedplus = vim.fn.has('unnamedplus') == 1
  if is_ssh and has_osc52 then
    vim.opt.clipboard = 'unnamed,unnamedplus'
  elseif not is_physical_console and (has_display or has_wayland or has_mac) then
    vim.opt.clipboard = has_unnamedplus and 'unnamed,unnamedplus' or 'unnamed'
  elseif has_tmux then
    vim.opt.clipboard = 'unnamed,unnamedplus'
  end
end

return M
