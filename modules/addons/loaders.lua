--[[-- Commands Module - Loaders
    - Adds a command that enable or disable loader
    @commands Loaders
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

-- For Modded Server Use
Commands.new_command('toggle-loader', 'Toggle Loaders')
:register(function(_)
    game.player.force.recipes.loader.enabled = not game.player.force.recipes.loader.enabled
    game.player.force.recipes["fast-loader"].enabled = not game.player.force.recipes["fast-loader"].enabled
    game.player.force.recipes["express-loader"].enabled = not game.player.force.recipes["express-loader"].enabled

    return Commands.success
end)
