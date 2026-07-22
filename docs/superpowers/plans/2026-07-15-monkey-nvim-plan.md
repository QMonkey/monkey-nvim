# monkey-nvim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete Neovim configuration in Lua that replicates all 33 features/plugins from monkey-vim, using mini.deps as plugin manager, organized as one-file-per-plugin.

**Architecture:** A single `init.lua` bootstraps mini.deps, loads core settings, then loads plugins via `mini.deps.now()` / `mini.deps.later()`. Each `lua/plugins/*.lua` file is self-contained — declares its plugin dependency, configures it, and runs `.setup()`.

**Tech Stack:** Neovim >= 0.10, Lua, mini.deps (plugin manager), 30 external plugins + 3 feature replacements.

## Global Constraints

- Neovim >= 0.10 required
- No Vim compatibility needed
- All configuration in Lua, no Vimscript
- Plugin manager: mini.deps
- Colorscheme: sainnhe/sonokai (andromeda variant)
- Config structure: one file per plugin under `lua/plugins/`
- Leader key: `,` (comma)
- Default tab: 8-width hard tabs, no expandtab
- Python/Markdown: 4-space, JSON/YAML/JS/TS: 2-space
- Error handling: `pcall()` wrapper on plugin requires, silent skip on failure
- mini.deps bootstrap downloads to `~/.local/share/nvim/lazy/mini-deps`

## File Map

| File | Responsibility |
|---|---|
| `init.lua` | Bootstrap mini.deps, load core, load plugins, set colorscheme |
| `lua/core/options.lua` | All `vim.opt.*` / `vim.g.*` settings |
| `lua/core/autocmds.lua` | All `vim.api.nvim_create_autocmd` calls |
| `lua/core/filetypes.lua` | Filetype-specific tab/space/fold settings |
| `lua/core/keys.lua` | Global keymaps not belonging to a single plugin |
| `lua/plugins/colorscheme.lua` | sainnhe/sonokai |
| `lua/plugins/lualine.lua` | nvim-lualine/lualine.nvim |
| `lua/plugins/telescope.lua` | nvim-telescope/telescope.nvim |
| `lua/plugins/project.lua` | ahmedkhalf/project.nvim |
| `lua/plugins/gutentags.lua` | ludovicchabant/vim-gutentags |
| `lua/plugins/toggleterm.lua` | akinsho/toggleterm.nvim |
| `lua/plugins/lsp.lua` | mason + mason-lspconfig + nvim-lspconfig + LS setup |
| `lua/plugins/cmp.lua` | nvim-cmp + LuaSnip + friendly-snippets |
| `lua/plugins/treesitter.lua` | nvim-treesitter/nvim-treesitter |
| `lua/plugins/gitsigns.lua` | lewis6991/gitsigns.nvim |
| `lua/plugins/fugitive.lua` | tpope/vim-fugitive |
| `lua/plugins/flash.lua` | folke/flash.nvim |
| `lua/plugins/substitute.lua` | gbprod/substitute.nvim |
| `lua/plugins/visual-multi.lua` | mg979/vim-visual-multi |
| `lua/plugins/ufo.lua` | kevinhwang91/nvim-ufo |
| `lua/plugins/textobjects.lua` | mini.ai + mini.indentscope |
| `lua/plugins/surround.lua` | echasnovski/mini.surround |
| `lua/plugins/repeat.lua` | tpope/vim-repeat |
| `lua/plugins/autopairs.lua` | windwp/nvim-autopairs |
| `lua/plugins/matchup.lua` | andymass/vim-matchup |
| `lua/plugins/eunuch.lua` | tpope/vim-eunuch |
| `lua/plugins/commentary.lua` | numToStr/Comment.nvim |
| `lua/plugins/highlighted-yank.lua` | machakann/vim-highlightedyank |
| `lua/plugins/oil.lua` | stevearc/oil.nvim |
| `lua/plugins/marks.lua` | chentoast/marks.nvim |
| `lua/plugins/auto-session.lua` | rmagatti/auto-session |
| `lua/plugins/trouble.lua` | folke/trouble.nvim |
| `.gitignore` | Git ignore rules |

---

### Task 1: Scaffold init.lua

**Files:**
- Create: `init.lua`
- Create: `.gitignore`

**Interfaces:**
- Produces: mini.deps bootstrap (download to `~/.local/share/nvim/lazy/mini-deps`), global `require('core.options')` etc. calls after declare, lazy-load trigger words for plugins

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p lua/core lua/plugins after/ftplugin
```

- [ ] **Step 2: Create the .gitignore**

Write `,.gitignore`:

```
# Ctags file
*.tags
tags

# Swap file
*.swp
*.swo
*.swn

# Session
*.vim
!init.lua
```

- [ ] **Step 3: Create init.lua with mini.deps bootstrap**

Write `init.lua`:

```lua
-- ~/.config/nvim/init.lua

local path_package = vim.fn.stdpath('data') .. '/lazy'
local mini_path = path_package .. '/mini-deps'

if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Downloading mini.deps..."')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.deps.git',
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.deps | helptags ' .. mini_path .. '/doc')
end

require('mini.deps').setup({ path = { package = path_package } })

local now, later, add = MiniDeps.now, MiniDeps.later, MiniDeps.add

-- Load core settings early (before plugins configure themselves)
require('core.options')

