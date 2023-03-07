--[[-- Commands Module - Loaders
    - Adds a command that enable or disable loader
    @commands Loaders
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

-- For Modded Server Use
Commands.new_command('toggle-loader', 'Toggle Loaders')
:register(function(_)
    local new_status = not game.player.force.recipes.loader.enabled
    
    game.player.force.recipes.loader.enabled = new_status
    game.player.force.recipes["fast-loader"].enabled = new_status
    game.player.force.recipes["express-loader"].enabled = new_status

    game.player.force.recipes.loader.hidden = not new_status
    game.player.force.recipes["fast-loader"].hidden = not new_status
    game.player.force.recipes["express-loader"].hidden = not new_status
    
    return Commands.success
end)
