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
  { src = 'https://github.com/nvim-mini/mini.ai' },
  { src = 'https://github.com/nvim-mini/mini.surround' },
  { src = 'https://github.com/nvim-mini/mini.extra' },
  { src = 'https://github.com/nvim-mini/mini.comment' },
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
      { '<leader>e',  function() require('fzf-lua').blines() end,       desc = 'Buffer lines' },
      { '<leader>a',  function() require('fzf-lua').grep_cword() end,   desc = 'Grep cword' },
      { '<leader>a',  function() require('fzf-lua').grep_visual() end,  mode = 'v',                 desc = 'Grep visual' },
      { '<leader>gg', function() require('fzf-lua').git_status() end,   desc = 'Git status' },
      { '<leader>gc', function() require('fzf-lua').git_bcommits() end, desc = 'Git buffer commits' },
      { '<leader>gc', function() require('fzf-lua').git_bcommits() end, mode = 'x',                 desc = 'Git commits for selected lines' },
      { '<leader>gC', function() require('fzf-lua').git_commits() end,  desc = 'Git commits (repo)' },
    },
    config = function()
      local fzf_lua = require('fzf-lua')
      fzf_lua.setup({
        ui_select = {},
        defaults = {
          silent = true,
          file_ignore_patterns = { '.git/', '.hg/', '.svn/', '.bzr/' },
        },
        winopts = {
          height = 0.9,
          preview = { wrap = true },
        },
        keymap = {
          builtin = { ['<F2>'] = 'hide' },
          fzf = {
            ['ctrl-j'] = 'down',
            ['ctrl-k'] = 'up',
            ['alt-u'] = 'preview-half-page-up',
            ['alt-d'] = 'preview-half-page-down',
            ['alt-f'] = 'preview-page-down',
            ['alt-b'] = 'preview-page-up',
            ['alt-j'] = 'preview-down',
            ['alt-k'] = 'preview-up',
          },
        },
        git = {
          status = {
            actions = {
              ['ctrl-h'] = { fn = fzf_lua.actions.git_stage, reload = true },
              ['ctrl-l'] = { fn = fzf_lua.actions.git_unstage, reload = true },
            },
          },
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
    dependencies = { src = 'https://github.com/kevinhwang91/promise-async' },
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
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup()
      vim.keymap.set('n', '[c', function() require('treesitter-context').go_to_context() end,
        { silent = true, desc = 'Jump to context' })
    end,
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          lookahead = true,
          selection_modes = { ['@function.outer'] = 'V', ['@class.outer'] = 'V' },
        },
        move = { set_jumps = true },
      })
      local select = require('nvim-treesitter-textobjects.select')
      local selects = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aP'] = '@parameter.outer',
        ['iP'] = '@parameter.inner',
        ['aL'] = '@loop.outer',
        ['iL'] = '@loop.inner',
        ['ad'] = '@conditional.outer',
        ['id'] = '@conditional.inner',
        ['aC'] = '@comment.outer',
        ['iC'] = '@comment.inner',
      }
      for lhs, query in pairs(selects) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { silent = true, desc = 'ts textobj ' .. lhs })
      end
      local move = require('nvim-treesitter-textobjects.move')
      local moves = {
        [']f'] = { move.goto_next_start, '@function.outer' },
        ['[f'] = { move.goto_previous_start, '@function.outer' },
        [']F'] = { move.goto_next_end, '@function.outer' },
        ['[F'] = { move.goto_previous_end, '@function.outer' },
        [']c'] = { move.goto_next_start, '@class.outer' },
        ['[c'] = { move.goto_previous_start, '@class.outer' },
        [']C'] = { move.goto_next_end, '@class.outer' },
        ['[C'] = { move.goto_previous_end, '@class.outer' },
        [']P'] = { move.goto_next_start, '@parameter.outer' },
        ['[P'] = { move.goto_previous_start, '@parameter.outer' },
        [']L'] = { move.goto_next_start, '@loop.outer' },
        ['[L'] = { move.goto_previous_start, '@loop.outer' },
      }
      for lhs, fn in pairs(moves) do
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          fn[1](fn[2], 'textobjects')
        end, { silent = true, desc = 'ts move ' .. lhs })
      end

      local swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', '<leader>x', function() swap.swap_next('@parameter.inner') end,
        { silent = true, desc = 'swap param forward' })
      vim.keymap.set('n', '<leader>X', function() swap.swap_previous('@parameter.inner') end,
        { silent = true, desc = 'swap param backward' })
    end,
  },
  {
    src = 'https://github.com/saghen/blink.cmp',
    dependencies = { src = 'https://github.com/saghen/blink.lib' },
    build = function() require('blink.cmp').build():pwait() end,
  },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}

