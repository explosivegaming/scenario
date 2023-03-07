--[[-- Commands Module - Set Friendly Fire
    - Adds a command that set all friendly fire
    @commands Set Friendly Fire
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

-- For Modded Server Use
Commands.new_command('friendly-fire', 'Set Friendly Fire')
:register(function(_)
    game.forces.player.friendly_fire = not game.forces.player.friendly_fire
    return Commands.success
end)
