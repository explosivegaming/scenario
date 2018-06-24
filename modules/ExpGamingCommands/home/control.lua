--- A full ranking system for factorio.
-- @module ExpGamingCommands.kill
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local global = global{}

--- Sets the home for a player
-- @command set-home
commands.add_command('set-home', 'Set your home position', {}, function(event,args)
    local player = Game.get_player(event)
    if not global[player.index] then global[player.index] = {player.force.get_spawn_position(player.surface),player.force.get_spawn_position(player.surface)} end
    global[player.index][1] = {math.floor(player.position.x),math.floor(player.position.y)}
    player_return('Home set at: ('..math.floor(player.position.x)..','..math.floor(player.position.y)..')')
end)

--- Teleports a player back to their home
-- @command home
commands.add_command('home', 'Go to you home position', {}, function(event,args)
    local player = Game.get_player(event)
    if not global[player.index] then global[player.index] = {player.force.get_spawn_position(player.surface),player.force.get_spawn_position(player.surface)} end
    global[player.index][2] = {math.floor(player.position.x),math.floor(player.position.y)}
    player.teleport(player.surface.find_non_colliding_position('player',global[player.index][1],32,1),player.surface)
end)

--- Returns a player back to the place before using /home
-- @command return
commands.add_command('return', 'Return to your previous position after using /home', {}, function(event,args)
    local player = Game.get_player(event)
    if not global[player.index] then global[player.index] = {player.force.get_spawn_position(player.surface),player.force.get_spawn_position(player.surface)} end
    local _temp = {math.floor(player.position.x),math.floor(player.position.y)}
    player.teleport(player.surface.find_non_colliding_position('player',global[player.index][2],32,1),player.surface)
    global[player.index][2] = _temp
end)
