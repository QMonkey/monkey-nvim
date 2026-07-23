vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = 'utf-8,gb18030,cp936,ucs-bom,big5,euc-jp,euc-kr,latin1'
vim.opt.fileformats = 'unix,dos,mac'

-- Numbers
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = true

-- Cursor
vim.opt.cursorline = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true
vim.opt.showmatch = true
vim.opt.shortmess:remove('S')
vim.opt.shortmess:append('s')

-- Completion
vim.opt.wildmenu = true
vim.opt.wildmode = 'list:longest,full'
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.magic = true

-- Swap
vim.opt.directory = vim.fn.expand('$HOME/.vim/swap//')
vim.opt.jumpoptions:append('stack')

-- Clipboard (only if DISPLAY is set)
if vim.fn.has('unnamedplus') == 1 and vim.fn.empty(vim.fn.getenv('DISPLAY')) == 0 then
  vim.opt.clipboard = 'unnamed,unnamedplus'
elseif vim.fn.empty(vim.fn.getenv('DISPLAY')) == 0 then
  vim.opt.clipboard = 'unnamed'
end

-- Indent
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.textwidth = 0
vim.opt.wrap = true
vim.opt.breakindent = true

-- Splits
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

-- Session options (for auto-session)
vim.opt.sessionoptions:remove({ 'blank', 'options', 'folds', 'terminal' })

-- True color
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
else
  vim.opt.t_Co = 256
  if vim.env.TERM and vim.env.TERM:find('256color') then
    vim.opt.t_ut = ''
  end
end
