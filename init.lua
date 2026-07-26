vim.cmd('syntax on')

-- Plugins
vim.pack.add({
  { src = 'https://github.com/sainnhe/sonokai' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { src = 'https://github.com/echasnovski/mini.icons' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/hrsh7th/nvim-cmp' },
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
  { src = 'https://github.com/hrsh7th/cmp-buffer' },
  { src = 'https://github.com/hrsh7th/cmp-path' },
  { src = 'https://github.com/L3MON4D3/LuaSnip' },
  { src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/folke/flash.nvim' },
  { src = 'https://github.com/gbprod/substitute.nvim' },
  { src = 'https://github.com/echasnovski/mini.ai' },
  { src = 'https://github.com/echasnovski/mini.indentscope' },
  { src = 'https://github.com/echasnovski/mini.surround' },
  { src = 'https://github.com/numToStr/Comment.nvim' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/kevinhwang91/promise-async' },
  { src = 'https://github.com/kevinhwang91/nvim-ufo' },
  { src = 'https://github.com/ludovicchabant/vim-gutentags' },
  { src = 'https://github.com/chentoast/marks.nvim' },
  { src = 'https://github.com/folke/trouble.nvim' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/jake-stewart/multicursor.nvim' },
  { src = 'https://github.com/NeogitOrg/neogit' },
  { src = 'https://github.com/esmuellert/codediff.nvim' },
  { src = 'https://github.com/akinsho/toggleterm.nvim' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/rmagatti/auto-session' },
})

-- Leader
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = 'utf-8,gb18030,cp936,ucs-bom,big5,euc-jp,euc-kr,latin1'
vim.opt.fileformats = 'unix,dos,mac'

-- Number
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = true

local relativeNumberGroup = vim.api.nvim_create_augroup('RelativeNumber', { clear = true })
vim.api.nvim_create_autocmd({ 'WinEnter', 'InsertLeave' }, {
  group = relativeNumberGroup,
  command = 'set relativenumber',
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'InsertEnter' }, {
  group = relativeNumberGroup,
  command = 'set norelativenumber number',
})

-- Cursorline
vim.opt.cursorline = true

local cursorLineGroup = vim.api.nvim_create_augroup('CursorLine', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = cursorLineGroup,
  command = 'set nocursorline',
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = cursorLineGroup,
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

local hlsearchGroup = vim.api.nvim_create_augroup('Hlsearch', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = hlsearchGroup,
  callback = function()
    if vim.v.hlsearch == 1 then
      vim.schedule(function()
        vim.cmd('nohlsearch')
      end)
    end
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
if vim.fn.has('unnamedplus') == 1 and vim.fn.empty(vim.fn.getenv('DISPLAY')) == 0 then
  vim.opt.clipboard = 'unnamed,unnamedplus'
elseif vim.fn.empty(vim.fn.getenv('DISPLAY')) == 0 then
  vim.opt.clipboard = 'unnamed'
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
vim.opt.updatetime = 500

-- Display
vim.opt.list = true
vim.opt.listchars = 'tab:▸ ,leadmultispace:│   ,eol:¬,trail:·'

-- Scroll
vim.opt.scrolloff = 7
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 1

-- Fold
vim.opt.foldenable = false
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevel = 99

-- Misc
vim.opt.backspace = 'indent,eol,start'
vim.opt.hidden = true
vim.opt.autoread = true
vim.opt.belloff = 'all'
vim.opt.mouse = 'nvi'
vim.opt.showtabline = 1
vim.opt.laststatus = 2

vim.opt.sessionoptions:remove({ 'blank', 'options', 'folds', 'terminal' })

-- Color support
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
else
  vim.opt.t_Co = 256
  if vim.env.TERM and vim.env.TERM:find('256color') then
    vim.opt.t_ut = ''
  end
end

-- FileType
local fileTypeGroup = vim.api.nvim_create_augroup('FileType', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = fileTypeGroup,
  pattern = { 'rust', 'python', 'markdown' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = fileTypeGroup,
  pattern = { 'javascript', 'typescript', 'lua', 'yaml', 'json' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = fileTypeGroup,
  pattern = 'qf',
  command = 'wincmd J',
})

vim.api.nvim_create_autocmd('BufNewFile', {
  group = fileTypeGroup,
  pattern = '*.sh',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash', '' })
  end,
})
vim.api.nvim_create_autocmd('BufNewFile', {
  group = fileTypeGroup,
  pattern = '*.py',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3', '', '' })
  end,
})

-- Docset
vim.api.nvim_create_user_command('LspHover', vim.lsp.buf.hover, { nargs = '*', range = true })
vim.opt.keywordprg = ':LspHover'

local docsetGroup = vim.api.nvim_create_augroup('DocSet', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = docsetGroup,
  pattern = { 'man', 'help' },
  callback = function()
    vim.wo.list = false
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = docsetGroup,
  pattern = { 'c', 'man' },
  callback = function()
    vim.bo.keywordprg = ':Man'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = docsetGroup,
  pattern = { 'vim', 'help' },
  callback = function()
    vim.bo.keywordprg = ':help'
  end,
})

-- AutoResize
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('AutoResize', { clear = true }),
  command = 'tabdo wincmd =',
})

-- LanguageFold
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('LanguageFold', { clear = true }),
  pattern = { 'python', 'yaml' },
  callback = function()
    vim.wo.foldmethod = 'indent'
  end,
})

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

-- CheckFileChanges
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufWinEnter', 'WinEnter', 'CursorHold' }, {
  group = vim.api.nvim_create_augroup('CheckFileChanges', { clear = true }),
  callback = function()
    if vim.fn.getcmdtype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- Ctags
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  group = vim.api.nvim_create_augroup('Ctags', { clear = true }),
  pattern = '*.tags',
  command = 'setfiletype tags',
})

-- sonokai
vim.g.sonokai_style = 'andromeda'
vim.g.sonokai_better_performance = 1
vim.g.sonokai_diagnostic_text_highlight = 1
vim.g.sonokai_diagnostic_virtual_text = 'colored'
vim.g.sonokai_dim_inactive_windows = 1
vim.opt.background = 'dark'
vim.cmd('colorscheme sonokai')

-- lualine.nvim
local mc = require('multicursor-nvim')
local function mc_active()
  return mc.hasCursors()
end

require('lualine').setup({
  options = {
    theme = 'sonokai',
    component_separators = '',
    section_separators = '',
    always_show_tabline = false,
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
          local result = mc.numCursors() .. ' cursors'
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
    lualine_a = { { 'tabs', mode = 1 } },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
})

-- Key map
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

vim.keymap.set('n', 'q', function()
  local last_winnr = vim.fn.winnr('#')
  local ftype = vim.bo.filetype
  local is_diff = vim.wo.diff
  local is_qf = ftype == 'qf'
  local is_preview = vim.wo.previewwindow

  if is_diff and tonumber(last_winnr) > 0 then
    vim.cmd(last_winnr .. 'wincmd w')
    vim.cmd('quit')
    return
  end

  vim.cmd('quit')

  if is_qf or is_preview then
    if tonumber(last_winnr) > 0 and vim.fn.win_id2win(vim.fn.win_getid(tonumber(last_winnr))) ~= 0 then
      vim.cmd(last_winnr .. 'wincmd w')
    end
  end
end, { silent = true })

vim.keymap.set('n', '<S-q>', '<cmd>quitall<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, 't', 'q')

-- Terminal
vim.keymap.set('n', '<F3>', ':botright terminal ', { desc = 'Open terminal with command' })
require('toggleterm').setup({
  size = 15,
  open_mapping = '<F4>',
  direction = 'horizontal',
})

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
vim.keymap.set('n', '<leader>t', function()
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
vim.keymap.set('n', '<leader>s', function()
  local name = vim.fn.input('New split name: ', '', 'file')
  if name ~= '' then
    vim.cmd('split ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
vim.keymap.set('n', '<leader>v', function()
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

-- Zoom
vim.keymap.set('n', '<leader>z', function()
  if vim.g.zoomed then
    vim.cmd(vim.g.zoom_winrestcmd)
    vim.g.zoomed = false
  else
    vim.g.zoom_winrestcmd = vim.fn.winrestcmd()
    vim.cmd('resize')
    vim.cmd('vertical resize')
    vim.g.zoomed = true
  end
end, { silent = true })

-- rooter
local patterns = { '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout' }

local function find_root()
  local path = vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
  local last = nil
  while path ~= last do
    for _, p in ipairs(patterns) do
      if vim.uv.fs_stat(vim.fs.joinpath(path, p)) then
        return path
      end
    end
    last = path
    path = vim.fn.fnamemodify(path, ':h')
  end
  return nil
end

vim.keymap.set('n', '<leader>cr', function()
  local root = find_root()
  if root then
    vim.cmd('cd ' .. vim.fn.fnameescape(root))
  end
end, { silent = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('ChangeRoot', { clear = true }),
  once = true,
  callback = function()
    local root = find_root()
    if root then
      vim.cmd('cd ' .. vim.fn.fnameescape(root))
    end
  end,
})

-- oil.nvim
require('oil').setup({
  view_options = { show_hidden = true },
})

vim.keymap.set('n', '-', function()
  require('oil').open(vim.fn.expand('%:p:h'))
end, { silent = true })

vim.keymap.set('n', '~', function()
  local root = find_root() or vim.fn.expand('~')
  require('oil').open(root)
end, { silent = true })

-- sudo write
vim.api.nvim_create_user_command('SudoWrite', function()
  vim.cmd('write !sudo tee % >/dev/null && edit!')
end, {})

-- gutentags
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

-- trouble.nvim
require('trouble').setup({
  auto_close = true,
  auto_refresh = true,
  height = 10,
})

vim.keymap.set('n', '<leader>d', '<cmd>Trouble diagnostics toggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>q', '<cmd>Trouble quickfix toggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>l', '<cmd>Trouble loclist toggle<CR>', { silent = true })

-- auto-session
require('auto-session').setup({
  log_level = 'error',
  auto_save_enabled = true,
  auto_restore_enabled = true,
})

vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<CR>', { silent = true })
vim.keymap.set('n', '<leader>rs', '<cmd>AutoSession delete<CR>', { silent = true })

-- telescope.nvim
local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup({
  defaults = {
    file_ignore_patterns = { '.git/', '.hg/', '.svn/', '.bzr/' },
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
      },
    },
  },
  pickers = {
    buffers = {
      mappings = {
        i = { ['<C-d>'] = actions.delete_buffer },
        n = { ['<C-d>'] = actions.delete_buffer },
      },
    },
    live_grep = { additional_args = { '--hidden' } },
    find_files = { hidden = true },
  },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, { silent = true })
vim.keymap.set('n', '<leader>b', builtin.buffers, { silent = true })
vim.keymap.set('n', '<leader>y', builtin.current_buffer_tags, { silent = true })
vim.keymap.set('n', '<leader>f', function()
  builtin.lsp_document_symbols({ symbols = { 'function', 'method' } })
end, { silent = true })
vim.keymap.set('n', '<leader>e', builtin.current_buffer_fuzzy_find, { silent = true })
vim.keymap.set('n', '<leader>a', function()
  builtin.grep_string({ default_text = vim.fn.expand('<cword>') })
end, { silent = true })
vim.keymap.set('v', '<leader>a', function()
  local saved_reg = vim.fn.getreg('"')
  local saved_regtype = vim.fn.getregtype('"')
  vim.cmd('normal! "vy"')
  local text = vim.fn.getreg('"')
  vim.fn.setreg('"', saved_reg, saved_regtype)
  builtin.grep_string({ default_text = text })
end, { silent = true })
vim.keymap.set('n', '<F1>', builtin.live_grep, { silent = true })
vim.keymap.set({ 'n', 'i' }, '<F2>', function()
  local state = require('telescope.state')
  local prompt_bufs = state.get_existing_prompt_bufnrs()
  if #prompt_bufs > 0 then
    actions.close(prompt_bufs[#prompt_bufs])
  else
    builtin.resume()
  end
end, { silent = true })

-- flash.nvim
require('flash').setup({
  labels = 'asdfghjklqwertyuiopzxcvbnm',
  search = { mode = 'exact' },
  modes = { char = { enabled = false } },
})

vim.keymap.set({ 'n', 'x', 'o' }, 'f', function()
  require('flash').jump()
end)
vim.keymap.set('n', 'F', function()
  require('flash').jump({ jump = { pos = 'end' } })
end)
vim.keymap.set({ 'x', 'o' }, 'F', function()
  require('flash').treesitter()
end)

-- substitute.nvim
require('substitute').setup()

vim.keymap.set('n', 's', require('substitute').operator, { silent = true })
vim.keymap.set('x', 's', require('substitute').visual, { silent = true })
vim.keymap.set('n', 'ss', require('substitute').line, { silent = true })
vim.keymap.set('n', 'S', require('substitute').eol, { silent = true })

-- multicursor.nvim
mc = require('multicursor-nvim')
mc.setup({ hlsearch = true })

vim.keymap.set({ 'n', 'x' }, '<c-n>', function() mc.matchAddCursor(1) end)
mc.addKeymapLayer(function(layerSet)
  layerSet({ 'n', 'x' }, '<c-n>', function() mc.matchAddCursor(1) end)
  layerSet({ 'n', 'x' }, '<c-p>', function() mc.matchAddCursor(-1) end)
  layerSet({ 'n', 'x' }, '<c-x>', function() mc.matchSkipCursor(1) end)
  layerSet({ 'n', 'x' }, '<c-q>', function() mc.matchSkipCursor(-1) end)
  layerSet('n', '<esc>', function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

-- nvim-ufo
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup({
  provider_selector = function(_, _, _)
    return { 'treesitter', 'indent' }
  end,
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = '  ' .. (endLnum - lnum) .. ' lines'
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
  end,
})

-- nvim-autopairs
local npairs = require('nvim-autopairs')
npairs.setup()

local rule = require('nvim-autopairs.rule')
npairs.add_rule(rule('"', '"', 'vim'):with_pair(function() return false end))

-- marks.nvim
require('marks').setup()

-- lsp
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('Lsp', { clear = true }),
  callback = function(args)
    local buf = args.buf
    local bufopts = { buffer = buf, silent = true }

    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gc', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, bufopts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, bufopts)
    vim.keymap.set('n', '[D', function() vim.diagnostic.jump({ count = -999 }) end, bufopts)
    vim.keymap.set('n', ']D', function() vim.diagnostic.jump({ count = 999 }) end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
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
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
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
    vim.lsp.buf.format({ async = true, timeout_ms = 5000 })
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
      if luasnip.expand_or_jumpable() then
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

-- markdown
vim.g.markdown_syntax_conceal = 0
vim.g.markdown_minlines = 100
vim.g.markdown_fenced_languages = { 'c', 'cpp', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua', 'bash=sh',
  'vim', 'sql', 'yaml', 'json' }

-- nvim-treesitter
require('nvim-treesitter').setup()
require('nvim-treesitter.install').install({
  'c', 'cpp', 'rust', 'go', 'javascript', 'typescript', 'python', 'lua', 'bash', 'vim', 'vimdoc', 'markdown',
  'markdown_inline', 'yaml', 'json', 'sql',
})

-- mini.icons
require('mini.icons').setup()

-- mini.indentscope
require('mini.indentscope').setup({ draw = { delay = 0 } })

-- mini.ai
require('mini.ai').setup()

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

-- highlight
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = 'Search', timeout = 200 }
  end,
})

-- git
require('neogit').setup({
  diff_viewer = 'codediff',
  integrations = { codediff = true },
})

require('codediff').setup({
  diff = { compact = true },
})

local gitsigns = require('gitsigns')
gitsigns.setup()

vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<CR>', { silent = true })
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