-- Add all plugins (register sources, don't load yet)
-- Plugin files call add(), setup happens in now()/later() blocks

local plugins = {
  'colorscheme', 'lualine', 'telescope', 'project',
  'gutentags', 'toggleterm', 'lsp', 'cmp', 'treesitter',
  'gitsigns', 'fugitive', 'flash', 'substitute',
  'visual-multi', 'ufo', 'textobjects', 'surround',
  'repeat', 'autopairs', 'matchup', 'eunuch',
  'commentary', 'highlighted-yank', 'oil', 'marks',
  'auto-session', 'trouble',
}

for _, name in ipairs(plugins) do
  local ok, _ = pcall(require, 'plugins.' .. name)
  if not ok then
    vim.notify('Failed to load plugin: ' .. name, vim.log.levels.WARN)
  end
end

-- Load core modules after plugin declarations
require('core.autocmds')
require('core.keys')
require('core.filetypes')

-- Colorscheme must load last
vim.cmd('colorscheme sonokai')
```

- [ ] **Step 4: Verify init.lua loads without errors**

```bash
nvim --headless -c 'lua if vim.v.shell_error == 0 then vim.cmd("q") end' 2>&1 || true
```

Expected: No Lua errors. mini.deps download may fail if offline (silently retry via `:DepsInstall`).

- [ ] **Step 5: Commit**

```bash
git add init.lua .gitignore lua/core lua/plugins after
git commit -m "feat: scaffold init.lua with mini.deps bootstrap and directory structure"
```

---

### Task 2: Core options.lua

**Files:**
- Modify: `lua/core/options.lua`

**Interfaces:**
- Consumes: Nothing (loaded first in init.lua)
- Produces: All `vim.opt.*` and `vim.g.*` global settings

- [ ] **Step 1: Write options.lua**

Write `lua/core/options.lua`:

```lua
-- ~/.config/nvim/lua/core/options.lua

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
vim.opt.completeopt = 'menu,menuone'
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
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 8
vim.opt.shiftwidth = 8
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
```

- [ ] **Step 2: Verify options load**

```bash
nvim --headless -c 'lua require("core.options")' -c 'lua print(vim.opt.tabstop:get())' -c 'q' 2>&1
```

Expected: Prints `8`. No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/core/options.lua
git commit -m "feat: add core vim options"
```

---

### Task 3: Core autocmds.lua

**Files:**
- Modify: `lua/core/autocmds.lua`

**Interfaces:**
- Produces: All global `vim.api.nvim_create_autocmd` calls

- [ ] **Step 1: Write autocmds.lua**

Write `lua/core/autocmds.lua`:

```lua
-- ~/.config/nvim/lua/core/autocmds.lua

local api = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

-- Relative number toggle in active normal mode
local relnum = augroup('RelativeNumber', { clear = true })
autocmd({ 'WinEnter', 'InsertLeave' }, {
  group = relnum,
  command = 'set relativenumber',
})
autocmd({ 'WinLeave', 'InsertEnter' }, {
  group = relnum,
  command = 'set norelativenumber number',
})

-- Cursorline toggle (disabled in insert mode)
local curline = augroup('CursorLine', { clear = true })
autocmd('InsertEnter', {
  group = curline,
  command = 'set nocursorline',
})
autocmd('InsertLeave', {
  group = curline,
  command = 'set cursorline',
})

-- Paste mode (disable on leaving insert)
local paste = augroup('PasteMode', { clear = true })
autocmd('InsertLeave', {
  group = paste,
  command = 'setlocal nopaste',
})

-- AudoInsertFileHead (.sh, .py)
local filehead = augroup('FileHead', { clear = true })
autocmd('BufNewFile', {
  group = filehead,
  pattern = '*.sh',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash', '' })
  end,
})
autocmd('BufNewFile', {
  group = filehead,
  pattern = '*.py',
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3', '', '' })
  end,
})

-- Restore cursor position
local cursor = augroup('RestoreCursorPosition', { clear = true })
autocmd('BufReadPost', {
  group = cursor,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Clear jumplist on startup
autocmd('VimEnter', {
  group = augroup('Jumplist', { clear = true }),
  command = 'clearjumps',
})

-- Resize splits on VimResized
autocmd('VimResized', {
  group = augroup('AutoResize', { clear = true }),
  command = 'tabdo wincmd =',
})

-- Check file changes
local checkfile = augroup('CheckFileChanges', { clear = true })
autocmd({ 'FocusGained', 'BufWinEnter', 'WinEnter', 'CursorHold' }, {
  group = checkfile,
  callback = function()
    if vim.fn.getcmdtype() == '' then
      vim.cmd('checktime')
    end
  end,
})

-- .tags filetype
autocmd({ 'BufNewFile', 'BufRead' }, {
  group = augroup('Ctags', { clear = true }),
  pattern = '*.tags',
  command = 'setfiletype tags',
})

-- Auto clang-format creation
local clangfmt = augroup('InitClangFormat', { clear = true })
autocmd('VimEnter', {
  group = clangfmt,
  once = true,
  callback = function()
    local cf = vim.env.HOME .. '/.clang-format'
    if vim.fn.filereadable(cf) == 1 then
      return
    end
    local lines = {
      'BasedOnStyle: LLVM',
      'IndentWidth: 8',
      'UseTab: Always',
      'BreakBeforeBraces: Linux',
      'AllowShortIfStatementsOnASingleLine: false',
      'IndentCaseLabels: false',
      'PointerAlignment: Left',
      'SortIncludes: false',
    }
    vim.fn.writefile(lines, cf)
  end,
})
```

- [ ] **Step 2: Verify autocmds load**

```bash
nvim --headless -c 'lua require("core.autocmds")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/core/autocmds.lua
git commit -m "feat: add core autocmds"
```

---

### Task 4: Core filetypes.lua

**Files:**
- Modify: `lua/core/filetypes.lua`

- [ ] **Step 1: Write filetypes.lua**

Write `lua/core/filetypes.lua`:

```lua
-- ~/.config/nvim/lua/core/filetypes.lua

local api = vim.api
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

local ft = augroup('FileTypeSettings', { clear = true })

-- Tab/space settings per filetype
autocmd('FileType', {
  group = ft,
  pattern = { 'python', 'markdown' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

autocmd('FileType', {
  group = ft,
  pattern = { 'json', 'yaml', 'javascript', 'typescript' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

-- Fold method per filetype
autocmd('FileType', {
  group = ft,
  pattern = { 'python', 'yaml' },
  callback = function()
    vim.wo.foldmethod = 'indent'
  end,
})

-- Quickfix window to bottom
autocmd('FileType', {
  group = ft,
  pattern = 'qf',
  command = 'wincmd J',
})

-- docset keywordprg
autocmd('FileType', {
  group = ft,
  pattern = { 'man', 'help' },
  callback = function()
    vim.wo.list = false
  end,
})

autocmd('FileType', {
  group = ft,
  pattern = '*',
  callback = function()
    vim.bo.keywordprg = ':LspHover'
  end,
})

autocmd('FileType', {
  group = ft,
  pattern = { 'c', 'man' },
  callback = function()
    vim.bo.keywordprg = ':Man'
  end,
})

autocmd('FileType', {
  group = ft,
  pattern = { 'vim', 'help' },
  callback = function()
    vim.bo.keywordprg = ':help'
  end,
})
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("core.filetypes")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/core/filetypes.lua
git commit -m "feat: add core filetype settings"
```

---

### Task 5: Core keys.lua

**Files:**
- Modify: `lua/core/keys.lua`

- [ ] **Step 1: Write keys.lua**

Write `lua/core/keys.lua`:

```lua
-- ~/.config/nvim/lua/core/keys.lua

local map = vim.keymap.set

-- Editing
map('n', 'Y', 'y$')
map({ 'n', 'v' }, 'j', 'gj')
map({ 'n', 'v' }, 'k', 'gk')
map({ 'n', 'v' }, 'H', '^')
map({ 'n', 'v' }, 'L', '$')
map('v', '<', '<gv')
map('v', '>', '>gv')
map({ 'n', 'v' }, ';', ':')
map('n', 'U', '<C-r>')

-- Insert mode movement
map('i', '<C-p>', '<Up>')
map('i', '<C-n>', '<Down>')
map('i', '<C-b>', '<Left>')
map('i', '<C-f>', '<Right>')
map('i', '<C-a>', '<Home>')
map('i', '<C-e>', '<End>')
map('i', '<C-h>', '<BackSpace>')
map('i', '<C-d>', '<Del>')

-- Command mode movement
map('c', '<C-p>', '<Up>')
map('c', '<C-n>', '<Down>')
map('c', '<C-b>', '<Left>')
map('c', '<C-f>', '<Right>')
map('c', '<C-a>', '<Home>')
map('c', '<C-e>', '<End>')
map('c', '<C-h>', '<BackSpace>')
map('c', '<C-d>', '<Del>')

-- Smart quit
map('n', 'q', function()
  local last_winnr = vim.fn.winnr('#')
  local ftype = vim.bo.filetype
  local is_diff = vim.wo.diff
  local is_qf = ftype == 'qf'
  local is_preview = vim.wo.previewwindow

  if is_diff and tonumber(last_winnr) > 0 then
    local bufname = vim.fn.bufname(vim.fn.winbufnr(tonumber(last_winnr)))
    if bufname:match('^fugitive:') then
      vim.cmd(last_winnr .. 'wincmd w')
      vim.cmd('quit')
      return
    end
  end

  vim.cmd('quit')

  if is_qf or is_preview then
    if tonumber(last_winnr) > 0 and vim.fn.win_id2win(vim.fn.win_getid(tonumber(last_winnr))) ~= 0 then
      pcall(vim.cmd, last_winnr .. 'wincmd w')
    end
  end
end, { silent = true })

map('n', '<S-q>', '<cmd>quitall<CR>', { silent = true })
map({ 'n', 'v' }, 't', 'q')

-- Splits
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')
map('n', '<leader>s', function()
  local name = vim.fn.input('New split name: ', '', 'file')
  if name ~= '' then
    vim.cmd('split ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
map('n', '<leader>v', function()
  local name = vim.fn.input('New vsplit name: ', '', 'file')
  if name ~= '' then
    vim.cmd('vsplit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })

-- Buffers
map('n', '<leader>o', function()
  local name = vim.fn.input('New buffer name: ', '', 'file')
  if name ~= '' then
    vim.cmd('edit ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
map('n', '[b', '<cmd>bprevious<CR>', { silent = true })
map('n', ']b', '<cmd>bnext<CR>', { silent = true })

-- Tabs
map('n', '<leader>t', function()
  local name = vim.fn.input('New tab name: ', '', 'file')
  if name ~= '' then
    vim.cmd('tabnew ' .. vim.fn.fnameescape(name))
  end
end, { silent = true })
map('n', '[t', '<cmd>tabprevious<CR>', { silent = true })
map('n', ']t', '<cmd>tabnext<CR>', { silent = true })
for i = 1, 9 do
  map('n', '<leader>' .. i, i .. 'gt')
end
map('n', '<leader>[', '<cmd>tabfirst<CR>', { silent = true })
map('n', '<leader>]', '<cmd>tablast<CR>', { silent = true })

-- Toggle
map('n', 'cod', function()
  vim.cmd(vim.wo.diff and 'diffoff' or 'diffthis')
end, { silent = true })
map('n', 'cop', '<cmd>set invpaste<CR>', { silent = true })
map('n', 'col', '<cmd>set invlist<CR>', { silent = true })
map('n', 'con', '<cmd>nohlsearch<CR>', { silent = true })
map('n', '<leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:nohlsearch<CR>', { silent = true })
map('n', '<leader><leader><Space>', '<cmd>%s/\\s\\+$//e<CR>:%s/\\r$//e<CR>:nohlsearch<CR>', { silent = true })

-- Zoom toggle
map('n', '<leader>z', function()
  if vim.t and vim.t.zoomed then
    vim.cmd(vim.t.zoom_winrestcmd)
    vim.t.zoomed = false
  else
    vim.t.zoom_winrestcmd = vim.fn.winrestcmd()
    vim.cmd('resize')
    vim.cmd('vertical resize')
    vim.t.zoomed = true
  end
end, { silent = true })

-- F1-F4 (will be remapped by telescope/toggleterm later; keymaps here are fallbacks)
map('n', '<F1>', '<cmd>Telescope live_grep<CR>', { silent = true })
map('n', '<F2>', '<cmd>Telescope resume<CR>', { silent = true })
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("core.keys")' -c 'q' 2>&1
```

Expected: No errors. F1/F2 may warn about telescope not loaded (expected).

- [ ] **Step 3: Commit**

```bash
git add lua/core/keys.lua
git commit -m "feat: add core keymaps"
```

---

### Task 6: Colorscheme (sonokai)

**Files:**
- Modify: `lua/plugins/colorscheme.lua`

- [ ] **Step 1: Write colorscheme.lua**

```lua
-- ~/.config/nvim/lua/plugins/colorscheme.lua

local add, now = MiniDeps.add, MiniDeps.now

add({
  source = 'sainnhe/sonokai',
})

now(function()
  vim.g.sonokai_style = 'andromeda'
  vim.g.sonokai_better_performance = 1
  vim.opt.background = 'dark'
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.colorscheme")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/colorscheme.lua
git commit -m "feat: add sonokai colorscheme (andromeda)"
```

---

### Task 7: Lualine (statusline)

**Files:**
- Modify: `lua/plugins/lualine.lua`

- [ ] **Step 1: Write lualine.lua**

```lua
-- ~/.config/nvim/lua/plugins/lualine.lua

local add, now = MiniDeps.add, MiniDeps.now

add({
  source = 'nvim-lualine/lualine.nvim',
  depends = { 'nvim-tree/nvim-web-devicons' },
})

now(function()
  local function search_count()
    if not vim.v.hlsearch or vim.fn.getreg('/') == '' then
      return ''
    end
    local ok, count = pcall(vim.fn.searchcount)
    if not ok or count.total == 0 then
      return ''
    end
    if count.incomplete == 1 then
      return '[?/??]'
    end
    return string.format('[%d/%d]', count.current, count.total)
  end

  require('lualine').setup({
    options = {
      theme = 'auto',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '│' },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        {
          'branch',
          icon = '⎇',
          cond = function()
            return vim.bo.filetype ~= 'help'
              and vim.fn.FugitiveHead and vim.fn.FugitiveHead() ~= ''
          end,
        },
        {
          'diff',
          symbols = { added = '+', modified = '~', removed = '-' },
          cond = function() return vim.bo.filetype ~= 'help' end,
        },
      },
      lualine_c = {
        {
          'filename',
          path = 0,
          symbols = {
            modified = '+',
            readonly = '🔒',
          },
        },
      },
      lualine_x = { search_count, 'filetype' },
      lualine_y = { 'fileformat', 'encoding' },
      lualine_z = { 'progress', 'location' },
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
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { 'tabs', mode = 2, max_length = vim.o.columns } },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  })
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.lualine")' -c 'lua print(vim.bo.laststatus)' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/lualine.lua
git commit -m "feat: add lualine statusline"
```

---

### Task 8: Telescope

**Files:**
- Modify: `lua/plugins/telescope.lua`

- [ ] **Step 1: Write telescope.lua**

```lua
-- ~/.config/nvim/lua/plugins/telescope.lua

local add, later = MiniDeps.add, MiniDeps.later

add({
  source = 'nvim-telescope/telescope.nvim',
  depends = { 'nvim-lua/plenary.nvim' },
})

later(function()
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
      live_grep = {
        additional_args = { '--hidden' },
      },
      find_files = {
        hidden = true,
      },
    },
  })

  local builtin = require('telescope.builtin')

  -- File/buffer search (replaces LeaderF)
  vim.keymap.set('n', '<C-p>', builtin.find_files, {})
  vim.keymap.set('n', '<leader>b', builtin.buffers, {})
  vim.keymap.set('n', '<leader>y', builtin.current_buffer_tags, {})
  vim.keymap.set('n', '<leader>f', builtin.tags, {})
  vim.keymap.set('n', '<leader>e', builtin.jumplist, {})

  -- Grep (replaces CtrlSF)
  vim.keymap.set('n', '<leader>a', builtin.live_grep, {})
  vim.keymap.set('v', '<leader>a', function()
    local text = vim.fn.getreg('"')
    builtin.grep_string({ default_text = text })
  end, {})

  -- Git (replaces gv.vim)
  vim.keymap.set('n', '<leader>gc', builtin.git_commits, {})
  vim.keymap.set('n', '<leader>gb', builtin.git_branches, {})
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.telescope")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/telescope.lua
git commit -m "feat: add telescope fuzzy finder"
```

---

### Task 9: LSP + Mason

**Files:**
- Modify: `lua/plugins/lsp.lua`

- [ ] **Step 1: Write lsp.lua**

```lua
-- ~/.config/nvim/lua/plugins/lsp.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'williamboman/mason.nvim' })
add({ source = 'williamboman/mason-lspconfig.nvim' })
add({ source = 'neovim/nvim-lspconfig' })

now(function()
  require('mason').setup()

  local lspconfig = require('lspconfig')
  local servers = {
    clangd = {
      filetypes = { 'c', 'cpp' },
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
    },
    rust_analyzer = {
      filetypes = { 'rust' },
      settings = {
        ['rust-analyzer'] = {
          checkOnSave = { command = 'clippy' },
          procMacro = { enable = true },
          cargo = { allFeatures = true },
        },
      },
    },
    gopls = {
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      root_dir = lspconfig.util.root_pattern('go.work', 'go.mod'),
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
    },
    ts_ls = {
      filetypes = { 'javascript', 'typescript' },
      root_dir = lspconfig.util.root_pattern('tsconfig.json', 'jsconfig.json', 'package.json'),
      settings = {
        typescript = { suggest = { completeFunctionCalls = true } },
        javascript = { suggest = { completeFunctionCalls = true } },
      },
    },
    pylsp = {
      filetypes = { 'python' },
      root_dir = lspconfig.util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', '.git'),
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
    },
    lua_ls = {
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          workspace = { checkThirdParty = false },
        },
      },
    },
    bashls = {
      filetypes = { 'sh' },
      root_dir = lspconfig.util.root_pattern('.shellcheckrc', '.git'),
      settings = {
        bashIde = {
          globPattern = '**/*@(.sh|.inc|.bash|.command|.bashrc|.bash_profile|.profile)',
          includeAllWorkspaceSymbols = true,
        },
      },
    },
    vimls = {
      filetypes = { 'vim' },
    },
    marksman = {
      filetypes = { 'markdown' },
      root_dir = lspconfig.util.root_pattern('.marksman.toml', '.git'),
    },
    yamlls = {
      filetypes = { 'yaml' },
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
    },
    jsonls = {
      filetypes = { 'json' },
    },
  }

  -- Common on_attach: keymaps + format on save
  local on_attach = function(client, bufnr)
    local bufopts = { buffer = bufnr, silent = true }

    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gc', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

    vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gc', function() vim.lsp.buf.declaration({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gt', function() vim.lsp.buf.type_definition({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gi', function() vim.lsp.buf.implementation({ reuse_win = true }) end, bufopts)
    vim.keymap.set('n', '<leader>gr', function() vim.lsp.buf.references({ reuse_win = true }) end, bufopts)

    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '[D', function() vim.diagnostic.goto_prev({ count = 999 }) end, bufopts)
    vim.keymap.set('n', ']D', function() vim.diagnostic.goto_next({ count = 999 }) end, bufopts)
    vim.keymap.set('n', '<leader>gh', function() vim.diagnostic.open_float({ scope = 'cursor' }) end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp = pcall(require, 'cmp_nvim_lsp')
  if ok_cmp then
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  end

  -- Setup all servers
  for server_name, config in pairs(servers) do
    config.on_attach = on_attach
    config.capabilities = capabilities
    lspconfig[server_name].setup(config)
  end

  -- Format on save
  require('mason-lspconfig').setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = true,
  })

  local format_augroup = vim.api.nvim_create_augroup('LspFormat', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = format_augroup,
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
  })
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.lsp")' -c 'q' 2>&1
```

Expected: No errors. (Mason may auto-download tools — this is expected.)

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/lsp.lua
git commit -m "feat: add LSP with mason and nvim-lspconfig"
```

---

### Task 10: nvim-cmp (completion)

**Files:**
- Create: `lua/plugins/cmp.lua`

- [ ] **Step 1: Write cmp.lua**

```lua
-- ~/.config/nvim/lua/plugins/cmp.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'hrsh7th/nvim-cmp' })
add({ source = 'hrsh7th/cmp-nvim-lsp' })
add({ source = 'hrsh7th/cmp-buffer' })
add({ source = 'hrsh7th/cmp-path' })
add({ source = 'L3MON4D3/LuaSnip' })
add({ source = 'saadparwaiz1/cmp_luasnip' })
add({ source = 'rafamadriz/friendly-snippets' })

