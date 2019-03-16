local Commands = require 'expcore.commands'
require 'config.command_parse_general'
require 'config.command_auth_admin'

Commands.new_command('admin-chat','Sends a message in chat that only admins can see.')
:add_param('message',false) -- the message to send in the admin chat
:enable_auto_concat()
:add_tag('admin_only',true)
:add_alias('ac')
:register(function(player,message,raw)
    local pcc = player and player.chat_color or {r=255,g=255,b=255}
    local player_name = player and player.name or '<Server>'
    local colour = string.format('%s,%s,%s',pcc.r,pcc.g,pcc.b)
    for _,return_player in pairs(game.connected_players) do
        if return_player.admin then
            return_player.print{'exp-commands.admin-chat-format',player_name,message,colour}
        end
    end
    return Commands.success -- prevents command complete message from showing
end)