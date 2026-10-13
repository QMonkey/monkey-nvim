local M = {}

-- Theme: sonokai colorscheme (with tty/unokai fallback) + lualine statusline
M.spec = {
  {
    src = 'https://github.com/sainnhe/sonokai',
    config = function()
      local util = require('util')
      -- Color support
      -- The Linux framebuffer console (tty1-tty63, TERM=linux) has no true
      -- color and sonokai is a true-color-only theme (its `&t_Co < 256 -> finish`
      -- guard makes it a no-op there). Detect it, moreover via a physical tty
      -- under a tmux client that masks the term as tmux-256color, so we can fall
      -- back to the built-in unokai theme below.
      if vim.fn.has('termguicolors') == 1 and not util.is_tty_console then
        vim.opt.termguicolors = true
      else
        vim.opt.termguicolors = false
      end

      -- Theme
      vim.opt.background = 'dark'
      if not util.is_tty_console then
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
        -- util.is_tty_console.
        vim.cmd('colorscheme unokai')
      end
    end,
  },
  {
    src = 'https://github.com/nvim-lualine/lualine.nvim',
    config = function()
      local util = require('util')
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
        if util.is_tty_console then return { fg = 0, bg = 13, gui = 'bold' } end
        return 'MiniStatuslineModeOther'
      end

      require('lualine').setup({
        options = {
          theme = not util.is_tty_console and 'sonokai' or '16color',
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
    end,
  },
}

return M
