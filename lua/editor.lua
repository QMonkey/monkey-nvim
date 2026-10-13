local M = {}

-- Generic editor options, keymaps and autocmds + text-editing plugins
-- (mini.*, autopairs, substitute, marks, matchup, multicursor)
M.spec = {
  {
    src = 'https://github.com/nvim-mini/mini.ai',
    config = function()
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
    end,
  },
  {
    src = 'https://github.com/nvim-mini/mini.surround',
    config = function()
      require('mini.surround').setup({
        search_method = 'cover_or_next',
      })

      -- Bare `s` has no surround action. Without this, a timed-out `s` falls
      -- through to native substitute (cl) and deletes the char under cursor.
      -- <Nop> makes that fallback harmless.
      vim.keymap.set('n', 's', '<Nop>')
      vim.keymap.set('x', 's', '<Nop>')
    end,
  },
  { src = 'https://github.com/nvim-mini/mini.extra' },
  {
    src = 'https://github.com/nvim-mini/mini.comment',
    config = function()
      require('mini.comment').setup()
    end,
  },
  {
    src = 'https://github.com/windwp/nvim-autopairs',
    config = function()
      local npairs = require('nvim-autopairs')
      npairs.setup()

      local rule = require('nvim-autopairs.rule')
      npairs.add_rule(rule('"', '"', 'vim'):with_pair(function() return false end))
    end,
  },
  {
    src = 'https://github.com/gbprod/substitute.nvim',
    config = function()
      require('substitute').setup()

      vim.keymap.set('n', 'x', require('substitute').operator, { silent = true })
      vim.keymap.set('x', 'x', require('substitute').visual, { silent = true })
      vim.keymap.set('n', 'xx', require('substitute').line, { silent = true })
      vim.keymap.set('n', 'X', require('substitute').eol, { silent = true })
    end,
  },
  {
    src = 'https://github.com/chentoast/marks.nvim',
    config = function()
      require('marks').setup()
    end,
  },
  {
    src = 'https://github.com/andymass/vim-matchup',
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      vim.g.matchup_matchparen_deferred = 1
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
      local function esc_handler()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end
      mc.addKeymapLayer(function(layer_set)
        layer_set({ 'n', 'x' }, '<c-n>', function() mc.matchAddCursor(1) end)
        layer_set({ 'n', 'x' }, '<c-p>', function() mc.matchAddCursor(-1) end)
        layer_set({ 'n', 'x' }, '<c-x>', function() mc.matchSkipCursor(1) end)
        layer_set({ 'n', 'x' }, '<c-q>', function() mc.matchSkipCursor(-1) end)
        layer_set('n', '<esc>', esc_handler)
        layer_set('n', '<A-;>', esc_handler)
        -- VM insert/replace states run inside vim's insert mode; without this
        -- the layer would let <M-;> through and VM would type it as text.
        layer_set('i', '<A-;>', function()
          vim.cmd('stopinsert')
        end)
      end)
    end,
  },
}

M.config = function()
  local util = require('util')

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
  local function cd_root()
    local root = vim.fs.root(0, util.root_patterns)
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
    local root = vim.fs.root(vim.uv.cwd(), util.root_patterns) or vim.env.HOME
    return vim.fn.stdpath('state') .. '/shada/' .. util.path_to_name(root) .. '.shada'
  end

  vim.o.shadafile = shada_path()

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

  -- Fold
  -- Top-level scope is the only hard requirement: they must be applied before VimEnter,
  -- when the session restore opens windows while ufo has not loaded yet (VeryLazy), and
  -- 'foldlevel' is window-local — setting them in ufo's config would unfold
  -- only the focused window and leave the rest collapsed. 'foldlevelstart'
  -- applies as each restored window loads its buffer, so all of them start unfolded.
  vim.opt.foldcolumn = '0'
  vim.opt.foldlevel = 99
  vim.opt.foldlevelstart = 99
  vim.opt.foldenable = true

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
  local function win_nav(dir)
    -- Floating windows (fzf-lua, ...) and fzf buffers are modal UI: navigating
    -- out of them breaks their layout, and their own Alt bindings must keep
    -- working -- hand the full Alt+key back to the job instead. 'n' skips
    -- mappings so the forwarded key cannot re-enter this function.
    if vim.bo.buftype == 'terminal' and vim.api.nvim_buf_get_name(0):find('fzf')
        or vim.api.nvim_win_get_config(0).relative ~= '' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<M-' .. dir .. '>', true, false, true), 'n', false)
      return
    end
    vim.cmd('stopinsert')
    vim.cmd('wincmd ' .. dir)
    if vim.bo.buftype == 'terminal' and vim.api.nvim_buf_get_name(0):find('fzf') == nil then
      vim.schedule(function() vim.cmd('startinsert') end)
    end
  end

  vim.keymap.set('n', '<C-h>', '<C-w>h')
  vim.keymap.set('n', '<C-j>', '<C-w>j')
  vim.keymap.set('n', '<C-k>', '<C-w>k')
  vim.keymap.set('n', '<C-l>', '<C-w>l')
  vim.keymap.set({ 'n', 't', 'i' }, '<A-h>', function() win_nav('h') end, { silent = true })
  vim.keymap.set({ 'n', 't', 'i' }, '<A-j>', function() win_nav('j') end, { silent = true })
  vim.keymap.set({ 'n', 't', 'i' }, '<A-k>', function() win_nav('k') end, { silent = true })
  vim.keymap.set({ 'n', 't', 'i' }, '<A-l>', function() win_nav('l') end, { silent = true })
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
  vim.keymap.set('n', 'con', '<cmd>nohlsearch<CR>', { silent = true })
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

  -- BufNewFile also fires when a virtual buffer (gitsigns://, git://,
  -- fugitive://) is opened by name and has no file on disk; templating those
  -- would poison the diff view that gitsigns later reuses as-is.
  vim.api.nvim_create_autocmd('BufNewFile', {
    group = filetype_group,
    pattern = '*.sh',
    callback = function()
      if vim.bo.buftype ~= '' or vim.api.nvim_buf_get_name(0):find('://') then return end
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash', '' })
    end,
  })
  vim.api.nvim_create_autocmd('BufNewFile', {
    group = filetype_group,
    pattern = '*.py',
    callback = function()
      if vim.bo.buftype ~= '' or vim.api.nvim_buf_get_name(0):find('://') then return end
      vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3', '', '' })
    end,
  })

  -- markdown
  vim.g.markdown_syntax_conceal = 0
  vim.g.markdown_minlines = 100
  vim.g.markdown_fenced_languages = { 'c', 'cpp', 'zig', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua',
    'bash=sh', 'zsh', 'vim', 'sql', 'yaml', 'json', 'jsonc' }

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
        -- Delete the buffer too: gitsigns reuses any existing buffer with the
        -- same gitsigns:// name without refreshing it, so a survivor would
        -- show stale content in the next diff.
        local buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_win_close(win, true)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
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
  vim.keymap.set('n', '<leader>q', function() qf_toggle('copen', 'cclose') end,
    { silent = true, desc = 'Toggle quickfix' })
  vim.keymap.set('n', '<leader>l', function() qf_toggle('lopen', 'lclose') end,
    { silent = true, desc = 'Toggle location list' })
end

return M
