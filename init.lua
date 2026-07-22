-- ~/.config/nvim/init.lua

-- --- Auto-bootstrap: clone plugins on first run -----------------------------

vim.pack.add({
  { src = 'https://github.com/sainnhe/sonokai' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/williamboman/mason.nvim' },
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
  { src = 'https://github.com/machakann/vim-highlightedyank' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/kevinhwang91/nvim-ufo' },
  { src = 'https://github.com/kevinhwang91/promise-async' },
  { src = 'https://github.com/ludovicchabant/vim-gutentags' },
  { src = 'https://github.com/chentoast/marks.nvim' },
  { src = 'https://github.com/folke/trouble.nvim' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/mg979/vim-visual-multi' },
  { src = 'https://github.com/tpope/vim-repeat' },
  { src = 'https://github.com/tpope/vim-eunuch' },
  { src = 'https://github.com/andymass/vim-matchup' },
  { src = 'https://github.com/akinsho/toggleterm.nvim' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/rmagatti/auto-session' },
})

-- --- Core ---------------------------------------------------------------

require('core.options')
require('core.autocmds')
require('core.keys')
require('core.filetypes')

-- --- Plugin configs -----------------------------------------------------

local plugin_list = {
  'colorscheme', 'lualine', 'telescope', 'project',
  'gutentags', 'toggleterm', 'lsp', 'cmp', 'treesitter',
  'gitsigns', 'fugitive', 'flash', 'substitute',
  'visual-multi', 'ufo', 'textobjects', 'surround',
  'repeat', 'autopairs', 'matchup', 'eunuch',
  'commentary', 'highlighted-yank', 'oil', 'marks',
  'auto-session', 'trouble',
}

for _, name in ipairs(plugin_list) do
  pcall(require, 'plugins.' .. name)
end

-- --- Colorscheme --------------------------------------------------------

vim.cmd('colorscheme sonokai')
