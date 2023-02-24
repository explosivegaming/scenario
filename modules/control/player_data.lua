--[[-- Commands Module - Player Data
    @commands pdj
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
require 'config.expcore.command_general_parse'

Commands.new_command('player-data-json', 'Player Data Json Lookup')
:add_param('player_', false, 'player-alive')
:add_alias('pdj')
:register(function(player, player_)
    local msg = 'Player Data of ' .. player_ .. ' :'

    for _, name in pairs(PlayerData.Statistics.metadata.display_order) do
        local child = PlayerData.Statistics[name]
        local metadata = child.metadata
        local value = child:get(player_)

        if metadata.stringify then
            value = metadata.stringify(value)
        else
            value = format_number(value or 0)
        end

        msg = msg .. ' ' .. {'exp-statistics.' .. name} .. ' ' .. value

        if _ % 8 == 0 then
            msg = msg .. '\n'
        end
    end

    game.player.print(msg)
    return Commands.success -- prevents command complete message from showing
end)