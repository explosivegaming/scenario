--[[-- Commands Module - Player Data
    @commands Admin-Chat
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
require 'config.expcore.command_general_parse'

Commands.new_command('admin-chat', 'Sends a message in chat that only admins can see.')
:add_param('message', false)
:register(function(player, player_)
    for _, name in pairs(PlayerData.Statistics.metadata.display_order) do
        local child = PlayerData.Statistics[name]
        local metadata = child.metadata
        local value = child:get(player_)

    return Commands.success -- prevents command complete message from showing
end)