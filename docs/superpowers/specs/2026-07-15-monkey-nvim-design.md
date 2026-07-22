# monkey-nvim Design Spec

Author: Charles Qiu
Date: 2026-07-15

## Overview

Clone monkey-vim's full feature set into a Neovim-exclusive configuration written entirely in Lua. No Vim compatibility required. 33 features/plugins to migrate (30 external plugins + 3 Vim builtin packages from monkey-vim).

## Key Decisions

| Item | Choice |
|---|---|
| Plugin manager | mini.deps |
| Colorscheme | sainnhe/sonokai (andromeda variant) |
| Config structure | C (one plugin per file, self-contained) |
| Feature scope | Full coverage of monkey-vim |

## Directory Structure

```
~/.config/nvim/
├── init.lua                         # Entry: bootstrap mini.deps, require core + plugins
├── lua/
│   ├── core/
│   │   ├── options.lua              # vim.opt/vim.g global options
│   │   ├── autocmds.lua             # Global autocmds
│   │   ├── keys.lua                 # Global keymaps (not belonging to a single plugin)
│   │   └── filetypes.lua            # Filetype-specific settings (tab/space, shebang, docset)
│   │
│   └── plugins/
│       ├── colorscheme.lua          # sainnhe/sonokai (andromeda)
│       ├── lualine.lua              # nvim-lualine/lualine.nvim
│       ├── telescope.lua            # nvim-telescope/telescope.nvim (files, grep, git)
│       ├── project.lua              # ahmedkhalf/project.nvim
│       ├── gutentags.lua            # ludovicchabant/vim-gutentags (retained)
│       ├── toggleterm.lua           # akinsho/toggleterm.nvim
│       ├── lsp.lua                  # mason.nvim + mason-lspconfig + nvim-lspconfig
│       ├── cmp.lua                  # hrsh7th/nvim-cmp + LuaSnip + friendly-snippets
│       ├── treesitter.lua           # nvim-treesitter/nvim-treesitter
│       ├── gitsigns.lua             # lewis6991/gitsigns.nvim
│       ├── fugitive.lua             # tpope/vim-fugitive (retained)
│       ├── flash.lua                # folke/flash.nvim
│       ├── substitute.lua           # gbprod/substitute.nvim
│       ├── visual-multi.lua         # mg979/vim-visual-multi (retained)
│       ├── ufo.lua                  # kevinhwang91/nvim-ufo
│       ├── textobjects.lua          # mini.ai + mini.indentscope
│       ├── surround.lua             # echasnovski/mini.surround
│       ├── repeat.lua               # tpope/vim-repeat (retained)
│       ├── autopairs.lua            # windwp/nvim-autopairs
│       ├── matchup.lua              # andymass/vim-matchup (retained)
│       ├── eunuch.lua               # tpope/vim-eunuch (retained)
│       ├── commentary.lua           # numToStr/Comment.nvim
│       ├── highlighted-yank.lua     # machakann/vim-highlightedyank
│       ├── oil.lua                  # stevearc/oil.nvim
│       ├── marks.lua                # chentoast/marks.nvim
│       ├── auto-session.lua         # rmagatti/auto-session
│       └── trouble.lua              # folke/trouble.nvim
│
├── after/
│   └── ftplugin/                    # Filetype overrides if needed
└── .gitignore
```

## Plugin Migration Table

### External Plugins (30)

