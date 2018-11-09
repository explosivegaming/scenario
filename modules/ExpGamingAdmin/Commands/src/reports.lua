local Admin = self
local Role = require('ExpGamingCore.Role@^4.0.0')

--- Reports a player
-- @command report
-- @param player the player to report
-- @param[opt] reason the reason why the player was reported
commands.add_command('report', 'Reports a player', {
    ['player']={true,'player-rank'},
    ['reason']={false,'string-inf'}
}, function(event,args)
    local _player = Game.get_player(event)
    local player = args.player
    local reason = args.reason
    if Admin.is_banned(player) then player_return({'ExpGamingAdmin.cant-report-ban',args.player.name}) return commands.error end
    if Role.has_flag(player,'not_reportable') then player_return({'ExpGamingAdmin.cant-report',args.player.name}) return commands.error end
    for _,report in pairs(global.addons.reports.reports) do if report[1] == _player.name then player_return({'ExpGamingAdmin.cant-report',args.player.name}) return commands.error end end
    for _,report in pairs(global.addons.reports.varified) do if report[1] == _player.name then player_return({'ExpGamingAdmin.cant-report',args.player.name}) return commands.error end end
    Admin.report(player,event.player_index,reason)
end)

--- Clears the reports of the player
-- @command clear-reports
-- @param player the player to clear the reports of
commands.add_command('clear-reports', 'Clears a player\'s reports', {
    ['player'] = {true,Admin.is_not_banned}
}, function(event,args)
    Admin.clear_reports(args.player,event.player_index)
end)