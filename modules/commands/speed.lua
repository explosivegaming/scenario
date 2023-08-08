--[[-- Commands Module - Set game speed
    - Adds a command that allows changing game speed
    @commands Set game speed
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('game-speed', 'Set game speed')
:add_param('amount', 'number-range', 0.2, 1)
:set_flag('admin_only')
:register(function(_, amount)
    game.speed = math.round(amount, 3)
    return Commands.success{'expcom-speed.result', string.format('%.3f', amount)}
end)
