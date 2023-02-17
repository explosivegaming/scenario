--[[-- Commands Module - Pollution Handle
    - Adds a command that allows modifying pollution
    @commands Pollution Handle
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('pol-clr', 'Clear pollution')
:set_flag('admin_only')
:register(function(player)
    game.player.surface.clear_pollution()

    for _, player_ in pairs(game.connected_players) do
        player_.print{'expcom-pol.clr', player}
    end

    return Commands.success
end)

Commands.new_command('pol-off', 'Remove pollution')
:set_flag('admin_only')
:register(function(player)
    game.map_settings.pollution.enabled = false

    for _, player_ in pairs(game.connected_players) do
        player_.print{'expcom-pol.off', player}
    end
    
    return Commands.success
end)
