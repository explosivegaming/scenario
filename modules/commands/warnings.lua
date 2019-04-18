local Commands = require 'expcore.commands'
local WarningsControl = require 'modules.addons.warnings-control'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
local config = require 'config.warnings'
require 'config.command_parse_roles'

Commands.new_command('give-warning','Gives a warning to a player; may lead to automatic script action.')
:add_param('player',false,'player-role')
:add_param('reason',false)
:add_alias('warn')
:enable_auto_concat()
:register(function(player,action_player,reason,raw)
    WarningsControl.add_warnings(action_player,player.name)
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'exp-commands.warnings-received',action_player_name_color,by_player_name_color,reason}
end)

Commands.new_command('get-warnings','Gets the number of warnings a player has. If no player then lists all players and the number of warnings they have.')
:add_param('player',true,'player')
:add_alias('warnings','list-warnings')
:register(function(player,action_player,raw)
    if action_player then
        local warnings = WarningsControl.get_warnings(action_player)
        local script_warnings = WarningsControl.get_temp_warnings(action_player)
        local action_player_name_color = format_chat_player_name(action_player)
        Commands.print{'exp-commands.warnings-player',action_player_name_color,warnings,script_warnings,config.temp_warning_limit}
    else
        local rtn = {}
        local user_warnings = WarningsControl.user_warnings
        local user_temp_warnings = WarningsControl.user_temp_warnings
        for player_name,warnings in pairs(user_warnings) do
            rtn[player_name] = {#warnings,0}
        end
        for player_name,warnings in pairs(user_temp_warnings) do
            if not rtn[player_name] then
                rtn[player_name] = {0,0}
            end
            rtn[player_name][2] = #warnings
        end
        Commands.print{'exp-commands.warnings-list-tilte'}
        for player_name,warnings in pairs(rtn) do
            local player_name_color = format_chat_player_name(player_name)
            Commands.print{'exp-commands.warnings-list',player_name_color,warnings[1],warnings[2],config.temp_warning_limit}
        end
    end
end)

Commands.new_command('clear-warnigns','Clears all warnings (and script warnings) from a player')
:add_param('player',false,'player')
:register(function(player,action_player,raw)
    WarningsControl.clear_warnings(player,player.name)
    WarningsControl.clear_temp_warnings(player,player.name)
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'exp-commands.warnings-cleared',action_player_name_color,by_player_name_color}
end)