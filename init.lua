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

-- Each module in lua/ returns an optional `spec` (zpack plugin entries) and
-- an optional `config` (startup code). All specs are collected first and
-- handed to zpack.setup in one batch, then every config runs in list order.
local names = {
  'theme',      -- Color support / Theme / lualine.nvim
  'editor',     -- CheckFileChanges / Rooter / Shada / options / keymaps / mini.*
  'session',    -- Session / Restore
  'terminal',   -- Terminal / Send to pane
  'tags',       -- gutentags / cscope_maps + gtags / Ctags
  'clipboard',  -- Clipboard
  'docset',     -- Docset
  'treesitter', -- nvim-treesitter
  'git',        -- Git
  'navigation', -- oil.nvim + fzf-lua / flash / ufo / bqf
  'sudo',       -- sudo write
  'ai',         -- minuet-ai.nvim
  'lsp',        -- LSP
  'completion', -- blink.cmp
}

local spec = {}
for _, name in ipairs(names) do
  local m = require(name)
  if m.spec then
    vim.list_extend(spec, m.spec)
  end
end

require('zpack').setup({ spec = spec })

for _, name in ipairs(names) do
  local m = require(name)
  if m.config then
    m.config()
  end
end
