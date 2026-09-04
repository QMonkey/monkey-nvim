-- Notes
--
--                               _                               _
--         _ __ ___   ___  _ __ | | _____ _   _       _ ____   _(_)_ __ ___
--        | '_ ` _ \ / _ \| '_ \| |/ / _ \ | | |_____| '_ \ \ / / | '_ ` _ \
--        | | | | | | (_) | | | |   <  __/ |_| |_____| | | \ V /| | | | | | |
--        |_| |_| |_|\___/|_| |_|_|\_\___|\__, |     |_| |_|\_/ |_|_| |_| |_|
--                                        |___/
--
--    Author: Charles Qiu
--    Email: Thinking.QMonkey@GMail.com
--

-- Leader
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Plugins
vim.pack.add({ 'https://github.com/zuqini/zpack.nvim' })

local theme_specs = {
  { src = 'https://github.com/sainnhe/sonokai' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
}

local editor_specs = {
  { src = 'https://github.com/echasnovski/mini.indentscope' },
  { src = 'https://github.com/echasnovski/mini.extra' },
  { src = 'https://github.com/echasnovski/mini.ai' },
  { src = 'https://github.com/echasnovski/mini.surround' },
  { src = 'https://github.com/numToStr/Comment.nvim' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/gbprod/substitute.nvim' },
  { src = 'https://github.com/chentoast/marks.nvim' },
  {
    src = 'https://github.com/andymass/vim-matchup',
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      vim.g.matchup_matchparen_deferred = 1
    end,
  },
}

local nav_specs = {
  {
    src = 'https://github.com/ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    keys = {
      { '<F1>',      function() require('fzf-lua').live_grep() end, desc = 'Live grep' },
      { '<F2>',      function() require('fzf-lua').resume() end,    desc = 'Resume fzf-lua' },
      { '<C-p>',     function() require('fzf-lua').files() end,     desc = 'Find files' },
      { '<leader>b', function() require('fzf-lua').buffers() end,   desc = 'Find buffers' },
      { '<leader>t', function() require('fzf-lua').btags() end,     desc = 'Buffer tags' },
      { '<leader>p', function() require('fzf-lua').tags() end,      desc = 'Project tags' },
      {
        '<leader>f',
        function()
          require('fzf-lua').lsp_document_symbols({
            regex_filter = function(item)
              return item.kind ==
                  'Function' or item.kind == 'Method'
            end
          })
        end,
        desc = 'Document functions'
      },
      { '<leader>e', function() require('fzf-lua').blines() end,      desc = 'Buffer lines' },
      { '<leader>a', function() require('fzf-lua').grep_cword() end,  desc = 'Grep cword' },
      { '<leader>a', function() require('fzf-lua').grep_visual() end, mode = 'v',           desc = 'Grep visual' },
    },
    config = function()
      local fzf_lua = require('fzf-lua')
      fzf_lua.setup({
        defaults = {
          silent = true,
          file_ignore_patterns = { '.git/', '.hg/', '.svn/', '.bzr/' },
        },
        keymap = {
          builtin = { ['<F2>'] = 'hide' },
          fzf = { ['ctrl-j'] = 'down', ['ctrl-k'] = 'up' },
        },
        files = { hidden = true },
        grep = { rg_opts = '--hidden' },
        buffers = {
          no_header_i = true,
          fzf_opts = { ['--header-lines'] = '0' },
          actions = { ['ctrl-d'] = { fn = fzf_lua.actions.buf_del, reload = true } },
        },
      })
    end,
  },
  {
    src = 'https://github.com/folke/flash.nvim',
    keys = {
      { 'f', function() require('flash').jump() end,                           mode = { 'n', 'x', 'o' } },
      { 'F', function() require('flash').jump({ jump = { pos = 'end' } }) end, mode = 'n' },
      { 'F', function() require('flash').treesitter() end,                     mode = { 'x', 'o' } },
    },
    config = function()
      require('flash').setup({
        labels = 'asdfghjklqwertyuiopzxcvbnm',
        search = { mode = 'exact' },
        modes = { char = { enabled = false } },
      })
    end,
  },
  {
    src = 'https://github.com/kevinhwang91/nvim-ufo',
    dependencies = { { src = 'https://github.com/kevinhwang91/promise-async' } },
    event = 'VeryLazy',
    cmd = { 'UfoEnable', 'UfoDisable', 'UfoInspect', 'UfoAttach', 'UfoDetach', 'UfoEnableFold', 'UfoDisableFold' },
    config = function()
      vim.opt.foldcolumn = '0'
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
      require('ufo').setup({
        provider_selector = function(_, _, _)
          return { 'treesitter', 'indent' }
        end,
        fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
          local new_virt_text = {}
          local suffix = '  ' .. (end_lnum - lnum) .. ' lines'
          local suf_width = vim.fn.strdisplaywidth(suffix)
          local target_width = width - suf_width
          local cur_width = 0
          for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = vim.fn.strdisplaywidth(chunk_text)
            if target_width > cur_width + chunk_width then
              table.insert(new_virt_text, chunk)
            else
              chunk_text = truncate(chunk_text, target_width - cur_width)
              local hl_group = chunk[2]
              table.insert(new_virt_text, { chunk_text, hl_group })
              chunk_width = vim.fn.strdisplaywidth(chunk_text)
              if cur_width + chunk_width < target_width then
                suffix = suffix .. (' '):rep(target_width - cur_width - chunk_width)
              end
              break
            end
            cur_width = cur_width + chunk_width
          end
          table.insert(new_virt_text, { suffix, 'MoreMsg' })
          return new_virt_text
        end,
      })
    end,
  },
}

local code_specs = {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/hrsh7th/nvim-cmp' },
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
  { src = 'https://github.com/hrsh7th/cmp-buffer' },
  { src = 'https://github.com/hrsh7th/cmp-path' },
  { src = 'https://github.com/hrsh7th/cmp-cmdline' },
  { src = 'https://github.com/L3MON4D3/LuaSnip' },
  { src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}

local git_specs = {
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  {
    src = 'https://github.com/NeogitOrg/neogit',
    cmd = { 'Neogit', 'NeogitResetState', 'NeogitLogCurrent', 'NeogitCommit' },
    keys = {
      { '<leader>gL', function() require('neogit').action('log', 'log_all_references')() end, desc = 'Neogit log (all)' },
    },
    dependencies = { { src = 'https://github.com/esmuellert/codediff.nvim' } },
    config = function()
      require('neogit').setup({ diff_viewer = 'codediff', integrations = { codediff = true } })
      require('codediff').setup({ diff = { compact = true } })
    end,
  },
  {
    src = 'https://github.com/esmuellert/codediff.nvim',
    cmd = { 'CodeDiff', 'VscodeDiff' },
  },
}

local project_specs = {
  { src = 'https://github.com/rmagatti/auto-session' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  {
    src = 'https://github.com/ludovicchabant/vim-gutentags',
    init = function()
      vim.g.gutentags_modules = { 'ctags' }
      vim.g.gutentags_project_root = { '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout' }
      vim.g.gutentags_cache_dir = vim.fn.stdpath("data") .. '/tags/'
      vim.g.gutentags_ctags_tagfile = '.tags'
      vim.g.gutentags_ctags_auto_set_tags = 1
      vim.g.gutentags_ctags_extra_args = {
        '--fields=+liaS',
        '--extras=+q',
        '--langmap=c:.c.h,vim:.vim.vimrc',
        '--c-kinds=+p',
        '--c++-kinds=+p',
        '--python-kinds=+i',
      }
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_new = 0
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_background_update = 1
      vim.g.gutentags_resolve_symlinks = 1
      vim.g.gutentags_define_advanced_commands = 1
    end,
  },
  {
    src = 'https://github.com/dhananjaylatkar/cscope_maps.nvim',
    cmd = { 'Cscope', 'Cs', 'Cstag', 'CsPrompt' },
    init = function()
      package.preload["cscope.pickers.trouble"] = function()
        return {
          run = function(opts)
            vim.fn.setqflist(opts.cscope.parsed_output)
            vim.fn.setqflist({}, "a", { title = opts.cscope.prompt_title })
            vim.cmd("Trouble quickfix")
          end,
        }
      end
    end,
    config = function()
      require("cscope_maps").setup({
        disable_maps = true,
        cscope = {
          exec = 'gtags-cscope',
          picker = "trouble",
          project_rooter = { enable = false },
          tag = { keymap = false },
        },
      })
      -- setup() resets vim.g.cscope_maps_db_file, so set it after setup for
      -- the current buffer's project; the GTags BufEnter autocmd keeps it in
      -- sync on project changes.
      local root = vim.fs.root(0, vim.g.gutentags_project_root) or vim.fn.getcwd()
      local dbpath = vim.fs.normalize(vim.fn['gutentags#get_cachefile'](root, ''))
      vim.g.cscope_maps_db_file = dbpath .. '/GTAGS::' .. root
    end,
  },
}

local tools_specs = {
  {
    src = 'https://github.com/folke/trouble.nvim',
    cmd = 'Trouble',
    config = function()
      require('trouble').setup({ auto_close = true, auto_refresh = true, height = 10 })
    end,
  },
  {
    src = 'https://github.com/jake-stewart/multicursor.nvim',
    keys = {
      { '<c-n>', function() require('multicursor-nvim').matchAddCursor(1) end, mode = { 'n', 'x' } },
    },
    config = function()
      local mc = require('multicursor-nvim')
      mc.setup({ hlsearch = true })
      mc.addKeymapLayer(function(layer_set)
        layer_set({ 'n', 'x' }, '<c-n>', function() mc.matchAddCursor(1) end)
        layer_set({ 'n', 'x' }, '<c-p>', function() mc.matchAddCursor(-1) end)
        layer_set({ 'n', 'x' }, '<c-x>', function() mc.matchSkipCursor(1) end)
        layer_set({ 'n', 'x' }, '<c-q>', function() mc.matchSkipCursor(-1) end)
        layer_set('n', '<esc>', function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
  {
    src = 'https://github.com/akinsho/toggleterm.nvim',
    cmd = { 'TermSelect', 'TermExec', 'TermNew', 'ToggleTerm', 'ToggleTermToggleAll', 'ToggleTermSendVisualLines', 'ToggleTermSendVisualSelection', 'ToggleTermSendCurrentLine', 'ToggleTermSetName' },
    keys = {
      {
        '<F3>',
        function()
          local cmd = vim.fn.input('Command: ')
          if cmd ~= '' then
            vim.cmd('2TermExec cmd=' .. vim.fn.shellescape(cmd))
          end
        end,
        desc = 'Run one-off command'
      },
      {
        '<F4>',
        function()
          local term = require('toggleterm.terminal').get(1)
          local was_open = term and term:is_open()
          vim.cmd('1ToggleTerm direction=horizontal')
          if not was_open and require('toggleterm.terminal').get(1):is_open() then
            vim.cmd('resize 20')
          end
        end,
        mode = { 'n', 't' },
        desc = 'Toggle horizontal terminal'
      },
      {
        '<F5>',
        function()
          local term = require('toggleterm.terminal').get(1)
          local was_open = term and term:is_open()
          vim.cmd('1ToggleTerm direction=vertical')
          if not was_open and require('toggleterm.terminal').get(1):is_open() then
            vim.cmd('vertical resize ' .. math.floor(vim.o.columns / 2))
          end
        end,
        mode = { 'n', 't' },
        desc = 'Toggle vertical terminal'
      },
    },
    config = function()
      require('toggleterm').setup({
        size = 20,
        direction = 'horizontal',
        start_in_insert = true,
        persist_mode = false,
      })
    end,
  },
}

local spec = {}
vim.list_extend(spec, theme_specs)
vim.list_extend(spec, editor_specs)
vim.list_extend(spec, nav_specs)
vim.list_extend(spec, code_specs)
vim.list_extend(spec, git_specs)
vim.list_extend(spec, project_specs)
vim.list_extend(spec, tools_specs)

require('zpack').setup({ spec = spec })

-- Terminal type detection
-- Detect the outermost terminal type by walking up the real process
-- tree from the current Neovim (or its tmux client). Needed before the
-- color block because a tmux client running on a physical tty reports
-- $TERM = tmux-256color, hiding the 8/16-color console behind it.
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
  local saw_login = false
  local saw_sshd = false
  for _ = 1, 10 do
    local line = vim.fn.trim(vim.fn.system('ps -o ppid=,tty=,comm= -p ' .. pid))
    local ppid, tty, comm = line:match('^%s*(%S+)%s+(%S+)%s*(.*)$')
    if not ppid then
      break
    end
    if comm == 'kmscon' then
      return 'kmscon'
    end
    if comm == 'login' then
      saw_login = true
    end
    if comm:match('^sshd') then
      saw_sshd = true
    end
    if tty ~= '' and tty ~= '?' then
      last_tty = tty
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
    if last_tty:match('^tty%d+$') or saw_login then
      return 'tty'
    elseif last_tty:match('^pts/') then
      return saw_sshd and 'remote_ssh' or 'pseudo_terminal'
    end
  end
  if lower:find('darwin') then
    return (last_tty == 'console' or last_tty == '/dev/console') and 'physical_console' or 'pseudo_terminal'
  end
  return 'unknown'
end

local root_terminal = get_root_terminal_type()
local is_tty_console = (vim.env.TERM or ''):match('^linux') ~= nil or root_terminal == 'tty'

-- Color support
-- The Linux framebuffer console (tty1-tty63, TERM=linux) has no true
-- color and sonokai is a true-color-only theme (its `&t_Co < 256 -> finish`
-- guard makes it a no-op there). Detect it, moreover via a physical tty
-- under a tmux client that masks the term as tmux-256color, so we can fall
-- back to the built-in unokai theme below.
if vim.fn.has('termguicolors') == 1 and not is_tty_console then
  vim.opt.termguicolors = true
else
  vim.opt.termguicolors = false
end

-- Theme
vim.opt.background = 'dark'
if not is_tty_console then
  -- sonokai settings must be set before :colorscheme
  vim.g.sonokai_style = 'andromeda'
  vim.g.sonokai_better_performance = 1
  vim.g.sonokai_diagnostic_text_highlight = 1
  vim.g.sonokai_diagnostic_virtual_text = 'colored'
  vim.g.sonokai_dim_inactive_windows = 1
  vim.cmd('colorscheme sonokai')
else
  -- unokai is a built-in Monokai-style theme whose named-color branches
  -- match the console's fixed VGA palette, keeping a sonokai-like look when
  -- is_tty_console.
  vim.cmd('colorscheme unokai')
end

-- lualine.nvim
local function mc()
  return package.loaded['multicursor-nvim']
end
local function mc_active()
  return mc() ~= nil and mc().hasCursors()
end

-- Shared mc() block color for the lualine a and z sections: during a
-- multi-cursor session both turn purple
local function mc_color()
  if mc_active() then
    if is_tty_console then
      return { fg = 0, bg = 13, gui = 'bold' }
    end
    local purple = vim.fn.mode() ~= 'n' and '#9d7cd8' or '#bb97ee'
    return { fg = '#2b2d3a', bg = purple, gui = 'bold' }
  end
  return {}
end

require('lualine').setup({
  options = {
    theme = not is_tty_console and 'sonokai' or '16color',
    component_separators = '',
    section_separators = '',
    always_show_tabline = false,
    icons_enabled = false,
  },
  sections = {
    lualine_a = {
      {
        function()
          if mc_active() then
            local m = vim.fn.mode()
            local prefix
            if m == 'n' then
              prefix = 'N'
            elseif m == 'v' then
              prefix = 'V'
            elseif m == 'V' then
              prefix = 'V-L'
            else
              prefix = 'V-B'
            end
            return prefix .. '-MULTI'
          end
          return require('lualine.utils.mode').get_mode()
        end,
        color = mc_color,
      },
    },
    lualine_b = {
      { 'branch',      icon = '' },
      { 'diff' },
      { 'diagnostics', sections = { 'error', 'warn', 'info', 'hint' } },
    },
    lualine_c = {
      { 'filename', path = 0 },
    },
    lualine_x = {
      {
        function()
          if not mc_active() then
            return ''
          end
          local result = mc().numCursors() .. ' cursors'
          if vim.v.hlsearch and vim.fn.getreg('/') ~= '' then
            result = result .. '  /' .. vim.fn.getreg('/')
          end
          return result
        end,
      },
      'filetype', 'fileformat', 'encoding',
    },
    lualine_y = { 'progress' },
    lualine_z = {
      { 'location', color = mc_color },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = {
      {
        'tabs',
        mode = 1,
        max_length = math.huge,
        tabs_color = { active = 'TabLineSel' },
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
})

-- CheckFileChanges
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufWinEnter', 'WinEnter', 'CursorHold' }, {
  group = vim.api.nvim_create_augroup('CheckFileChanges', { clear = true }),
  callback = function()
    if vim.fn.getcmdtype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- Rooter
local patterns = { '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout' }

local function cd_root()
  local root = vim.fs.root(0, patterns)
  if root then
    vim.cmd('cd ' .. vim.fn.fnameescape(root))
  end
end

vim.keymap.set('n', '<leader>cr', cd_root, { silent = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ChangeRoot', { clear = true }),
  once = true,
  callback = cd_root,
})

-- Shada
-- Isolate command/search history, registers and file marks per project by
-- pointing 'shadafile' at the project root (falls back to ~ outside a
-- project). Neovim reads shada after init.lua, so this also affects the startup load.
local function shada_path()
  local root = vim.fs.root(vim.uv.cwd(), patterns) or vim.env.HOME
  return vim.fn.stdpath('state') .. '/shada/' .. (root:gsub('^/', ''):gsub('/', '-')) .. '.shada'
end

vim.o.shadafile = shada_path()

-- Session / Restore
vim.opt.sessionoptions:remove({ 'blank', 'options', 'folds', 'terminal' })

-- auto-session
-- oil buffers are unlisted "oil://" nofile buffers, which mksession cannot
-- represent: quitting while an oil window has focus makes the saved session
-- fail to load on restore. this option deletes oil buffers right before every save.
require('auto-session').setup({
  log_level = 'error',
  auto_save_enabled = true,
  auto_restore_enabled = true,
  close_filetypes_on_save = { 'oil' },
})

vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<CR>', { silent = true })
-- Delete with confirmation
vim.keymap.set('n', '<leader>rs', function()
  if vim.fn.confirm('Delete session for ' .. vim.fn.getcwd() .. '?', '&Yes\n&No', 2) == 1 then
    vim.cmd('AutoSession delete')
  end
end)

-- RestoreCursorPosition
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('RestoreCursorPosition', { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= lcount then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- cscope_maps.nvim + gtags
vim.env.GTAGSLABEL = 'native-pygments'

local candidates = {
  '/usr/local/etc/gtags.conf',
  '/etc/gtags.conf',
  '/etc/gtags/gtags.conf',
  '/usr/share/gtags/gtags.conf',
  '/usr/local/share/gtags/gtags.conf',
  '/usr/local/opt/global/share/gtags/gtags.conf',
  '/opt/homebrew/etc/gtags.conf',
  '/opt/homebrew/share/gtags/gtags.conf',
  '/opt/homebrew/opt/global/share/gtags/gtags.conf',
}
if vim.env.GTAGSCONF and vim.env.GTAGSCONF ~= '' then
  table.insert(candidates, 1, vim.env.GTAGSCONF)
end
for _, conf in ipairs(candidates) do
  local f = io.open(conf, 'r')
  if f then
    local content = f:read('*a')
    f:close()
    if content:find('native%-pygments:') then
      vim.env.GTAGSCONF = conf
      break
    end
  end
end

-- Resolve the project root per buffer so files from other projects get
-- their own gtags DB, branch tracking and cscope connection.
local function project_root()
  return vim.fs.root(0, vim.g.gutentags_project_root) or vim.fn.getcwd()
end

local function gtags_dbpath(root)
  return vim.fs.normalize(vim.fn['gutentags#get_cachefile'](root, ''))
end

local function switch_cscope_conn(root)
  local dbpath = gtags_dbpath(root)
  -- gtags-cscope resolves the DB via env vars and ignores cscope_maps' -f/-P
  -- args, so the env must point at the current buffer's project.
  vim.env.GTAGSROOT = root
  vim.env.GTAGSDBPATH = dbpath
  -- cscope_maps re-reads vim.g.cscope_maps_db_file on every query and honors
  -- it over its internal connections ("db_file::pre_path" format), so this
  -- works regardless of when the lazy-loaded plugin actually loads.
  vim.g.cscope_maps_db_file = dbpath .. '/GTAGS::' .. root
end

vim.keymap.set('n', 'gs', '<Cmd>Cscope find s<CR>', { silent = true })
vim.keymap.set('n', 'gD', '<Cmd>Cstag<CR>', { silent = true })
vim.keymap.set('n', 'gR', '<Cmd>Cscope find c<CR>', { silent = true })

local gtags_building = {} -- root -> true while a gtags job runs
local function gtags_build(root)
  if gtags_building[root] then return false end
  gtags_building[root] = true
  local dbpath = gtags_dbpath(root)
  vim.fn.mkdir(dbpath, 'p')
  vim.system({ 'gtags', dbpath }, { cwd = root, text = true }, function(obj)
    vim.schedule(function()
      gtags_building[root] = nil
      if obj.code ~= 0 then
        vim.notify('gtags: build failed in ' .. root, vim.log.levels.ERROR)
      end
    end)
  end)
  return true
end

local function gtags_update(root)
  if gtags_building[root] then return end
  local dbpath = gtags_dbpath(root)
  if vim.fn.glob(dbpath .. '/GTAGS') == '' then
    gtags_build(root)
    return
  end
  gtags_building[root] = true
  vim.system({ 'gtags', '--incremental', dbpath }, { cwd = root, text = true }, function(obj)
    vim.schedule(function()
      gtags_building[root] = nil
      if obj.code ~= 0 then
        vim.notify('gtags: update failed in ' .. root, vim.log.levels.ERROR)
      end
    end)
  end)
end

local gtags_group = vim.api.nvim_create_augroup('GTags', { clear = true })

-- Switch the cscope DB to the entered buffer's project and build GTAGS
-- when missing
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = gtags_group,
  callback = function(e)
    if vim.bo[e.buf].buftype ~= '' or not vim.bo[e.buf].modifiable then return end
    if vim.fn.expand('#' .. e.buf .. ':p') == '' then return end
    local root = project_root()
    switch_cscope_conn(root)
    if vim.fn.glob(gtags_dbpath(root) .. '/GTAGS') == '' then
      gtags_build(root)
    end
  end,
  desc = 'switch cscope DB and build GTAGS on BufEnter when missing',
})

-- Incremental update on BufWritePost
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = gtags_group,
  callback = function(e)
    if vim.bo[e.buf].buftype ~= '' or not vim.bo[e.buf].modifiable then return end
    if vim.fn.expand('#' .. e.buf .. ':p') == '' then return end
    gtags_update(project_root())
  end,
  desc = 'incremental GTAGS update on save',
})

-- Branch-aware gtags rebuild. Detect a branch switch by comparing the joint
-- (branch, HEAD) identity against a session baseline, then force a full
-- rebuild; detached HEAD compares HEAD only. Incremental gtags updates can't
-- handle deleted/renamed files after a branch switch.
if vim.g.tags_branch_aware == nil then
  vim.g.tags_branch_aware = 1
end
local tags_branch_baseline = {} -- root -> { branch, head }

local function tags_head_file(root)
  return gtags_dbpath(root) .. '/.tags-head'
end

local function tags_load_head(root)
  local f = io.open(tags_head_file(root), 'r')
  if not f then return '' end
  local head = f:read('*a')
  f:close()
  return vim.trim(head)
end

local function tags_save_head(root, head)
  vim.fn.mkdir(gtags_dbpath(root), 'p')
  local f = io.open(tags_head_file(root), 'w')
  if f then
    f:write(head)
    f:close()
  end
end

local function tags_branch_identity(root)
  local branch = vim.fn.trim(vim.fn.system('git -C ' .. vim.fn.shellescape(root) .. ' branch --show-current'))
  local head = vim.fn.trim(vim.fn.system('git -C ' .. vim.fn.shellescape(root) .. ' rev-parse HEAD'))
  if head == '' then return nil end
  return { branch = branch, head = head }
end

local function tags_update_ctags(root)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[buf].gutentags_root == root and vim.b[buf].gutentags_files then
      -- Run in the project buffer without touching the visible buffer/window.
      -- GutentagsUpdate is buffer-local, so it must execute with that buffer
      -- current; nvim_buf_call restores the current buffer automatically.
      vim.api.nvim_buf_call(buf, function()
        if vim.fn.exists(':GutentagsUpdate') == 2 then
          vim.cmd('GutentagsUpdate!')
        end
      end)
      return
    end
  end
end

-- Full rebuild for one project. Returns false when a gtags job for that
-- project is already running, so callers keep their stale baseline and
-- retry on the next check instead of losing the rebuild.
local function tags_do_rebuild(root)
  if not gtags_build(root) then return false end
  tags_update_ctags(root)
  return true
end

local function tags_check_branch()
  if not vim.g.tags_branch_aware then return end
  -- Require a buffer gutentags has set up for this project. On a bare
  -- startup (no args) no buffer is set up yet, so skip and let the
  -- BufEnter that follows the first file open do the real check. This keeps
  -- gtags and ctags rebuilt together (ctags needs a set-up buffer).
  local root = project_root()
  local has_buf = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[buf].gutentags_root == root and vim.b[buf].gutentags_files then
      has_buf = true
      break
    end
  end
  if not has_buf then return end

  local info = tags_branch_identity(root)
  if not info then return end

  local base = tags_branch_baseline[root]
  if base == nil then
    -- No in-memory baseline yet (fresh nvim). Rebuild only if the DB was
    -- generated for a different HEAD; trust the existing DB otherwise.
    local saved = tags_load_head(root)
    if saved == '' then
      tags_save_head(root, info.head)
      tags_branch_baseline[root] = info
    elseif saved ~= info.head then
      if tags_do_rebuild(root) then
        tags_save_head(root, info.head)
        tags_branch_baseline[root] = info
      end
      -- else: a gtags job is in flight; the stale baseline makes the next
      -- check retry the rebuild.
    else
      tags_branch_baseline[root] = info
    end
    return
  end

  if base.branch == info.branch and base.head == info.head then return end

  -- Rebuild on a real switch (branch+HEAD both changed) or a detached HEAD
  -- move. Same-branch commit is ignored; rename only refreshes the baseline.
  local rebuild = (base.branch ~= info.branch and base.head ~= info.head)
      or (info.branch == '' and base.head ~= info.head)
  if rebuild then
    if not tags_do_rebuild(root) then return end -- retry on next check
    tags_save_head(root, info.head)
    tags_branch_baseline[root] = info
  elseif base.branch ~= info.branch then
    tags_branch_baseline[root].branch = info.branch
  end
end

local function tags_rebuild()
  local root = project_root()
  local info = tags_branch_identity(root)
  if not info then
    vim.notify('TagsRebuild: cannot determine project root', vim.log.levels.ERROR)
    return
  end
  if not tags_do_rebuild(root) then
    vim.notify('TagsRebuild: gtags job already running for ' .. root, vim.log.levels.WARN)
    return
  end
  tags_save_head(root, info.head)
  tags_branch_baseline[root] = info
end

vim.api.nvim_create_user_command('TagsRebuild', tags_rebuild, {})

local tags_group = vim.api.nvim_create_augroup('TagsBranchAware', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = tags_group,
  callback = function() tags_check_branch() end,
})
vim.api.nvim_create_autocmd('FocusGained', {
  group = tags_group,
  callback = function() tags_check_branch() end,
})
for _, ev in ipairs({ 'NeogitBranchCheckout', 'NeogitReset', 'NeogitMerge', 'NeogitRebase', 'NeogitStash', 'NeogitPullComplete' }) do
  vim.api.nvim_create_autocmd('User', {
    group = tags_group,
    pattern = ev,
    callback = function() tags_check_branch() end,
  })
end

-- Encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = 'utf-8,gb18030,cp936,ucs-bom,big5,euc-jp,euc-kr,latin1'
vim.opt.fileformats = 'unix,dos,mac'

-- Number
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = true

local relativenumber_group = vim.api.nvim_create_augroup('RelativeNumber', { clear = true })
vim.api.nvim_create_autocmd({ 'WinEnter', 'InsertLeave' }, {
  group = relativenumber_group,
  command = 'set relativenumber',
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'InsertEnter' }, {
  group = relativenumber_group,
  command = 'set norelativenumber number',
})

-- Cursorline
vim.opt.cursorline = true

local cursorline_group = vim.api.nvim_create_augroup('CursorLine', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = cursorline_group,
  command = 'set nocursorline',
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = cursorline_group,
  command = 'set cursorline',
})

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.gdefault = true
vim.opt.shortmess:remove('S')
vim.opt.shortmess:append('s')

local hlsearch_group = vim.api.nvim_create_augroup('Hlsearch', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = hlsearch_group,
  callback = function()
    if vim.v.hlsearch == 1 then
      vim.schedule(function()
        vim.cmd('nohlsearch')
      end)
    end
  end,
})

-- Highlight
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Completion
vim.opt.wildmenu = true
vim.opt.wildmode = 'list:longest,full'
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.magic = true

-- Swap
vim.opt.directory = vim.fn.stdpath("data") .. "/swap//"
vim.opt.jumpoptions:append('stack')

-- Clipboard {
-- Choose the clipboard backend for the +/* registers.
-- Over ssh, prefer OSC 52 so yanks reach the local clipboard; the remote
-- X11/Wayland clipboard is otherwise unreachable from here.
local is_physical_console = (vim.env.TERM or ''):match('^linux') ~= nil
    or root_terminal == 'kmscon' or root_terminal == 'tty' or root_terminal == 'physical_console'
local is_ssh = vim.fn.empty(vim.fn.getenv('SSH_CONNECTION')) == 0
    or vim.fn.empty(vim.fn.getenv('SSH_CLIENT')) == 0
    or vim.fn.empty(vim.fn.getenv('SSH_TTY')) == 0
    or root_terminal == 'remote_ssh'
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
-- }

-- Indent
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.textwidth = 0
vim.opt.wrap = true
vim.opt.breakindent = true

-- Split
vim.opt.splitright = true

-- Timing
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10
vim.opt.updatetime = 300

-- Display
vim.opt.list = true
vim.opt.listchars = 'tab:▸ ,leadmultispace:│   ,eol:¬,trail:·'

-- Trailing whitespace in red (matchadd is window-local; priority -1 keeps it below Search/IncSearch)
vim.api.nvim_set_hl(0, 'TrailingSpace', { bg = '#fb617e' })
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  group = vim.api.nvim_create_augroup('TrailingWhitespace', { clear = true }),
  callback = function()
    for _, m in ipairs(vim.fn.getmatches()) do
      if m.group == 'TrailingSpace' then
        return
      end
    end
    vim.fn.matchadd('TrailingSpace', [[\s\+$]], -1)
  end,
})

-- Scroll
vim.opt.scrolloff = 7
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 1

-- Misc
vim.opt.backspace = 'indent,eol,start'
vim.opt.hidden = true
vim.opt.autoread = true
vim.opt.belloff = 'all'
vim.opt.mouse = 'nvi'
vim.opt.showtabline = 1
vim.opt.laststatus = 2

-- Key maps
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set({ 'n', 'v' }, 'j', 'gj')
vim.keymap.set({ 'n', 'v' }, 'k', 'gk')
vim.keymap.set({ 'n', 'v' }, 'H', '^')
vim.keymap.set({ 'n', 'v' }, 'L', '$')
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
vim.keymap.set({ 'n', 'v' }, ';', ':')
vim.keymap.set('n', 'U', '<C-r>')

vim.keymap.set('i', '<C-p>', '<Up>')
vim.keymap.set('i', '<C-n>', '<Down>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-h>', '<BackSpace>')
vim.keymap.set('i', '<C-d>', '<Del>')

vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-h>', '<BackSpace>')
vim.keymap.set('c', '<C-d>', '<Del>')

-- Buffer
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { silent = true })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { silent = true })
vim.keymap.set('n', '<leader>o', function()
  local name = vim.fn.input('New buffer name: ', '', 'file')
  if name ~= '' then
    vim.cmd('edit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })

-- Tab
vim.keymap.set('n', '[t', '<cmd>tabprevious<CR>', { silent = true })
vim.keymap.set('n', ']t', '<cmd>tabnext<CR>', { silent = true })
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt')
end
vim.keymap.set('n', '<leader>[', '<cmd>tabfirst<CR>', { silent = true })
vim.keymap.set('n', '<leader>]', '<cmd>tablast<CR>', { silent = true })
vim.keymap.set('n', '<leader><leader>t', function()
  local name = vim.fn.input('New tab name: ', '', 'file')
  if name ~= '' then
    vim.cmd('tabnew ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })

-- Split
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<leader><leader>s', function()
  local name = vim.fn.input('New split name: ', '', 'file')
  if name ~= '' then
    vim.cmd('split ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '<leader><leader>v', function()
  local name = vim.fn.input('New vsplit name: ', '', 'file')
  if name ~= '' then
    vim.cmd('vsplit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })

-- Toggle
vim.keymap.set('n', 'cod', function()
  vim.cmd(vim.wo.diff and 'diffoff' or 'diffthis')
end, { silent = true })
vim.keymap.set('n', 'cop', '<cmd>set invpaste<CR>', { silent = true })
vim.keymap.set('n', 'col', '<cmd>set invlist<CR>', { silent = true })
vim.keymap.set('n', 'con', '<cmd>set nohlsearch<CR>', { silent = true })
vim.keymap.set('n', '<leader><Space>', '<cmd>%s/\\s\\+$//e<CR>', { silent = true })
vim.keymap.set('n', '<leader><leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:%s/\\r$//e<CR>', { silent = true })

vim.api.nvim_create_autocmd('InsertLeave', {
  group = vim.api.nvim_create_augroup('PasteMode', { clear = true }),
  command = 'setlocal nopaste',
})

-- Resize
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('AutoResize', { clear = true }),
  command = 'tabdo wincmd =',
})

vim.keymap.set({ 'n', 't' }, '<leader>z', function()
  if vim.g.zoomed and vim.fn.win_id2win(vim.g.zoom_winid) ~= 0 then
    if vim.fn.winnr('$') == vim.g.zoom_wincount then
      vim.cmd(vim.g.zoom_winrestcmd)
    end
    vim.g.zoomed = false
  else
    vim.g.zoom_winid = vim.fn.win_getid()
    vim.g.zoom_wincount = vim.fn.winnr('$')
    vim.g.zoom_winrestcmd = vim.fn.winrestcmd()
    vim.cmd('resize')
    vim.cmd('vertical resize')
    vim.g.zoomed = true
  end
end, { silent = true })

-- FileType
local filetype_group = vim.api.nvim_create_augroup('FileTypes', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = filetype_group,
  pattern = { 'zig', 'rust', 'python', 'markdown' },
  callback = function(args)
    vim.bo[args.buf].expandtab = true
    vim.bo[args.buf].tabstop = 4
    vim.bo[args.buf].shiftwidth = 4
    vim.bo[args.buf].softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = filetype_group,
  pattern = { 'javascript', 'typescript', 'lua', 'yaml', 'json', 'jsonc' },
  callback = function(args)
    vim.bo[args.buf].expandtab = true
    vim.bo[args.buf].tabstop = 2
    vim.bo[args.buf].shiftwidth = 2
    vim.bo[args.buf].softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = filetype_group,
  pattern = 'qf',
  command = 'wincmd J',
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = filetype_group,
  pattern = { '*.gotmpl', '*.go.tmpl' },
  command = 'setfiletype gotmpl',
})

vim.api.nvim_create_autocmd('BufNewFile', {
  group = filetype_group,
  pattern = '*.sh',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash', '' })
  end,
})
vim.api.nvim_create_autocmd('BufNewFile', {
  group = filetype_group,
  pattern = '*.py',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3', '', '' })
  end,
})

-- markdown
vim.g.markdown_syntax_conceal = 0
vim.g.markdown_minlines = 100
vim.g.markdown_fenced_languages = { 'c', 'cpp', 'zig', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua',
  'bash=sh', 'zsh', 'vim', 'sql', 'yaml', 'json', 'jsonc' }

-- Docset
vim.api.nvim_create_user_command('LspHover', vim.lsp.buf.hover, { nargs = '*', range = true })

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

-- Quit
local function is_auxiliary_window(win_id)
  if not vim.api.nvim_win_is_valid(win_id) then
    return true
  end

  local buf = vim.api.nvim_win_get_buf(win_id)
  if not vim.api.nvim_buf_is_valid(buf) then
    return true
  end

  local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local is_preview = vim.api.nvim_get_option_value('previewwindow', { win = win_id })
  local win_config = vim.api.nvim_win_get_config(win_id)

  if is_preview then return true end
  if buftype == 'quickfix' then return true end
  if buftype == 'help' then return true end
  if buftype == 'terminal' then return true end
  if buftype == 'nofile' and filetype == 'man' then return true end

  if filetype == 'NvimTree' or filetype == 'neo-tree' then return true end
  if filetype == 'dap-repl' or filetype == 'dapui_watches' or filetype == 'dapui_breakpoints' then return true end

  if win_config.relative ~= '' then return true end

  if buftype == 'nofile' and vim.api.nvim_buf_get_name(buf) == '' and
      not vim.api.nvim_get_option_value('modified', { buf = buf }) then
    return true
  end

  return false
end

local function focus_to_valid_window()
  local current = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_is_valid(current) and not is_auxiliary_window(current) then
    return true
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and not is_auxiliary_window(win) then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end

  return false
end

local function close_gitsigns_diff()
  if not vim.wo.diff then return false end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.bufname(vim.api.nvim_win_get_buf(win)):match('^gitsigns:') then
      -- The buffer is acwrite and may be marked modified (e.g. stray edits);
      -- it is an ephemeral view regenerated from git, so discard and close.
      vim.api.nvim_win_close(win, true)
      return true
    end
  end
  return false
end

vim.keymap.set('n', 'q', function()
  if close_gitsigns_diff() then return end

  local cur_tab = vim.api.nvim_get_current_tabpage()
  local win_id = vim.api.nvim_get_current_win()
  local has_other_window = false
  local total_valid = 0
  local tab_valid = 0

  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if w ~= win_id then
      has_other_window = true
      local is_in_cur_tab = (vim.api.nvim_win_get_tabpage(w) == cur_tab)
      if not is_auxiliary_window(w) then
        total_valid = total_valid + 1
        if is_in_cur_tab then
          tab_valid = tab_valid + 1
        end
      end
    end
  end

  if not has_other_window or total_valid == 0 then
    vim.cmd('confirm quitall')
  elseif tab_valid == 0 then
    vim.cmd('tabclose')
    focus_to_valid_window()
  else
    vim.cmd('quit')
    focus_to_valid_window()
  end
end, { silent = true })

vim.keymap.set('n', '<S-q>', '<cmd>confirm quitall<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, 't', 'q')

-- Ctags
-- Resolve a tag's real line number by searching its pattern in the target buffer.
local function ctags_resolve_lnum(t)
  local cmd = t.cmd or ''
  local pattern = cmd:match('^/(.*)/$')
  if not pattern then
    return tonumber(cmd:match('^(%d+)'))
  end
  local bufnr = vim.fn.bufnr(t.filename)
  if bufnr == -1 then
    bufnr = vim.fn.bufadd(t.filename)
  end
  vim.fn.bufload(bufnr)
  local re = vim.regex(pattern)
  for i = 1, vim.api.nvim_buf_line_count(bufnr) do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if re:match_str(line) then
      return i
    end
  end
  return tonumber(cmd:match('^(%d+)'))
end

vim.keymap.set('n', 'gd', '<C-]>')
vim.keymap.set('n', 'g]', function()
  local tagfunc = vim.bo.tagfunc
  vim.bo.tagfunc = nil
  local name = vim.fn.expand('<cword>')
  local tags = vim.fn.taglist('^' .. vim.fn.escape(name, '\\^$.') .. '$')
  local items = {}
  for _, t in ipairs(tags) do
    table.insert(items, {
      filename = t.filename,
      lnum = ctags_resolve_lnum(t) or 0,
      col = 1,
      text = t.name,
    })
  end

  local ok = pcall(vim.cmd, 'tag ' .. name)
  if not ok then
    vim.bo.tagfunc = tagfunc
    vim.notify('Tag not found: ' .. name, vim.log.levels.ERROR)
    return
  end
  vim.fn.setqflist(items, 'r')
  vim.fn.setqflist({}, 'a', { title = 'tag ' .. name })

  vim.bo.tagfunc = tagfunc
  require('trouble').open('quickfix')
end, { silent = true, desc = 'tag + open quickfix' })

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  group = vim.api.nvim_create_augroup('Ctags', { clear = true }),
  pattern = '*.tags',
  command = 'setfiletype tags',
})

-- mini.indentscope
require('mini.indentscope').setup({ draw = { delay = 0 } })

-- mini.ai
local gen_ai_spec = require('mini.extra').gen_ai_spec
require('mini.ai').setup({
  custom_textobjects = {
    i = gen_ai_spec.indent(),
    L = gen_ai_spec.line(),
    B = gen_ai_spec.buffer(),
  },
  mappings = {
    goto_left = '',
    goto_right = '',
  },
})

-- mini.surround
require('mini.surround').setup({
  search_method = 'cover_or_next',
})

-- Bare `s` has no surround action. Without this, a timed-out `s` falls
-- through to native substitute (cl) and deletes the char under cursor.
-- <Nop> makes that fallback harmless.
vim.keymap.set('n', 's', '<Nop>')
vim.keymap.set('x', 's', '<Nop>')

-- Comment.nvim
require('Comment').setup()

-- nvim-autopairs
local npairs = require('nvim-autopairs')
npairs.setup()

local rule = require('nvim-autopairs.rule')
npairs.add_rule(rule('"', '"', 'vim'):with_pair(function() return false end))

-- substitute.nvim
require('substitute').setup()

vim.keymap.set('n', 'x', require('substitute').operator, { silent = true })
vim.keymap.set('x', 'x', require('substitute').visual, { silent = true })
vim.keymap.set('n', 'xx', require('substitute').line, { silent = true })
vim.keymap.set('n', 'X', require('substitute').eol, { silent = true })

-- marks.nvim
require('marks').setup()

-- nvim-treesitter
require('nvim-treesitter').setup({
  highlight = { enable = true },
  indent = { enable = true },
  auto_install = true,
})
require('nvim-treesitter.install').install({
  'c', 'cpp', 'zig', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua', 'bash', 'vim', 'vimdoc', 'markdown',
  'markdown_inline', 'yaml', 'json', 'sql',
})

-- Git
local gitsigns = require('gitsigns')
gitsigns.setup()

vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { silent = true })
vim.keymap.set('n', '<leader>gl', '<cmd>NeogitLogCurrent<CR>', { silent = true })
vim.keymap.set('x', '<leader>gl', ":'<,'>NeogitLogCurrent<CR>", { silent = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', { silent = true })
vim.keymap.set('n', '<leader>gD', '<cmd>CodeDiff<CR>', { silent = true })
vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', { silent = true })
vim.keymap.set('n', '<leader>gB', '<cmd>Gitsigns blame<CR>', { silent = true })

vim.keymap.set('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { silent = true })
vim.keymap.set('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { silent = true })
vim.keymap.set('n', '<leader>hq', '<cmd>Gitsigns setqflist<CR>', { silent = true })
vim.keymap.set('n', '<leader>hQ', '<cmd>Gitsigns setqflist all<CR>', { silent = true })
vim.keymap.set('n', '<leader>hl', '<cmd>Gitsigns setloclist<CR>', { silent = true })
vim.keymap.set('n', '<leader>hp', '<cmd>Gitsigns preview_hunk_inline<CR>', { silent = true })
vim.keymap.set('n', '<leader>hP', '<cmd>Gitsigns preview_hunk<CR>', { silent = true })
vim.keymap.set('n', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', { silent = true })
vim.keymap.set('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>', { silent = true })
vim.keymap.set('n', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', { silent = true })
vim.keymap.set('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>', { silent = true })

-- oil.nvim
require('oil').setup({
  view_options = { show_hidden = true, show_icons = false },
})

vim.keymap.set('n', '-', function()
  require('oil').open(vim.fn.expand('%:p:h'))
end, { silent = true })

vim.keymap.set('n', '~', function()
  local root = vim.fs.root(0, patterns) or vim.fn.expand('~')
  require('oil').open(root)
end, { silent = true })

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

-- trouble.nvim
vim.keymap.set('n', '<leader>d', '<cmd>Trouble diagnostics toggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>q', '<cmd>Trouble quickfix toggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>l', '<cmd>Trouble loclist toggle<CR>', { silent = true })

-- LSP
vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'Search' })
vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'Search' })
vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'Search' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('Lsp', { clear = true }),
  callback = function(args)
    local buf = args.buf
    local bufopts = { buffer = buf, silent = true }

    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    local function handle_locations(result)
      if result.items and #result.items == 1 then
        local item = result.items[1]
        local b = vim.fn.bufadd(item.filename)
        vim.cmd("normal! m'")
        vim.bo[b].buflisted = true
        vim.api.nvim_set_current_buf(b)
        vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
        return
      end
      vim.fn.setqflist({}, ' ', result)
      require('trouble').open('quickfix')
    end

    vim.keymap.set('n', 'gd', function()
      vim.lsp.buf.definition({ on_list = handle_locations })
    end, bufopts)
    vim.keymap.set('n', 'gc', function()
      vim.lsp.buf.declaration({ on_list = handle_locations })
    end, bufopts)
    vim.keymap.set('n', 'gt', function()
      vim.lsp.buf.type_definition({ on_list = handle_locations })
    end, bufopts)
    vim.keymap.set('n', 'gi', function()
      vim.lsp.buf.implementation({ on_list = handle_locations })
    end, bufopts)
    vim.keymap.set('n', 'gr', function()
      vim.lsp.buf.references({ includeDeclaration = true }, {
        on_list = handle_locations,
      })
    end, bufopts)

    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, bufopts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, bufopts)
    vim.keymap.set('n', '[D', function() vim.diagnostic.jump({ count = -999 }) end, bufopts)
    vim.keymap.set('n', ']D', function() vim.diagnostic.jump({ count = 999 }) end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)

    local has_highlight = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if client:supports_method('textDocument/documentHighlight') then
        has_highlight = true
        break
      end
    end
    if has_highlight then
      vim.api.nvim_create_autocmd('CursorHold', {
        buffer = buf,
        group = vim.api.nvim_create_augroup('Lsp', { clear = false }),
        callback = function()
          if vim.fn.getcmdtype() ~= '' then
            return
          end
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = buf,
        group = vim.api.nvim_create_augroup('Lsp', { clear = false }),
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--background-index-priority=background',
    '--clang-tidy',
    '--cross-file-rename',
    '--all-scopes-completion=true',
    '--completion-style=detailed',
    '--function-arg-placeholders=true',
    '--header-insertion=iwyu',
    '--header-insertion-decorators',
    '--limit-references=0',
    '--limit-results=0',
  },
  filetypes = { 'c', 'cpp' },
  root_markers = { '.git' },
})

vim.lsp.config('zls', {
  cmd = { 'zls' },
  filetypes = { 'zig' },
  root_markers = { 'build.zig', 'build.zig.zon' },
  settings = {
    zls = {
      enable_inlay_hints = true,
      enable_snippets = true,
    },
  },
})

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = { command = 'clippy' },
      procMacro = { enable = true },
      cargo = { allFeatures = true },
    },
  },
})

vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gosum', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod' },
  settings = {
    gopls = {
      analyses = {
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hoverKind = 'FullDocumentation',
      gofumpt = true,
      completeUnimported = true,
      staticcheck = true,
      usePlaceholders = true,
      completionDocumentation = true,
      codelenses = {
        generate = true,
        test = true,
        run_vulncheck_exp = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

vim.lsp.config('typescript-language-server', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'typescript' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json' },
  settings = {
    typescript = { suggest = { completeFunctionCalls = true } },
    javascript = { suggest = { completeFunctionCalls = true } },
  },
})

vim.lsp.config('pylsp', {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true },
        pylint = { enabled = false },
        pycodestyle = {
          enabled = true,
          maxLineLength = 120,
          ignore = { 'E501', 'W503' },
        },
        rope_autoimport = {
          enabled = true,
          completions = { enabled = true },
          code_actions = { enabled = true },
        },
      },
    },
  },
})

vim.lsp.config('lua-language-server', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config('bash-language-server', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh' },
  root_markers = { '.shellcheckrc', '.git' },
  settings = {
    bashIde = {
      globPattern = '**/*@(.sh|.inc|.bash|.command|.bashrc|.bash_profile|.profile)',
      includeAllWorkspaceSymbols = true,
    },
  },
})

vim.lsp.config('vim-language-server', {
  cmd = { 'vim-language-server', '--stdio' },
  filetypes = { 'vim' },
  root_markers = { '.git' },
})

vim.lsp.config('marksman', {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown' },
  root_markers = { '.marksman.toml', '.git' },
})

vim.lsp.config('efm-langserver', {
  cmd = { 'efm-langserver' },
  filetypes = { 'markdown' },
  root_markers = { '.git' },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = false,
    documentDiagnostics = true,
    codeAction = false,
  },
})

vim.lsp.config('yaml-language-server', {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
        url = 'https://www.schemastore.org/api/json/catalog.json',
      },
      completion = true,
      hover = true,
      validate = true,
    },
  },
})

vim.lsp.config('vscode-json-language-server', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  init_options = { provideFormatter = true },
  settings = {
    json = {
      validate = { enable = true },
    },
  },
})

local cmp_nvim_lsp = require('cmp_nvim_lsp')
vim.lsp.config('*', { capabilities = cmp_nvim_lsp.default_capabilities() })

local enabled = {
  'clangd', 'zls', 'rust_analyzer', 'gopls', 'typescript-language-server', 'pylsp', 'lua-language-server',
  'bash-language-server', 'vim-language-server', 'marksman', 'efm-langserver', 'yaml-language-server',
  'vscode-json-language-server',
}
for _, name in ipairs(enabled) do
  vim.lsp.enable(name)
end

vim.diagnostic.config({ virtual_lines = { current_line = true } })

local format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_augroup,
  callback = function(args)
    local clients = vim.lsp.get_clients({ bufnr = args.buf })
    if #clients == 0 then return end
    vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
  end,
})

-- nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-l>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

require('cmp_cmdline')

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})
