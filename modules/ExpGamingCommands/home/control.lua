--- A full ranking system for factorio.
-- @module ExpGamingCommands.home@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE

local Game = require('FactorioStdLib.Game')
local global = global{}

--- Sets the home for a player
-- @command set-home
commands.add_command('home', 'Allows you to set, remove and goto your homes', {
    ['command'] = {false,'string-list',{'set','remove','goto','list','return'}},
    ['name'] = {false,'string-len',10}
}, function(event,args)
    local player = Game.get_player(event)
    if not global[player.index] then local spawn_pos = player.force.get_spawn_position(player.surface) global[player.index] = {Spawn={spawn_pos.x,spawn_pos.y},_m=3,_n=1,_r={spawn_pos.x,spawn_pos.y}} end
    local homes = global[player.index]
    local command = args.command
    local name = args.name
    if command == 'set' then
        local pos = {math.floor(player.position.x),math.floor(player.position.y)}
        if homes._n+1 > homes._m then player_return{'ExpGamingCommands-home.too-many-homes',homes._m} return commands.error end
        homes[name] = pos
        homes._n=homes._n+1
        player_return{'ExpGamingCommands-home.set',name,pos[1],pos[2]}
    elseif command == 'remove' then
        if not homes[name] then player_return{'ExpGamingCommands-home.invalid',name} return commands.error end
        homes[name] = nil
        homes._n=homes._n-1
        player_return{'ExpGamingCommands-home.remove',name}
    elseif command == 'goto' then
        if not homes[name] then player_return{'ExpGamingCommands-home.invalid',name} return commands.error end
        local pos = {math.floor(player.position.x),math.floor(player.position.y)}
        player.teleport(player.surface.find_non_colliding_position('player',homes[name],32,1),player.surface)
        homes._r = pos
        player_return{'ExpGamingCommands-home.goto',name}
    elseif command == 'return' then
        local pos = {math.floor(player.position.x),math.floor(player.position.y)}
        player.teleport(player.surface.find_non_colliding_position('player',homes._r,32,1),player.surface)
        homes._r = pos
        player_return{'ExpGamingCommands-home.return',pos[1],pos[2]}
    else
        player_return{'ExpGamingCommands-home.homes',homes._n,homes._m}
        local index = 1
        for home_name,pos in pairs(homes) do if home_name ~= '_n' and home_name ~= '_r' and home_name ~= '_m' then player_return{'ExpGamingCommands-home.home',index,home_name,pos[1],pos[2]} index=index+1 end end
    end
end)
