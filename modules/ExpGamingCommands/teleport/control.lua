--- A full ranking system for factorio.
-- @module ExpGamingCommands.teleport@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Admin = require('ExpGamingAdmin')

--- Teleports the user to the player given
-- @command go-to
-- @param player player to go to
commands.add_command('go-to', 'Go to a player\'s location', {
    ['player']={true,'player-online'}
}, function(event,args)
    Admin.go_to(args.player,event)
end)

--- Teleports a player to the user
-- @command bring
-- @param player player to go to
commands.add_command('bring', 'Bring a player to your location', {
    ['player']={true,'player-online'}
}, function(event,args)
    Admin.bring(args.player,event)
end)

--- Teleports one player to another
-- @command tp
-- @param player_one the player that is teleported
-- @param player_two the player who is the destination
commands.add_command('tp', 'Teleport a player to another player\'s location', {
    ['player_one']={true,'player-online'},
    ['player_two']={true,'player-online'}
}, function(event,args)
    Admin.tp(args.player_one,args.player_two)
end)
