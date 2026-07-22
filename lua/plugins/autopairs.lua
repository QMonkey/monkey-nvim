-- ~/.config/nvim/lua/plugins/autopairs.lua

local npairs = require('nvim-autopairs')
npairs.setup()

-- Disable " pairing in vim files
local rule = require('nvim-autopairs.rule')
npairs.add_rule(rule('"', '"', 'vim'):with_pair(function()
  return false
end))
