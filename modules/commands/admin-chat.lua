local Commands = require 'expcore.commands'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
require 'config.expcore-commands.parse_general'

Commands.new_command('admin-chat','Sends a message in chat that only admins can see.')
:add_param('message',false) -- the message to send in the admin chat
:enable_auto_concat()
:set_flag('admin_only',true)
:add_alias('ac')
:register(function(player,message,raw)
    local player_name_colour = format_chat_player_name(player)
    for _,return_player in pairs(game.connected_players) do
        if return_player.admin then
            return_player.print{'expcom-admin-chat.format',player_name_colour,message}
        end
    end
    return Commands.success -- prevents command complete message from showing
end)