local git_specs = {
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/nvim-mini/mini-git' },
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
    config = function()
      require("cscope_maps").setup({
        disable_maps = true,
        cscope = {
          exec = 'gtags-cscope',
          picker = "quickfix",
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
    src = 'https://github.com/kevinhwang91/nvim-bqf',
    dependencies = { src = 'https://github.com/junegunn/fzf' },
    ft = 'qf',
    config = function()
      require('bqf').setup({
        auto_resize_height = true,
      })
      -- Workaround for a nvim-bqf bug: leaving zf (fzf filter) mode leaks the
      -- old preview float, which overlays the fresh one as a gray film. When
      -- the fzf window closes, wait for bqf to finish restoring the list,
      -- then close ALL BqfPreview* windows (the leaked one cannot be told
      -- apart from the fresh one) and re-open the preview for the list
      -- window zf was launched from (quickfix or loclist) right away instead
      -- of waiting for the next cursor move.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('BqfFzfOrphan', { clear = true }),
        pattern = 'fzf',
        callback = function(args)
          local fzf_win = vim.fn.bufwinid(args.buf)
          if fzf_win == -1 then
            return
          end
          local src_win = vim.fn.win_getid(vim.fn.winnr('#'))
          vim.api.nvim_create_autocmd('WinClosed', {
            pattern = tostring(fzf_win),
            once = true,
            callback = function()
              vim.defer_fn(function()
                for _, wid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                  local bufnr = vim.api.nvim_win_get_buf(wid)
                  if vim.fn.bufname(bufnr):find('^BqfPreview') and vim.api.nvim_win_is_valid(wid) then
                    vim.api.nvim_win_close(wid, true)
                  end
                end
                if vim.api.nvim_win_is_valid(src_win) then
                  require('bqf.preview.handler').open(src_win, nil, true)
                end
              end, 150)
            end,
          })
        end,
      })
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
  { src = 'https://github.com/milanglacier/minuet-ai.nvim' },
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
-- multi-cursor session both turn purple. Colors point at the theme's purple
-- groups so they follow the active colorscheme.
local function mc_color()
  if not mc_active() then return {} end
  if is_tty_console then return { fg = 0, bg = 13, gui = 'bold' } end
  return 'MiniStatuslineModeOther'
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
      'filetype', 'encoding', 'fileformat',
    },
    lualine_y = {
      function()
        return string.format('%d%%%%', math.floor((100 * vim.fn.line('.')) / vim.fn.line('$')))
      end,
    },
    lualine_z = {
      {
        function()
          return string.format('%d/%d:%d', vim.fn.line('.'), vim.fn.line('$'), vim.fn.col('.'))
        end,
        color = mc_color,
      },
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
  pre_save_cmds = {
    -- mksession drops terminal buffers but still rebuilds their windows as
    -- blank tabs/splits: quitting with no real-file window left saves a
    -- session that restores as a blank nvim. So close terminal windows
    -- first (the last one cannot close, E444, and falls through to the
    -- fallback), then point the remaining window at the most recently
    -- used file buffer.
    function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == 'terminal' then
          pcall(vim.api.nvim_win_close, win, false)
        end
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buflisted and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= '' then
          return
        end
      end

      local last
      for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if vim.bo[info.bufnr].buflisted and vim.bo[info.bufnr].buftype == '' and vim.api.nvim_buf_get_name(info.bufnr) ~= ''
            and (not last or info.lastused > last.lastused) then
          last = info
        end
      end
      if last then vim.api.nvim_set_current_buf(last.bufnr) end
    end,
  },
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
          vim.g.SEND_PANE_ID = pane
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
    if pane then
      local check = vim.fn.system({ 'tmux', 'display-message', '-p', '-t', pane, '#{pane_id}' })
      if vim.v.shell_error ~= 0 or not check:find(pane, 1, true) then
        vim.g.SEND_PANE_ID = nil
        vim.notify('send-to-pane: attached pane is gone, detached', vim.log.levels.WARN)
        pane = nil
      end
    end
    if pane then
      return tmux_send(pane, text, submit)
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
    vim.g.SEND_PANE_ID = pane
    vim.notify('send-to-pane: attached ' .. pane)
  end)
end, { desc = 'Attach pane' })
vim.keymap.set('n', '<leader>sd', function()
  vim.notify('send-to-pane: detached ' .. (vim.g.SEND_PANE_ID or 'nothing'))
  vim.g.SEND_PANE_ID = nil
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

-- Switch the cscope DB to the entered buffer's project and build GTAGS when missing
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
local tags_git_subcommands = {
  'branch', 'checkout', 'switch', 'restore', 'reset', 'merge', 'rebase', 'cherry-pick', 'revert', 'stash', 'pull',
}
vim.api.nvim_create_autocmd('User', {
  group = tags_group,
  pattern = 'MiniGitCommandDone',
  callback = function(args)
    if vim.list_contains(tags_git_subcommands, args.data.git_subcommand) then
      tags_check_branch()
    end
  end,
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
  callback = function()
    if vim.bo.buftype == 'terminal' then return end
    vim.cmd('set relativenumber')
  end,
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'InsertEnter' }, {
  group = relativenumber_group,
  callback = function()
    if vim.bo.buftype == 'terminal' then return end
    vim.cmd('set norelativenumber number')
  end,
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

-- Clipboard
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
-- Blacklist: filetypes that skip trailing-whitespace highlighting
vim.g.trailing_whitespace_blacklist = { 'fzf', 'terminal', 'help' }
vim.api.nvim_set_hl(0, 'TrailingSpace', { link = 'IncSearch' })
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'FileType' }, {
  group = vim.api.nvim_create_augroup('TrailingWhitespace', { clear = true }),
  callback = function()
    local win = vim.api.nvim_get_current_win()
    vim.schedule(function()
      if not vim.api.nvim_win_is_valid(win) then
        return
      end
      for _, m in ipairs(vim.fn.getmatches(win)) do
        if m.group == 'TrailingSpace' then
          vim.fn.matchdelete(m.id, win)
        end
      end
      local bo = vim.bo[vim.api.nvim_win_get_buf(win)]
      if bo.buftype == '' and not vim.tbl_contains(vim.g.trailing_whitespace_blacklist, bo.filetype) then
        vim.fn.matchadd('TrailingSpace', [[\s\+$]], -1, -1, { window = win })
      end
    end)
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
  callback = function()
    local cur = vim.api.nvim_get_current_tabpage()
    vim.cmd('tabdo wincmd =')
    vim.api.nvim_set_current_tabpage(cur)
  end,
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
  vim.cmd('botright copen')
end, { silent = true, desc = 'tag + open quickfix' })

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  group = vim.api.nvim_create_augroup('Ctags', { clear = true }),
  pattern = '*.tags',
  command = 'setfiletype tags',
})