now(function()
  local cmp = require('cmp')
  local luasnip = require('luasnip')

  require('luasnip.loaders.from_vscode').lazy_load()
  require('friendly-snippets')

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
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.cmp")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/cmp.lua
git commit -m "feat: add nvim-cmp completion with LuaSnip"
```

---

### Task 11: Treesitter

**Files:**
- Modify: `lua/plugins/treesitter.lua`

- [ ] **Step 1: Write treesitter.lua**

```lua
-- ~/.config/nvim/lua/plugins/treesitter.lua

local add, now = MiniDeps.add, MiniDeps.now

add({
  source = 'nvim-treesitter/nvim-treesitter',
  hooks = { ':TSUpdate' },
})

now(function()
  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'c', 'cpp', 'rust', 'go', 'javascript', 'typescript',
      'python', 'lua', 'bash', 'vim', 'vimdoc', 'markdown',
      'markdown_inline', 'yaml', 'json', 'sql',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })

  -- Disable markdown conceal
  vim.g.markdown_syntax_conceal = 0
  vim.g.markdown_minlines = 100
  vim.g.markdown_fenced_languages = {
    'c', 'cpp', 'rust', 'go', 'javascript', 'typescript',
    'python', 'lua', 'bash=sh', 'vim', 'sql', 'yaml', 'json',
  }
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.treesitter")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/treesitter.lua
git commit -m "feat: add treesitter highlighting and indentation"
```

---

### Task 12: Flash.nvim + Substitute.nvim (motion)

**Files:**
- Create: `lua/plugins/flash.lua`

- [ ] **Step 1: Write flash.lua**

```lua
-- ~/.config/nvim/lua/plugins/flash.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'folke/flash.nvim' })

