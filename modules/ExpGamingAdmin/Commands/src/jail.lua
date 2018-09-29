local Admin = Admin
local Role = require('ExpGamingCore.Role')

--- Used to jail a player which stops them from moving
-- @command jail
-- @param player the player to be jailed
-- @param[opt] reason the reason the player was jailed
commands.add_command('jail', 'Jails a player', {
    ['player']={true,'player-rank'},
    ['reason']={false,'string-inf'}
}, function(event,args)
    local player = args.player
    local reason = args.reason
    if Role.allowed(player,'no-report') then player_return{'ExpGamingAdmin.cant-report',args.player} return commands.error end
    if Admin.is_banned(player) then player_return{'commands.cant-report-ban',args.player} return commands.error end
    Admin.jail(player,event.player_index,reason)
end)

--- Used to unjail a player
-- @command unjail
-- @param player the player to unjail
commands.add_command('unjail', 'Returns a player\'s old rank', {
    ['player']={true,'player'}
}, function(event,args)
    local player = args.player
    if Admin.is_banned(player) then player_return({'commands.cant-report-ban',args.player}) return commands.error end
    Server.interface(Role.revert,true,player,event.player_index,2)
end)