-- mini.ai
local gen_ai_spec = require('mini.extra').gen_ai_spec
require('mini.ai').setup({
  custom_textobjects = {
    i = gen_ai_spec.indent(),
    e = gen_ai_spec.line(),
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

-- mini.comment
require('mini.comment').setup()

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
gitsigns.setup({ preview_config = { border = 'rounded' } })
require('mini.git').setup({ command = { split = 'horizontal' } })

vim.keymap.set('n', '<leader>gl', '<cmd>tab Git log --oneline --follow -- %<CR>', { silent = true })
vim.keymap.set('n', '<leader>gL', '<cmd>tab Git log --oneline --graph --all<CR>', { silent = true })
vim.keymap.set({ 'n', 'x' }, '<leader>gS', function() MiniGit.show_at_cursor() end,
  { silent = true, desc = 'Git show at cursor (line/range history or commit)' })
vim.keymap.set('n', '<leader>gF', function() MiniGit.show_diff_source() end,
  { silent = true, desc = 'Git open file at commit under cursor' })
vim.keymap.set('n', '<leader>gd', '<cmd>Gitsigns diffthis<CR>', { silent = true })
vim.keymap.set('n', '<leader>gD', '<cmd>tab Git diff<CR>', { silent = true })
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

-- `:G` alias for `:Git` (fugitive-style): forwards modifiers, bang and args;
-- completion delegates to `:Git`'s context-aware completion by rewriting the
-- cmdline (e.g. `:G log --<Tab>` completes as `:Git log --<Tab>`)
local function g_complete(_, cmd_line, cursor_pos)
  local lead = cmd_line:match('^%S+')
  local git_line = cmd_line:gsub('^%S+', 'Git', 1)
  return vim.fn.getcompletion(git_line, 'cmdline', cursor_pos + ('Git'):len() - lead:len())
end
vim.api.nvim_create_user_command('G', function(input)
  vim.cmd(('%s Git%s %s'):format(input.mods, input.bang and '!' or '', input.args))
end, { bang = true, nargs = '+', bar = true, complete = g_complete, desc = 'Alias for :Git' })

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

-- quickfix / loclist / diagnostics
local function qf_toggle(open, close_cmd)
  local ftype = vim.bo.filetype
  local last_winnr = vim.fn.winnr('#')
  local win_count = #vim.fn.tabpagebuflist()
  vim.cmd('silent! ' .. close_cmd)
  if #vim.fn.tabpagebuflist() == win_count then
    if type(open) == 'function' then
      open()
    else
      vim.cmd('silent! botright ' .. open)
    end
  elseif ftype == 'qf' then
    vim.cmd(last_winnr .. 'wincmd w')
  end
end

vim.keymap.set('n', '<leader>d', function()
  qf_toggle(function()
    vim.diagnostic.setloclist({ title = 'Diagnostics' })
    vim.cmd('botright lopen')
  end, 'lclose')
end, { silent = true, desc = 'Diagnostics into location list' })
vim.keymap.set('n', '<leader>q', function() qf_toggle('copen', 'cclose') end, { silent = true, desc = 'Toggle quickfix' })
vim.keymap.set('n', '<leader>l', function() qf_toggle('lopen', 'lclose') end,
  { silent = true, desc = 'Toggle location list' })

-- minuet-ai.nvim
local minuet_presets = {}
local minuet_preset_order = {}
local minuet_current_preset = vim.env.NVIM_MINUET_PRESET

local local_fim_name = vim.env.NVIM_MINUET_LOCAL_NAME or 'llama.cpp'
local local_fim_options = {
  api_key = 'TERM',
  name = local_fim_name,
  end_point = (vim.env.NVIM_MINUET_LOCAL_BASE_URL or 'http://localhost:8080') .. '/v1/completions',
  model = vim.env.NVIM_MINUET_LOCAL_MODEL or 'qwen2.5-coder:7b',
  stream = false,
  optional = {
    max_tokens = 64,
    top_p = 0.9,
  },
}

if local_fim_name == 'llama.cpp' then
  local_fim_options.get_text_fn = {
    no_stream = function(json)
      return json.content
    end,
  }
  local_fim_options.transform = {
    function(data)
      -- llama.cpp /infill: prompt/suffix -> input_prefix/input_suffix
      data.end_point = data.end_point:gsub('/v1/completions$', '/infill')
      data.body.input_prefix = data.body.prompt
      data.body.input_suffix = data.body.suffix or ''
      data.body.prompt = nil
      data.body.suffix = nil
      return data
    end,
  }
end

minuet_presets.local_fim = {
  n_completions = 1,
  context_window = 4096,
  request_timeout = 30,
  throttle = 1000,
  debounce = 300,
  provider = 'openai_fim_compatible',
  provider_options = {
    openai_fim_compatible = local_fim_options,
  },
}
minuet_preset_order[#minuet_preset_order + 1] = 'local_fim'

if vim.env.NVIM_MINUET_API_KEY
    and vim.env.NVIM_MINUET_BASE_URL
    and vim.env.NVIM_MINUET_MODEL
    and vim.env.NVIM_MINUET_NAME
then
  minuet_presets.openai = {
    context_window = 4096,
    request_timeout = 15,
    throttle = 3000,
    debounce = 500,
    provider = 'openai_compatible',
    provider_options = {
      openai_compatible = {
        api_key = 'NVIM_MINUET_API_KEY',
        name = vim.env.NVIM_MINUET_NAME,
        end_point = vim.env.NVIM_MINUET_BASE_URL .. '/v1/chat/completions',
        model = vim.env.NVIM_MINUET_MODEL,
        stream = false,
        optional = {
          max_tokens = 512,
          reasoning_effort = 'none',
        },
      },
    },
  }
  minuet_preset_order[#minuet_preset_order + 1] = 'openai'
end

if minuet_presets[minuet_current_preset] then
  require('minuet').setup({
    n_completions = minuet_presets[minuet_current_preset].n_completions or 1,
    context_window = minuet_presets[minuet_current_preset].context_window,
    request_timeout = minuet_presets[minuet_current_preset].request_timeout,
    throttle = minuet_presets[minuet_current_preset].throttle,
    debounce = minuet_presets[minuet_current_preset].debounce,
    provider = minuet_presets[minuet_current_preset].provider,
    provider_options = minuet_presets[minuet_current_preset].provider_options,
    presets = minuet_presets,
    cmp = { enable_auto_complete = false },
    virtualtext = {
      auto_trigger_ft = { '*' },
      auto_trigger_ignore_ft = {
        'help', 'markdown', 'text', 'gitcommit', 'gitrebase', 'qf', 'TelescopePrompt', 'DressingInput', 'terminal',
      },
    },
  })

  vim.keymap.set('n', '<leader>ig', '<cmd>Minuet virtualtext toggle<cr>', {
    desc = 'Minuet: toggle virtual text auto-trigger',
  })
  vim.keymap.set('n', '<leader>ia', function()
    local next_name
    for i, name in ipairs(minuet_preset_order) do
      if name == minuet_current_preset then
        next_name = minuet_preset_order[i % #minuet_preset_order + 1]
        break
      end
    end
    next_name = next_name or minuet_preset_order[1]
    require('minuet').change_preset(next_name)
    minuet_current_preset = next_name
  end, { desc = 'Minuet: cycle provider preset' })

  local minuet_vt = require('minuet.virtualtext').action
  vim.keymap.set('i', '<A-a>', minuet_vt.accept, { desc = 'Minuet: accept suggestion' })
  vim.keymap.set('i', '<A-l>', minuet_vt.accept_line, { desc = 'Minuet: accept one line' })
  vim.keymap.set('i', '<A-y>', minuet_vt.accept_n_lines, { desc = 'Minuet: accept n lines' })
  vim.keymap.set('i', '<A-n>', minuet_vt.next, { desc = 'Minuet: next suggestion' })
  vim.keymap.set('i', '<A-p>', minuet_vt.prev, { desc = 'Minuet: prev suggestion' })
  vim.keymap.set('i', '<A-d>', minuet_vt.dismiss, { desc = 'Minuet: dismiss suggestion' })
end

-- LSP
vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'Search' })
vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'Search' })
vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'Search' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('Lsp', { clear = true }),
  callback = function(args)
    local buf = args.buf
    local bufopts = { buffer = buf, silent = true }

    vim.keymap.set('n', 'gh', function() vim.lsp.buf.hover({ border = 'rounded' }) end, bufopts)

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gc', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', function() vim.lsp.buf.references({ includeDeclaration = true }) end, bufopts)

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

vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

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

-- blink.cmp
require('blink.cmp').setup({
  completion = {
    list = {
      selection = { preselect = true, auto_insert = true },
    },
    menu = { border = 'rounded' },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = 'rounded' },
    },
  },
  signature = {
    enabled = true,
    trigger = {
      show_on_keyword = true,
    },
    window = {
      border = 'rounded',
      max_width = 100,
    },
  },
  keymap = {
    preset = 'default',
    ['<Tab>'] = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
    ['<C-l>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
    ['<CR>'] = { 'select_and_accept', 'fallback' },
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
  },
  sources = {
    default = { 'lsp', 'snippets', 'buffer', 'path' },
    providers = {
      path = {
        enabled = function()
          return not (vim.fn.mode() == 'c' and (vim.fn.getcmdtype() == '/' or vim.fn.getcmdtype() == '?'))
        end,
      },
    },
  },
  cmdline = {
    sources = { default = { 'path', 'cmdline', 'buffer' } },
    completion = {
      menu = { auto_show = true },
      list = { selection = { preselect = true, auto_insert = true } },
    },
  },
})
