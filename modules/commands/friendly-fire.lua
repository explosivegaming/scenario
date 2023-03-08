--[[-- Commands Module - Toggle Friendly Fire
    - Adds a command that toggle all friendly fire
    @commands Toggle Friendly Fire
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

-- For Modded Server Use
Commands.new_command('toggle-friendly-fire', 'Toggle Friendly Fire')
:register(function(_)
    game.forces.player.friendly_fire = not game.forces.player.friendly_fire
    return Commands.success{'expcom-ff.ff', game.forces.player.friendly_fire}
end)
