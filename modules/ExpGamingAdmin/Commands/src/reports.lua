local Admin = self
local Role = require('ExpGamingCore.Role')
local Game = require('FactorioStdLib.Game')

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
    for _,report in pairs(global.addons.reports.verified) do if report[1] == _player.name then player_return({'ExpGamingAdmin.cant-report',args.player.name}) return commands.error end end
    Admin.report(player,event.player_index,reason)
end)

--- Clears the reports of the player
-- @command clear-reports
-- @param player the player to clear the reports of
commands.add_command('clear-reports', 'Clears a player\'s reports', {
    ['player'] = {true,function(value)
        local player,err = commands.validate['player'](value) 
        if err then return commands.error(err) end
        local rtn = not Admin.is_banned(player) and player
        if not rtn then return commands.error{'ExpGamingAdmin.cant-report-ban',value} end return rtn
    end}
}, function(event,args)
    Admin.clear_reports(args.player,event.player_index)
end)