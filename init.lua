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
  {
    src = 'https://github.com/stevearc/oil.nvim',
    cmd = 'Oil',
    keys = {
      { '-', function() require('oil').open(vim.fn.expand('%:p:h')) end, desc = 'Open parent dir' },
      {
        '~',
        function()
          local patterns = { '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout' }
          local root = vim.fs.root(0, patterns) or vim.fn.expand('~')
          require('oil').open(root)
        end,
        desc = 'Open project root or home'
      },
    },
    config = function()
      require('oil').setup({ view_options = { show_hidden = true, show_icons = false } })
    end,
  },
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
      local project_root = vim.fs.root(0, vim.g.gutentags_project_root) or vim.fn.getcwd()
      local gtags_dbpath = vim.fs.normalize(vim.fn['gutentags#get_cachefile'](project_root, ''))
      require("cscope_maps").setup({
        disable_maps = true,
        cscope = {
          exec = 'gtags-cscope',
          picker = "trouble",
          project_rooter = { enable = false },
          tag = { keymap = false },
        },
      })
      vim.g.cscope_maps_db_file = gtags_dbpath .. '/GTAGS::' .. project_root
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
    },
    config = function()
      require('toggleterm').setup({ size = 20, direction = 'horizontal', start_in_insert = true })
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

vim.cmd('syntax on')

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
      return vim.fn.empty(vim.fn.getenv('SSH_TTY')) == 0 and 'remote_ssh' or 'pseudo_terminal'
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

-- CheckFileChanges
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufWinEnter', 'WinEnter', 'CursorHold' }, {
  group = vim.api.nvim_create_augroup('CheckFileChanges', { clear = true }),
  callback = function()
    if vim.fn.getcmdtype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- lualine.nvim
local function mc()
  return package.loaded['multicursor-nvim']
end
local function mc_active()
  return mc() ~= nil and mc().hasCursors()
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
        color = function()
          if mc_active() then
            if is_tty_console then
              return { fg = 0, bg = 13, gui = 'bold' }
            end
            local purple = vim.fn.mode() ~= 'n' and '#9d7cd8' or '#bb9af7'
            return { fg = '#1a1b26', bg = purple, gui = 'bold' }
          end
          return {}
        end,
      },
    },
    lualine_b = {
      { 'branch', icon = '⎇' },
      { 'diff' },
      { 'diagnostics' },
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
    lualine_z = { 'location' },
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

-- Session / Restore
vim.opt.sessionoptions:remove({ 'blank', 'options', 'folds', 'terminal' })

-- auto-session
require('auto-session').setup({
  log_level = 'error',
  auto_save_enabled = true,
  auto_restore_enabled = true,
})

vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<CR>', { silent = true })
vim.keymap.set('n', '<leader>rs', '<cmd>AutoSession delete<CR>', { silent = true })

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

-- Determine project root and gtags cache path once at startup
local project_root = vim.fs.root(0, vim.g.gutentags_project_root) or vim.fn.getcwd()
local gtags_dbpath = vim.fs.normalize(vim.fn['gutentags#get_cachefile'](project_root, ''))
vim.env.GTAGSROOT = project_root
vim.env.GTAGSDBPATH = gtags_dbpath

vim.keymap.set('n', 'gs', '<Cmd>Cscope find s<CR>', { silent = true })
vim.keymap.set('n', 'gD', '<Cmd>Cstag<CR>', { silent = true })
vim.keymap.set('n', 'gR', '<Cmd>Cscope find c<CR>', { silent = true })

-- Auto-build GTAGS
local function gtags_build()
  if vim.g.gtags_building then return end
  vim.fn.mkdir(gtags_dbpath, 'p')
  vim.g.gtags_building = true
  vim.system({ 'gtags', gtags_dbpath }, { cwd = project_root, text = true }, function(obj)
    vim.schedule(function()
      vim.g.gtags_building = nil
      if obj.code ~= 0 then
        vim.notify('gtags: build failed', vim.log.levels.ERROR)
      end
    end)
  end)
end

local function gtags_update()
  if vim.fn.glob(gtags_dbpath .. '/GTAGS') == '' then return end
  if vim.g.gtags_building then return end
  vim.g.gtags_building = true
  vim.system({ 'global', '--update' }, { cwd = project_root, text = true }, function(obj)
    vim.schedule(function()
      vim.g.gtags_building = nil
      if obj.code ~= 0 then
        vim.notify('gtags: update failed', vim.log.levels.ERROR)
      end
    end)
  end)
end

local gtags_group = vim.api.nvim_create_augroup('GTags', { clear = true })

-- Build GTAGS on BufEnter when missing
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = gtags_group,
  callback = function(e)
    if vim.bo[e.buf].buftype ~= '' or not vim.bo[e.buf].modifiable then return end
    if vim.fn.expand('#' .. e.buf .. ':p') == '' then return end
    if vim.fn.glob(gtags_dbpath .. '/GTAGS') ~= '' then return end
    gtags_build()
  end,
  desc = 'build GTAGS on BufEnter when missing',
})