| # | monkey-vim | monkey-nvim | Notes |
|---|---|---|---|
| 1 | tomasr/molokai | sainnhe/sonokai | andromeda variant |
| 2 | itchyny/lightline.vim | nvim-lualine/lualine.nvim | Lua-native statusline |
| 3 | Yggdroot/LeaderF | nvim-telescope/telescope.nvim | Lua fuzzy finder |
| 4 | dyng/ctrlsf.vim | telescope live_grep | Built into Telescope |
| 5 | airblade/vim-rooter | ahmedkhalf/project.nvim | Lua project root detection |
| 6 | ludovicchabant/vim-gutentags | Retained | User requires ctags support |
| 7 | skywind3000/asyncrun.vim | akinsho/toggleterm.nvim | Lua terminal |
| 8 | tpope/vim-fugitive | Retained | No Lua alternative |
| 9 | junegunn/gv.vim | telescope git_commits | Built into Telescope |
| 10 | airblade/vim-gitgutter | lewis6991/gitsigns.nvim | Lua git diff signs |
| 11 | monkoose/vim9-stargate | folke/flash.nvim | Unified replacement for stargate+asterisk |
| 12 | svermeulen/vim-subversive | gbprod/substitute.nvim | Lua substitute operator |
| 13 | haya14busa/vim-asterisk | flash.nvim | Merged into flash |
| 14 | mg979/vim-visual-multi | Retained | Irreplaceable |
| 15 | Konfekt/FastFold | kevinhwang91/nvim-ufo | Lua folding |
| 16 | wellle/targets.vim | echasnovski/mini.ai | Lua text objects |
| 17 | michaeljsmith/vim-indent-object | echasnovski/mini.indentscope | Lua indent objects |
| 18 | tpope/vim-surround | echasnovski/mini.surround | Lua surround |
| 19 | tpope/vim-repeat | Retained | Companion to surround/visual-multi |
| 20 | cohama/lexima.vim | windwp/nvim-autopairs | Lua auto pairing |
| 21 | andymass/vim-matchup | Retained | Enhanced % jumping, nvim compatible |
| 22 | tpope/vim-eunuch | Retained | Unix file operations |
| 23 | yegappan/lsp | neovim/nvim-lspconfig + mason | Native Neovim LSP |
| 24 | hrsh7th/vim-vsnip | L3MON4D3/LuaSnip | Lua snippet engine |
| 25 | hrsh7th/vim-vsnip-integ | LuaSnip built-in | No separate plugin needed |
| 26 | rafamadriz/friendly-snippets | Retained | Snippet library |
| 27 | justinmk/vim-dirvish | stevearc/oil.nvim | Dirvish-like file browser |
| 28 | kshenoy/vim-signature | chentoast/marks.nvim | Lua mark visualization |
| 29 | tpope/vim-obsession | rmagatti/auto-session | Lua session management |
| 30 | romainl/vim-qf | folke/trouble.nvim | Enhanced quickfix |

### Vim Builtin Packages → Neovim (3)

| # | monkey-vim (packadd) | monkey-nvim | Notes |
|---|---|---|---|
| 31 | comment (gcc/gc) | numToStr/Comment.nvim | Vim builtin not available in nvim |
| 32 | hlyank (yank highlight) | machakann/vim-highlightedyank | No nvim builtin equivalent |
| 33 | nohlsearch | Autocmd-based | nvim has `:nohlsearch`, auto-clear via autocmd |

### Built-in Features (not plugins)

| monkey-vim | monkey-nvim |
|---|---|
| vim-markdown builtin syntax | nvim-treesitter (markdown parser) |
| netrw (disabled) | netrw (disabled by default in nvim) |
| man.vim | Retained (nvim builtin) |
| .clang-format auto-generation | Retained in autocmds.lua |

## Bootstrap / Startup Flow

```
init.lua
  ├── 1. Bootstrap mini.deps
  │      └── Download mini.deps if absent → add to rtp
  │
  ├── 2. require('core.options')      # Set vim.opt before plugins (e.g. termguicolors)
  │
  ├── 3. mini.deps.add() declare all plugins  # Register but don't load
  │
  ├── 4. require('core.autocmds')     # Global autocmds
  │    require('core.keys')           # Global keymaps
  │    require('core.filetypes')      # Filetype-specific settings
  │
  ├── 5. mini.deps.now() / later() load plugins on demand
  │      └── Each plugins/*.lua calls setup
  │
  └── 6. vim.cmd('colorscheme sonokai')
```

## mini.deps Lazy Loading Strategy

**Load immediately (now):**
colorscheme, lualine, flash.nvim, commentary, mini.*, treesitter, nvim-cmp, lspconfig, gitsigns, nvim-autopairs, nvim-ufo, highlightedyank, marks.nvim, project.nvim, substitute.nvim, surround, repeat, matchup

**Load lazily (later):**
telescope (cmd=Telescope), fugitive (cmd=Git/Gdiff/Gblame), trouble (cmd=Trouble), oil (cmd=Oil), visual-multi (cmd=VM/event=VM_Enter), auto-session (event=VimEnter), toggleterm (cmd=ToggleTerm)

