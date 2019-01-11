local Admin = self
local Role = require('ExpGamingCore.Role')

--- Gives a warning to a player
-- @command warn
-- @param player the player to give a warning to
-- @param[opt] reason the reason the player was given a warning
commands.add_command('warn', 'Gives a player a warning', {
    ['player']={true,'player-rank'},
    ['reason']={false,'string-inf'}
}, function(event,args)
    local player = args.player
    local reason = args.reason
    if Admin.is_banned(player) then player_return{'ExpGamingAdmin.cant-report-ban',args.player.name} return commands.error end
    if Role.has_flag(player,'not_reportable') then player_return{'ExpGamingAdmin.cant-report',args.player.name} return commands.error end
    Admin.give_warning(player,event.player_index,reason)
end)

--- Clears the warning of a player
-- @command clear-warnings
-- @param player the player to clear the warning of
commands.add_command('clear-warnings', 'Clears a player\'s warnings', {
    ['player'] = {true,'player'}
}, function(event,args)
    local player = args.player
    if Admin.is_banned(player) then player_return({'ExpGamingAdmin.cant-report-ban',args.player.name}) return commands.error end
    Admin.clear_warnings(player,event.player_index)
end)