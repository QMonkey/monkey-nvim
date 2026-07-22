-- ~/.config/nvim/lua/plugins/visual-multi.lua

vim.cmd.packadd('vim-visual-multi')

vim.cmd([[
  let g:VM_maps = {}
  let g:VM_maps['Select Operator'] = 'gs'
  let g:VM_set_statusline = 0
  let g:VM_silent_exit = 1
  let g:VM_show_warnings = 0
]])