**mini.deps commands:**
`:DepsInstall` — install/reinstall all registered plugins
`:DepsUpdate` — update installed plugins
`:DepsSnapSave`/`:DepsSnapRestore` — snapshot management

## Key Mappings (inherited from monkey-vim)

| Category | Mapping | Function |
|---|---|---|
| Leader | `,` | mapleader |
| Editing | `Y → y$`, `j/k → gj/gk`, `H/L → ^/$`, `> → >gv`, `U → <C-r>`, `; → :` | |
| Splits | `<C-hjkl>` navigate, `,s` / `,v` new split | |
| Buffers | `,o`, `[b`, `]b` | |
| Tabs | `,t`, `[t`, `]t`, `,1-9` | |
| Toggle | `cod` diff, `cop` paste, `col` list, `con` clear hlsearch | |
| Search | `<C-p>` find files (→telescope), `,a` grep (→telescope live_grep) | |
| LSP | `gd/gc/gt/gi/gr`, `gh` hover, `[d/]d` diagnostics | |
| Terminal | `<F3>` make, `<F4>` run command | |
| Snippets | `<Tab>/<S-Tab>` jump, `<C-l>` expand | |
| Substitute | `s/ss/S` | |
| Fold | `zx/zX/za/zA` | |
| File browser | `-` current dir, `~` project root | |
| Session | `,ws` save, `,rs` delete | |
| Quickfix | `,q` / `,l` toggle | |
| Zoom | `,z` zoom toggle | |
| Quit | `q` smart quit | |
| Rooter | `,cr` change root | |
| Trailing whitespace | `,<Space>` strip | |

## Error Handling

- **mini.deps download failure**: Print error message with manual install instructions
- **Plugin missing / not installed**: Each `plugins/*.lua` wraps `require` in `pcall`; silently skip on failure
- **LSP server not installed**: mason.nvim auto-detects available servers; `:Mason` for manual install; keymaps still work but produce no result if server not attached
- **ctags missing**: Gutentags errors on `:UpdateTags`, other functionality unaffected
- **Terminal without true color**: Fallback to 256 colors (same as monkey-vim)

## Settings Migration

All settings from monkey-vim `.vimrc` (lines 120-347) to be migrated to `lua/core/options.lua`:
- Encoding (UTF-8), fileencodings, fileformats
- Relative + absolute line numbers with InsertEnter/InsertLeave toggles
- Cursorline with InsertEnter/InsertLeave toggles
- Search: incsearch, hlsearch, ignorecase, smartcase, gdefault
- Tab settings: tabstop=8, softtabstop=8, shiftwidth=8, noexpandtab (default)
- FileType overrides: python/markdown 4-space, json/yaml/js/ts 2-space
- List/ListChars, cursorline, ruler, wildmenu, completeopt, magic
- Swap directory, jumpoptions, clipboard, smartindent/autoindent
- Splitright, timeout settings, scrolloff/sidescrolloff
- Fold settings, hidden, autoread, belloff, mouse, showtabline

## Autocmds Migration

From monkey-vim `.vimrc` to `lua/core/autocmds.lua`:
- Relative number toggle (WinEnter/InsertLeave)
- CursorLine toggle (InsertEnter/InsertLeave)
- FileType groups (tab settings, foldmethod, docset keywordprg, qf position)
- AutoInsertFileHead (.sh → #!/usr/bin/env bash, .py → #!/usr/bin/env python3)
- AutoResize on VimResized
- RestoreCursorPosition on BufReadPost
- Clear jumplist on VimEnter
- Paste mode disable on InsertLeave
- File change detection (FocusGained/BufWinEnter/WinEnter/CursorHold)
- InitClangFormat on VimEnter
- .tags filetype detection

## LSP Servers (from monkey-vim)

All 12 LSP server configurations migrated to `lsp.lua`:

| Server | Filetypes |
|---|---|
| clangd | c, cpp |
| rust-analyzer | rust |
| gopls | go, gomod, gowork, gotmpl |
| typescript-language-server | javascript, typescript |
| pylsp | python |
| lua-language-server | lua |
| bash-language-server | sh |
| vim-language-server | vim |
| marksman | markdown |
| yaml-language-server | yaml |
| vscode-json-language-server | json |

Auto-format on save via `autocmd BufWritePre * lua vim.lsp.buf.format()`.