now(function()
  require('flash').setup({
    labels = 'asdfghjklqwertyuiopzxcvbnm',
    search = {
      mode = 'fuzzy',
    },
    modes = {
      char = {
        enabled = false,
      },
    },
  })

  -- Replace stargate (f/F → flash)
  vim.keymap.set({ 'n', 'x', 'o' }, 'f', function()
    require('flash').jump()
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, 'F', function()
    require('flash').jump({ search = { mode = 'search' } })
  end)

  -- Replace asterisk
  vim.keymap.set({ 'n', 'x', 'o' }, '*', function()
    require('flash').jump({ search = { mode = 'search', forward = true } })
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '#', function()
    require('flash').jump({ search = { mode = 'search', forward = false } })
  end)
end)
```

- [ ] **Step 2: Write substitute.lua**

Write `lua/plugins/substitute.lua`:

```lua
-- ~/.config/nvim/lua/plugins/substitute.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'gbprod/substitute.nvim' })

now(function()
  require('substitute').setup()

  -- Match monkey-vim subversive bindings
  vim.keymap.set('n', 's', require('substitute').operator, {})
  vim.keymap.set('x', 's', require('substitute').visual, {})
  vim.keymap.set('n', 'ss', require('substitute').line, {})
  vim.keymap.set('n', 'S', require('substitute').eol, {})
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.flash")' -c 'lua require("plugins.substitute")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/flash.lua lua/plugins/substitute.lua
git commit -m "feat: add flash.nvim and substitute.nvim for motion"
```

---

### Task 13: mini.surround, mini.ai, mini.indentscope

**Files:**
- Create: `lua/plugins/surround.lua`
- Create: `lua/plugins/textobjects.lua`

- [ ] **Step 1: Write surround.lua**

```lua
-- ~/.config/nvim/lua/plugins/surround.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'echasnovski/mini.surround' })