-- Incremental update on BufWritePost
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = gtags_group,
  callback = function(e)
    if vim.bo[e.buf].buftype ~= '' or not vim.bo[e.buf].modifiable then return end
    if vim.fn.expand('#' .. e.buf .. ':p') == '' then return end
    gtags_update()
  end,
  desc = 'incremental GTAGS update on save',
})

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
-- Use the GUI clipboard (X11/Wayland/macOS) when a display is available
-- and we are not on a real console (kmscon/TTY), where the GUI clipboard
-- is unusable; there, fall back to tmux buffers.
local is_physical_console = root_terminal == 'kmscon' or root_terminal == 'tty' or root_terminal == 'physical_console'
local has_display = vim.fn.empty(vim.fn.getenv('DISPLAY')) == 0
local has_wayland = vim.fn.empty(vim.fn.getenv('WAYLAND_DISPLAY')) == 0
local has_mac = vim.fn.has('mac') == 1
local has_tmux = vim.fn.empty(vim.fn.getenv('TMUX')) == 0
local has_unnamedplus = vim.fn.has('unnamedplus') == 1
if not is_physical_console and (has_display or has_wayland or has_mac) then
  vim.opt.clipboard = has_unnamedplus and 'unnamed,unnamedplus' or 'unnamed'
elseif has_tmux then
  vim.opt.clipboard = 'unnamed,unnamedplus'
  vim.g.clipboard = 'tmux'
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
vim.keymap.set('n', '<leader>o', function()
  local name = vim.fn.input('New buffer name: ', '', 'file')
  if name ~= '' then
    vim.cmd('edit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '[b', '<cmd>bprevious<CR>', { silent = true })
vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { silent = true })

-- Tab
vim.keymap.set('n', '<leader><leader>t', function()
  local name = vim.fn.input('New tab name: ', '', 'file')
  if name ~= '' then
    vim.cmd('tabnew ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '[t', '<cmd>tabprevious<CR>', { silent = true })
vim.keymap.set('n', ']t', '<cmd>tabnext<CR>', { silent = true })
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt')
end
vim.keymap.set('n', '<leader>[', '<cmd>tabfirst<CR>', { silent = true })
vim.keymap.set('n', '<leader>]', '<cmd>tablast<CR>', { silent = true })

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
  pattern = { 'rust', 'python', 'markdown' },
  callback = function(args)
    vim.bo[args.buf].expandtab = true
    vim.bo[args.buf].tabstop = 4
    vim.bo[args.buf].shiftwidth = 4
    vim.bo[args.buf].softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = filetype_group,
  pattern = { 'javascript', 'typescript', 'lua', 'yaml', 'json' },
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
vim.g.markdown_fenced_languages = { 'c', 'cpp', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua', 'bash=sh',
  'zsh', 'vim', 'sql', 'yaml', 'json' }

-- Docset
vim.api.nvim_create_user_command('LspHover', vim.lsp.buf.hover, { nargs = '*', range = true })
-- 'keywordprg' defaults to ':Man' on non-Windows, so no global override is needed.

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
  pattern = { 'cpp', 'rust', 'go', 'gomod', 'gowork', 'gosum', 'gotmpl',
    'javascript', 'typescript', 'python', 'lua', 'sh', 'markdown', 'yaml', 'json' },
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
      vim.api.nvim_win_close(win, false)
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
    vim.cmd('silent! confirm quitall!')
  elseif tab_valid == 0 then
    vim.cmd('tabclose')
    focus_to_valid_window()
  else
    vim.cmd('quit')
    focus_to_valid_window()
  end
end, { silent = true })

vim.keymap.set('n', '<S-q>', '<cmd>silent! confirm quitall!<CR>', { silent = true })
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
require('mini.ai').setup({
  mappings = {
    goto_left = '',
    goto_right = '',
  },
})

-- mini.surround (vim-surround compatible mappings)
require('mini.surround').setup({
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = 'cs',
  },
  search_method = 'cover_or_next',
})
vim.keymap.set('n', 'yss', 'ys_', { remap = true })
vim.keymap.del('x', 'ys')
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

-- Comment.nvim
require('Comment').setup()

-- nvim-autopairs
local npairs = require('nvim-autopairs')
npairs.setup()

local rule = require('nvim-autopairs.rule')
npairs.add_rule(rule('"', '"', 'vim'):with_pair(function() return false end))

-- substitute.nvim
require('substitute').setup()

vim.keymap.set('n', 's', require('substitute').operator, { silent = true })
vim.keymap.set('x', 's', require('substitute').visual, { silent = true })
vim.keymap.set('n', 'ss', require('substitute').line, { silent = true })
vim.keymap.set('n', 'S', require('substitute').eol, { silent = true })

-- marks.nvim
require('marks').setup()

-- nvim-treesitter
require('nvim-treesitter').setup({
  highlight = { enable = true },
  indent = { enable = true },
  auto_install = true,
})
require('nvim-treesitter.install').install({
  'c', 'cpp', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua', 'bash', 'vim', 'vimdoc', 'markdown',
  'markdown_inline', 'yaml', 'json', 'sql',
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

-- sudo write
vim.api.nvim_create_user_command('SudoWrite', function()
  vim.cmd('write !sudo tee % >/dev/null && edit!')
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
  filetypes = { 'json' },
  root_markers = { '.git' },
  init_options = { provideFormatter = true },
})

local cmp_nvim_lsp = require('cmp_nvim_lsp')
vim.lsp.config('*', { capabilities = cmp_nvim_lsp.default_capabilities() })

local enabled = {
  'clangd', 'rust_analyzer', 'gopls', 'typescript-language-server', 'pylsp', 'lua-language-server',
  'bash-language-server', 'vim-language-server', 'marksman', 'yaml-language-server', 'vscode-json-language-server',
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
