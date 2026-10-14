local M = {}

-- Project root
-- Shared by Rooter, Shada, Session and gtags/cscope
-- NOTE: vim.fs.root() searches the whole upward tree per marker in list
-- order, so a stray outer .root would shadow deeper VCS roots. Keep .root
-- last: repos always win, .root only marks repos-less dirs (loose scripts).
M.root_patterns = { '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout', '.root' }

function M.project_root()
  return vim.fs.root(0, M.root_patterns) or vim.fn.getcwd()
end

-- Flatten a project root into a single cache-friendly name ('/' and ':'
-- become '-', ' ' becomes '_', leading and trailing separators stripped).
function M.path_to_name(path)
  return (path:gsub('^/+', ''):gsub('[/:]', '-'):gsub(' ', '_'):gsub('[-_]+$', ''))
end

function M.gtags_dbpath(root)
  return vim.fs.normalize(vim.fn.stdpath('data') .. '/tags/' .. M.path_to_name(root))
end

-- Terminal type detection
-- Detects the real display by walking the process tree from the tmux client
-- (or Neovim itself) up the ancestry. Needed because under tmux $TERM is
-- tmux-256color even on a physical console, hiding the 8/16-color fallback.
-- The FIRST (innermost) valid tty decides: it is where output is actually
-- rendered. Compositor ttys further up (e.g. Hyprland from tty1) must never
-- classify as 'tty'. kmscon is the display only when everything below it
-- lives on the single pty it allocates; a second, distinct pty means it
-- merely launched a graphical session (e.g. Hyprland). Under kmscon the
-- innermost tty is always a pty. sshd in the ancestry outranks both: a
-- remote pty renders on the remote side, not on any local display.
-- The walk exists only to find kmscon/sshd/login markers, and reads the
-- process tree, not environment variables (which would mirror the tmux
-- server's start environment instead).
-- Return value: 'kmscon' | 'tty' | 'physical_console' | 'pseudo_terminal' | 'remote_ssh' | 'no_tty' | 'unknown'
local function get_root_terminal_type()
  local pid = vim.fn.getpid()
  if vim.fn.empty(vim.fn.getenv('TMUX')) == 0 then
    local pid_str = vim.fn.trim(vim.fn.system('tmux display-message -p "#{client_pid}" 2>/dev/null'))
    if pid_str:match('^%d+$') then
      pid = tonumber(pid_str)
    end
  end

  local uname = vim.fn.trim(vim.fn.system('uname -s'))
  if uname == '' or uname:lower():find('unknown') then
    return 'unknown'
  end

  local last_tty = ''
  local two_ptys = false
  local saw_login = false
  local saw_sshd = false
  for _ = 1, 10 do
    local line = vim.fn.trim(vim.fn.system('ps -o ppid=,tty=,comm= -p ' .. pid))
    local ppid, tty, comm = line:match('^%s*(%S+)%s+(%S+)%s*(.*)$')
    if not ppid then
      break
    end
    if comm == 'kmscon' then
      if saw_sshd then
        return 'remote_ssh'
      end
      if two_ptys then
        return 'pseudo_terminal'
      end
      return 'kmscon'
    end
    if comm == 'login' then
      saw_login = true
    end
    if comm:match('^sshd') then
      saw_sshd = true
    end
    if tty ~= '' and tty ~= '?' then
      if last_tty == '' then
        last_tty = tty
      end
      if last_tty:match('^pts/') and tty ~= last_tty then
        two_ptys = true
      end
    end
    if ppid == '' or tonumber(ppid) <= 1 then
      break
    end
    pid = tonumber(ppid)
  end

  if last_tty == '' and not saw_login then
    return 'no_tty'
  end
  local lower = uname:lower()
  if lower:find('linux') then
    if last_tty:match('^tty%d+$') then
      return 'tty'
    elseif last_tty:match('^pts/') then
      return saw_sshd and 'remote_ssh' or 'pseudo_terminal'
    elseif last_tty == '' then
      -- No controlling tty anywhere (e.g. shell spawned by a daemon), but a
      -- console login is in the ancestry: assume the physical console.
      return 'tty'
    end
  end
  if lower:find('darwin') then
    return (last_tty == 'console' or last_tty == '/dev/console') and 'physical_console' or 'pseudo_terminal'
  end
  return 'unknown'
end

M.root_terminal = get_root_terminal_type()
M.is_tty_console = (vim.env.TERM or ''):match('^linux') ~= nil or M.root_terminal == 'tty'

return M