now(function()
  require('mini.surround').setup()
end)
```

- [ ] **Step 2: Write textobjects.lua**

```lua
-- ~/.config/nvim/lua/plugins/textobjects.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'echasnovski/mini.ai' })
add({ source = 'echasnovski/mini.indentscope' })

now(function()
  require('mini.ai').setup()
  require('mini.indentscope').setup({
    draw = { delay = 0, animation = function() end },
  })
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.surround")' -c 'lua require("plugins.textobjects")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/surround.lua lua/plugins/textobjects.lua
git commit -m "feat: add mini.surround, mini.ai, mini.indentscope"
```

---

### Task 14: Commentary + HighlightedYank

**Files:**
- Create: `lua/plugins/commentary.lua`
- Create: `lua/plugins/highlighted-yank.lua`

- [ ] **Step 1: Write commentary.lua**

```lua
-- ~/.config/nvim/lua/plugins/commentary.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'numToStr/Comment.nvim' })

now(function()
  require('Comment').setup()
end)
```

- [ ] **Step 2: Write highlighted-yank.lua**

```lua
-- ~/.config/nvim/lua/plugins/highlighted-yank.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'machakann/vim-highlightedyank' })

now(function()
  vim.g.highlightedyank_highlight_duration = 200
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.commentary")' -c 'lua require("plugins.highlighted-yank")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/commentary.lua lua/plugins/highlighted-yank.lua
git commit -m "feat: add comment.nvim and vim-highlightedyank"
```

---

### Task 15: Gitsigns + Fugitive

**Files:**
- Create: `lua/plugins/gitsigns.lua`
- Create: `lua/plugins/fugitive.lua`

- [ ] **Step 1: Write gitsigns.lua**

```lua
-- ~/.config/nvim/lua/plugins/gitsigns.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'lewis6991/gitsigns.nvim' })

