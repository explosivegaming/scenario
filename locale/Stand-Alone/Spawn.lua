--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
--[[
note for positions
{-1,-1} {0,-1} {1,-1}
{-1,0} {0,0} {1,0}
{-1,1} {0,1} {1,1}
--]]
local tile_positions = {
    {0,0},{-1,-1},{1,-1},{-1,1},{1,1}
}

local entitys = {
    {'iron-chest',-2,-2},{'iron-chest',2,2},{'iron-chest',2,-2},{'iron-chest',-2,2}
}

Event.register(defines.events.on_player_created, function(event)
    if event.player_index == 1 then
        local offset = game.players[event.player_index].character.position
        local tiles = {}
        for _,position in pairs(tile_positions) do
            table.insert(tiles,{name='stone-path',position={position[1]+offset.x,position[2]+offset.y}})
        end
        game.players[event.player_index].surface.set_tiles(tiles)
        for _,entity in pairs(entitys) do
            local entity = game.players[event.player_index].surface.create_entity{name=entity[1],position={entity[2]+offset.x,entity[3]+offset.y},force='neutral'}
            entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
        end
    end
end)