local Admin = Admin
local Ranking = require('ExpGamingCore.Ranking')

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
    if Admin.is_banned(player) then player_return({'ExpGamingAdmin.cant-report-ban',args.player}) return commands.error end
    if Ranking.get_rank(player):allowed('no-report') then player_return({'ExpGamingAdmin.cant-report',args.player}) return commands.error end
    Admin.give_warning(player,event.player_index,reason)
end)

--- Clears the warning of a player
-- @command clear-warnings
-- @param player the player to clear the warning of
commands.add_command('clear-warnings', 'Clears a player\'s warnings', {
    ['player'] = {true,'player'}
}, function(event,args)
    local player = args.player
    if Admin.is_banned(player) then player_return({'ExpGamingAdmin.cant-report-ban',args.player}) return commands.error end
    Admin.clear_warings(player,event.player_index)
end)