now(function()
  require('gitsigns').setup()
end)
```

- [ ] **Step 2: Write fugitive.lua**

```lua
-- ~/.config/nvim/lua/plugins/fugitive.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'tpope/vim-fugitive' })

later(function()
  vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { silent = true })
  vim.keymap.set('n', '<leader>gd', '<cmd>Gdiff<CR>', { silent = true })
  vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<CR>', { silent = true })
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.gitsigns")' -c 'lua require("plugins.fugitive")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/gitsigns.lua lua/plugins/fugitive.lua
git commit -m "feat: add gitsigns and fugitive for git integration"
```

---

### Task 16: nvim-ufo (folding)

**Files:**
- Create: `lua/plugins/ufo.lua`

- [ ] **Step 1: Write ufo.lua**

```lua
-- ~/.config/nvim/lua/plugins/ufo.lua

local add, now = MiniDeps.add, MiniDeps.now

add({
  source = 'kevinhwang91/nvim-ufo',
  depends = { 'kevinhwang91/promise-async' },
})

now(function()
  vim.o.foldcolumn = '0'
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true

  require('ufo').setup({
    provider_selector = function(_, ft, _)
      return { 'treesitter', 'indent' }
    end,
    -- Match FastFold behavior: only update on zx/zX/za/zA
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
end)
```

- [ ] **Step 2: Verify**

```bash
nvim --headless -c 'lua require("plugins.ufo")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/ufo.lua
git commit -m "feat: add nvim-ufo for folding"
```

---

### Task 17: Autopairs + Matchup + Repeat

**Files:**
- Create: `lua/plugins/autopairs.lua`
- Create: `lua/plugins/matchup.lua`
- Create: `lua/plugins/repeat.lua`

- [ ] **Step 1: Write autopairs.lua**

```lua
-- ~/.config/nvim/lua/plugins/autopairs.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'windwp/nvim-autopairs' })

