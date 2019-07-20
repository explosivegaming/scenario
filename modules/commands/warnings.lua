local Commands = require 'expcore.commands'
local Warnings = require 'modules.control.warnings'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
local config = require 'config.warnings'
require 'config.expcore-commands.parse_roles'

Commands.new_command('give-warning','Gives a warning to a player; may lead to automatic script action.')
:add_param('player',false,'player-role')
:add_param('reason',false)
:add_alias('warn')
:enable_auto_concat()
:register(function(player,action_player,reason,raw)
    Warnings.add_warning(action_player,player.name,reason)
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'expcom-warnings.received',action_player_name_color,by_player_name_color,reason}
end)

Commands.new_command('get-warnings','Gets the number of warnings a player has. If no player then lists all players and the number of warnings they have.')
:add_param('player',true,'player')
:add_alias('warnings','list-warnings')
:register(function(player,action_player,raw)
    if action_player then
        local warnings = Warnings.get_warnings(action_player)
        local script_warnings = Warnings.get_script_warnings(action_player)
        local action_player_name_color = format_chat_player_name(action_player)
        Commands.print{'expcom-warnings.player',action_player_name_color,warnings,script_warnings,config.temp_warning_limit}
    else
        local rtn = {}
        local user_warnings = Warnings.user_warnings
        local user_script_warnings = Warnings.user_script_warnings
        for player_name,warnings in pairs(user_warnings) do
            rtn[player_name] = {#warnings,0}
        end
        for player_name,warnings in pairs(user_script_warnings) do
            if not rtn[player_name] then
                rtn[player_name] = {0,0}
            end
            rtn[player_name][2] = #warnings
        end
        Commands.print{'expcom-warnings.list-tilte'}
        for player_name,warnings in pairs(rtn) do
            local player_name_color = format_chat_player_name(player_name)
            Commands.print{'expcom-warnings.list',player_name_color,warnings[1],warnings[2],config.temp_warning_limit}
        end
    end
end)

Commands.new_command('clear-warnings','Clears all warnings (and script warnings) from a player')
:add_param('player',false,'player')
:register(function(player,action_player,raw)
    Warnings.clear_warnings(action_player,player.name)
    Warnings.clear_script_warnings(action_player,player.name)
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'expcom-warnings.cleared',action_player_name_color,by_player_name_color}
end)