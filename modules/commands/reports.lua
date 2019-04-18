local Roles = require 'expcore.roles'
local Commands = require 'expcore.commands'
local ReportsControl = require 'modules.addons.reports-control'
local format_chat_player_name = ext_require('expcore.common','format_chat_player_name')
require 'config.command_parse_general'

Commands.new_command('report','Reports a player and notifies moderators')
:add_param('player',false,function(input,player,reject)
    input = Commands.parse('player',input,player,reject)
    if not input then return end
    if Roles.player_has_flag(player,'report-immune') then
        return reject{'exp-command.report-player-immune'}
    else
        return input
    end
end)
:add_param('reason',false)
:add_alias('report-player')
:enable_auto_concat()
:register(function(player,action_player,reason,raw)
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    if ReportsControl.report_player(action_player,reason,player.name) then
        game.print{'exp-commands.report-non-admin',action_player_name_color,reason}
        Roles.print_to_roles_higher('Trainee',{'exp-commands.report-admin',action_player_name_color,by_player_name_color,reason})
    else
        return Commands.error{'exp-commands.report-already-reported'}
    end
end)

Commands.new_command('get-reports','Gets a list of all reports that a player has on them. If no player then lists all players and the number of reports on them.')
:add_param('player',true,'player')
:add_alias('reports','list-reports')
:register(function(player,action_player,raw)
    if action_player then
        local reports = ReportsControl.get_player_reports(action_player)
        local action_player_name_color = format_chat_player_name(action_player)
        Commands.print{'exp-commands.report-player-report-title',action_player_name_color}
        for player_name,reason in pairs(reports) do
            local by_player_name_color = format_chat_player_name(player_name)
            Commands.print{'exp-commands.report-list',by_player_name_color,reason}
        end
    else
        local user_reports = ReportsControl.user_reports
        Commands.print{'exp-commands.report-player-count-title'}
        for player_name,reports in pairs(user_reports) do
            local player_name_color = format_chat_player_name(player_name)
            Commands.print{'exp-commands.report-list',player_name_color,#reports}
        end
    end
end)

Commands.new_command('clear-reports','Clears all reports from a player or just the report from one player.')
:add_param('player',false,'player')
:add_param('from-player',true,'player')
:register(function(player,action_player,from_player,raw)
    if from_player then
        if not ReportsControl.remove_player_report(action_player,from_player) then
            return Commands.error{'exp-commands.report-not-reported'}
        end
    else
        if not ReportsControl.clear_player_reports(action_player) then
            return Commands.error{'exp-commands.report-not-reported'}
        end
    end
    local action_player_name_color = format_chat_player_name(action_player)
    local by_player_name_color = format_chat_player_name(player)
    game.print{'exp-commands.report-removed',action_player_name_color,by_player_name_color}
end)