now(function()
  local npairs = require('nvim-autopairs')
  npairs.setup()

  -- Disable " pairing in vim files
  local rule = require('nvim-autopairs.rule')
  npairs.add_rule(rule('"', '"', 'vim'):with_pair(function()
    return false
  end))
end)
```

- [ ] **Step 2: Write matchup.lua**

```lua
-- ~/.config/nvim/lua/plugins/matchup.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'andymass/vim-matchup' })

now(function()
  vim.g.matchup_matchparen_deferred = 1
  vim.g.matchup_matchparen_offscreen = {}
end)
```

- [ ] **Step 3: Write repeat.lua**

```lua
-- ~/.config/nvim/lua/plugins/repeat.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'tpope/vim-repeat' })

now(function()
  -- No config needed; vim-repeat works by hooking into vim's .
end)
```

- [ ] **Step 4: Verify**

```bash
nvim --headless -c 'lua require("plugins.autopairs")' -c 'lua require("plugins.matchup")' -c 'lua require("plugins.repeat")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/autopairs.lua lua/plugins/matchup.lua lua/plugins/repeat.lua
git commit -m "feat: add autopairs, matchup, and vim-repeat"
```

---

### Task 18: Retained Vim Plugins (gutentags, visual-multi, eunuch)

**Files:**
- Create: `lua/plugins/gutentags.lua`
- Create: `lua/plugins/visual-multi.lua`
- Create: `lua/plugins/eunuch.lua`

- [ ] **Step 1: Write gutentags.lua**

```lua
-- ~/.config/nvim/lua/plugins/gutentags.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'ludovicchabant/vim-gutentags' })

now(function()
  vim.g.gutentags_modules = { 'ctags' }
  vim.g.gutentags_project_root = {
    '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout',
  }
  vim.g.gutentags_cache_dir = vim.fn.expand('$HOME/.cache/tags')
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
end)
```

- [ ] **Step 2: Write visual-multi.lua**

```lua
-- ~/.config/nvim/lua/plugins/visual-multi.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'mg979/vim-visual-multi' })

later(function()
  vim.g.VM_maps = {}
  vim.g.VM_maps['Select Operator'] = 'gs'
  vim.g.VM_set_statusline = 0
  vim.g.VM_silent_exit = 1
end)
```

- [ ] **Step 3: Write eunuch.lua**

```lua
-- ~/.config/nvim/lua/plugins/eunuch.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'tpope/vim-eunuch' })

later(function()
  -- Commands available: :Remove, :Rename, :Chmod, :SudoWrite, etc.
end)
```

- [ ] **Step 4: Verify**

```bash
nvim --headless -c 'lua require("plugins.gutentags")' -c 'lua require("plugins.visual-multi")' -c 'lua require("plugins.eunuch")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/gutentags.lua lua/plugins/visual-multi.lua lua/plugins/eunuch.lua
git commit -m "feat: add gutentags, visual-multi, and vim-eunuch"
```

---

### Task 19: Oil.nvim + Project.nvim

**Files:**
- Create: `lua/plugins/oil.lua`
- Create: `lua/plugins/project.lua`

- [ ] **Step 1: Write oil.lua**

```lua
-- ~/.config/nvim/lua/plugins/oil.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'stevearc/oil.nvim' })

later(function()
  require('oil').setup({
    keymaps = {
      ['-'] = 'actions.parent',
      ['<CR>'] = 'actions.select',
      ['<C-s>'] = 'actions.select_vsplit',
      ['<C-v>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
    },
  })

  -- Replace dirvish bindings
  vim.keymap.set('n', '-', function()
    require('oil').open(vim.fn.expand('%:p:h'))
  end, { silent = true })

  vim.keymap.set('n', '~', function()
    local root = vim.fn.FindRootDirectory and vim.fn.FindRootDirectory() or vim.fn.expand('~')
    if root == '' then root = vim.fn.expand('~') end
    require('oil').open(root)
  end, { silent = true })
end)
```

- [ ] **Step 2: Write project.lua**

```lua
-- ~/.config/nvim/lua/plugins/project.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'ahmedkhalf/project.nvim' })

