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
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    Admin.temp_ban(player,event.player_index,reason)
end)

--- Used to clear all parts of a player, removing warnings, reports, jail and temp ban
-- @command clear-all
-- @param player the player to clear
commands.add_command('clear-all', 'Clears a player of any temp-ban, reports or warnings', {
    ['player']={true,'player'}
}, function(event,args)
    Admin.clear_player(args.player,event.player_index)
end)