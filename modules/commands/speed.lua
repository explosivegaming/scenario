--[[-- Commands Module - Set game speed
    - Adds a command that allows changing game speed
    @commands Set game speed
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('speed', 'Set game speed')
:add_param('amount', 'number-range', 0.1, 1)
:set_flag('admin_only')
:register(function(player, amount)
    game.speed = string.format("%.3f", amount)

    for _, player_ in pairs(game.connected_players) do
        player_.print{'expcom-speed.result', string.format("%.3f", string.format("%.3f", amount))}
    end

    return Commands.success
end)
