local M = {}

-- Completion: blink.cmp + friendly-snippets
M.spec = {
  {
    src = 'https://github.com/saghen/blink.cmp',
    dependencies = { src = 'https://github.com/saghen/blink.lib' },
    build = function() require('blink.cmp').build():pwait() end,
    config = function()
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
    end,
  },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}

return M