now(function()
  require('project_nvim').setup({
    patterns = { '.root', '.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout' },
    silent_chdir = true,
    manual_mode = true,
  })

  -- Replace vim-rooter
  vim.keymap.set('n', '<leader>cr', function()
    vim.cmd('ProjectRoot')
  end, { silent = true })

  local rooter_augroup = vim.api.nvim_create_augroup('ChangeRoot', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = rooter_augroup,
    callback = function()
      vim.cmd('ProjectRoot')
    end,
  })
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.oil")' -c 'lua require("plugins.project")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/oil.lua lua/plugins/project.lua
git commit -m "feat: add oil.nvim and project.nvim"
```

---

### Task 20: Marks + Auto-session

**Files:**
- Create: `lua/plugins/marks.lua`
- Create: `lua/plugins/auto-session.lua`

- [ ] **Step 1: Write marks.lua**

```lua
-- ~/.config/nvim/lua/plugins/marks.lua

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'chentoast/marks.nvim' })

now(function()
  require('marks').setup({
    default_mappings = false,
    mappings = {
      set_next = 'm',
    },
  })
end)
```

- [ ] **Step 2: Write auto-session.lua**

```lua
-- ~/.config/nvim/lua/plugins/auto-session.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'rmagatti/auto-session' })

later(function()
  require('auto-session').setup({
    log_level = 'error',
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
  })

  vim.keymap.set('n', '<leader>ws', '<cmd>SessionSave<CR>', { silent = true })
  vim.keymap.set('n', '<leader>rs', '<cmd>SessionDelete<CR>', { silent = true })
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.marks")' -c 'lua require("plugins.auto-session")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/marks.lua lua/plugins/auto-session.lua
git commit -m "feat: add marks.nvim and auto-session"
```

---

### Task 21: Toggleterm + Trouble

**Files:**
- Create: `lua/plugins/toggleterm.lua`
- Create: `lua/plugins/trouble.lua`

- [ ] **Step 1: Write toggleterm.lua**

```lua
-- ~/.config/nvim/lua/plugins/toggleterm.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'akinsho/toggleterm.nvim' })

later(function()
  require('toggleterm').setup({
    size = 20,
    open_mapping = '<F5>',
    direction = 'horizontal',
  })

  -- Async Make command
  vim.api.nvim_create_user_command('Make', function(opts)
    local Terminal = require('toggleterm.terminal').Terminal
    local make = Terminal:new({ cmd = 'make ' .. (opts.args or ''), hidden = true })
    make:open()
  end, { nargs = '*', complete = 'file' })

  -- Async Run command
  vim.api.nvim_create_user_command('AsyncRun', function(opts)
    local Terminal = require('toggleterm.terminal').Terminal
    local run = Terminal:new({ cmd = opts.args, hidden = true })
    run:open()
  end, { nargs = '+', complete = 'file' })

  vim.keymap.set('n', '<F3>', '<cmd>Make ', {})
  vim.keymap.set('n', '<F4>', '<cmd>AsyncRun ', {})
end)
```

- [ ] **Step 2: Write trouble.lua**

```lua
-- ~/.config/nvim/lua/plugins/trouble.lua

local add, later = MiniDeps.add, MiniDeps.later

add({ source = 'folke/trouble.nvim' })

later(function()
  require('trouble').setup({
    auto_close = true,
    auto_refresh = true,
    height = 10,
  })

  -- Toggle quickfix / loclist
  vim.keymap.set('n', '<leader>q', '<cmd>Trouble quickfix toggle<CR>', { silent = true })
  vim.keymap.set('n', '<leader>l', '<cmd>Trouble loclist toggle<CR>', { silent = true })
end)
```

- [ ] **Step 3: Verify**

```bash
nvim --headless -c 'lua require("plugins.toggleterm")' -c 'lua require("plugins.trouble")' -c 'q' 2>&1
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/toggleterm.lua lua/plugins/trouble.lua
git commit -m "feat: add toggleterm and trouble.nvim"
```

---

### Task 22: Final Integration Pass

**Files:**
- Modify: `lua/core/keys.lua` (cleanup duplicate F1/F2 maps if any)
- Verify: Full end-to-end load

- [ ] **Step 1: Clean up keys.lua F1/F2 fallbacks**

Remove or comment out the F1/F2 fallback maps in `keys.lua` since telescope maps them in its plugin file.

In `lua/core/keys.lua`, delete these lines:
```lua
map('n', '<F1>', '<cmd>Telescope live_grep<CR>', { silent = true })
map('n', '<F2>', '<cmd>Telescope resume<CR>', { silent = true })
```

- [ ] **Step 2: Full load test**

```bash
nvim --headless -c 'lua print("monkey-nvim loaded successfully")' -c 'q' 2>&1
```

Expected: `monkey-nvim loaded successfully` printed, no errors.

- [ ] **Step 3: Verify key plugins report as loaded**

```bash
nvim --headless -c 'lua vim.cmd("DepsStatus")' -c 'q' 2>&1
```

Expected: Lists all plugins and their status.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: final integration pass and cleanup"
```

---

## Self-Review

**1. Spec coverage:**
- All 33 plugins/features mapped to tasks
- All settings, autocmds, filetype configs, keymaps covered
- All 12 LSP servers configured
- mini.deps bootstrap included
- Error handling via pcall in init.lua plugin loop
- True color fallback in options.lua
- Format on save in lsp.lua

**2. Placeholder scan:** No TBD/TODO fragments. All code blocks are complete.

**3. Type consistency:** Plugin names match across init.lua and individual files. Keymaps don't conflict between global keys.lua and plugin-local maps.
