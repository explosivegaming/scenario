--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------

local function _homes(reset)
    global.addons = not reset and global.addons or {}
    global.addons.homes = not reset and global.addons.homes or {}
    return global.addons.homes
end

commands.add_command('set-home', 'Set your home position', {}, function(event,args)
    local player = Game.get_player(event)
    if not _homes()[player.index] then _homes()[player.index] = {player.force.get_spawn_position(player.surface),player.force.get_spawn_position(player.surface)} end
    _homes()[player.index][1] = {math.floor(player.position.x),math.floor(player.position.y)}
    player_return('Home set at: ('..math.floor(player.position.x)..','..math.floor(player.position.y)..')')
end)

commands.add_command('home', 'Go to you home position', {}, function(event,args)
    local player = Game.get_player(event)
    if not _homes()[player.index] then _homes()[player.index] = {player.force.get_spawn_position(player.surface),player.force.get_spawn_position(player.surface)} end
    _homes()[player.index][2] = {math.floor(player.position.x),math.floor(player.position.y)}
    player.teleport(player.surface.find_non_colliding_position('player',_homes()[player.index][1],32,1),player.surface)
end)

commands.add_command('return', 'Return to your previous position after using /home', {}, function(event,args)
    local player = Game.get_player(event)
    if not _homes()[player.index] then _homes()[player.index] = {player.force.get_spawn_position(player.surface),player.force.get_spawn_position(player.surface)} end
    local _temp = {math.floor(player.position.x),math.floor(player.position.y)}
    player.teleport(player.surface.find_non_colliding_position('player',_homes()[player.index][2],32,1),player.surface)
    _homes()[player.index][2] = _temp
end)
