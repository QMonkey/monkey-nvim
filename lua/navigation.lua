local M = {}

-- Navigation & browsing: fzf-lua, flash, ufo, oil, bqf
M.spec = {
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
        -- Preview scrolling must use `builtin` (neovim-side) binds with
        -- *neovim* key notation: with the builtin previewer.
        keymap = {
          -- [1]=true merges with fzf-lua defaults; without it the table
          -- REPLACES them (losing shift-down/up, ctrl-f/b, alt-a, ...).
          -- alt-f/alt-i/alt-h are reserved by fzf-lua built-in actions
          -- (toggle_follow/ignore/hidden): their accept-binds are appended
          -- after keymap binds and win, so never bind those keys here.
          builtin = {
            [1] = true,
            ['<F2>'] = 'hide',
            ['<A-u>'] = 'preview-half-page-up',
            ['<A-d>'] = 'preview-half-page-down',
            ['<A-j>'] = 'preview-down',
            ['<A-k>'] = 'preview-up',
          },
          fzf = {
            [1] = true,
            ['ctrl-j'] = 'down',
            ['ctrl-k'] = 'up',
            ['alt-u'] = 'preview-half-page-up',
            ['alt-d'] = 'preview-half-page-down',
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
  {
    src = 'https://github.com/stevearc/oil.nvim',
    config = function()
      local util = require('util')
      require('oil').setup({
        view_options = { show_hidden = true, show_icons = false },
      })

      vim.keymap.set('n', '-', function()
        require('oil').open(vim.fn.expand('%:p:h'))
      end, { silent = true })

      vim.keymap.set('n', '~', function()
        local root = vim.fs.root(0, util.root_patterns) or vim.fn.expand('~')
        require('oil').open(root)
      end, { silent = true })
    end,
  },
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
}

return M
