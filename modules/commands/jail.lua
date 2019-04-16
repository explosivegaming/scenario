local Commands = require 'expcore.commands'
local JailControl = require 'modules.addons.jail-control'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
require 'config.command_parse_roles'

Commands.new_command('jail','Puts a player into jail and removes all other roles')
:add_param('player',false,'player-role')
:add_param('reason',true)
:enable_auto_concat()
:register(function(player,action_player,reason,raw)
    reason = reason or 'Non Given.'
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    if JailControl.jail_player(action_player,player.name) then
        game.print{'exp-commands.jail-give',action_player_name_color,by_player_name_color,reason}
    else
        return Commands.error{'exp-commands.jail-already-jailed',action_player_name_color}
    end
end)

Commands.new_command('unjail','Puts a player into jail and removes all other roles')
:add_param('player',false,'player-role')
:enable_auto_concat()
:register(function(player,action_player,raw)
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    if JailControl.unjail_player(action_player,player.name) then
        game.print{'exp-commands.jail-remove',action_player_name_color,by_player_name_color}
    else
        return Commands.error{'exp-commands.jail-not-jailed',action_player_name_color}
    end
end)