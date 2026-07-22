-- ~/.config/nvim/lua/plugins/lualine.lua

local function vm_active()
  local ok, vm = pcall(vim.fn.VMInfos)
  return ok and type(vm) == 'table' and not vim.tbl_isempty(vm)
end

local augroup = vim.api.nvim_create_augroup('VMLualine', { clear = true })
vim.api.nvim_create_autocmd('User', {
  group = augroup,
  pattern = { 'visual_multi_start', 'visual_multi_exit' },
  callback = function()
    pcall(vim.cmd, 'lualine.refresh')
  end,
})

require('lualine').setup({
  options = {
    theme = 'sonokai',
    component_separators = '',
    section_separators = '',
  },
  sections = {
    lualine_a = {
      {
        function()
          if vm_active() then
            return 'V-MULTI'
          end
          return require('lualine.utils.mode').get_mode()
        end,
        color = function()
          if vm_active() then
            return { fg = '#1a1b26', bg = '#bb9af7', gui = 'bold' }
          end
          return {}
        end,
      },
    },
    lualine_b = {
      {
        'branch',
        icon = '⎇',
      },
      {
        'diff',
      },
      { 'diagnostics' },
    },
    lualine_c = {
      {
        'filename',
        path = 0,
      },
    },
    lualine_x = {
      {
        function()
          if not vm_active() then
            return ''
          end
          local ok, vm = pcall(vim.fn.VMInfos)
          if not ok or type(vm) ~= 'table' or vim.tbl_isempty(vm) then
            return ''
          end
          local result = vm.ratio or ''
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
    lualine_a = {
      {
        'tabs',
        mode = 1,
      },
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
})
