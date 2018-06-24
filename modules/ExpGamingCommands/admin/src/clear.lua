local Admin = Admin

--- Clears a players inventory and moves it to chests in spawn
-- @command clear-inv
-- @param player the player to clear the inventory of
commands.add_command('clear-inv', 'Clears a player\'s invetory', {
    ['player'] = {true,'player-rank'}
}, function(event,args)
    local player = args.player
    if Admin.is_banned(player) then player_return({'reports.cant-report-ban',args.player}) return commands.error end
    Admin.move_inventory(player)
end)
