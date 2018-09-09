local Admin = Admin

--- Used to temp ban a player and give a reason
-- @command temp-ban
-- @param player the player to temp ban
-- @param[opt] reason the reason for the ban
commands.add_command('temp-ban', 'Temporarily ban a player', {
    ['player']={true,'player-rank'},
    ['reason']={false,'string-inf'}
}, function(event,args)
    local player = args.player
    local reason = args.reason
    if Admin.is_banned(player) then player_return({'ExpGamingAdmin.cant-report-ban',args.player}) return commands.error end
    Admin.temp_ban(player,event.player_index,reason)
end)