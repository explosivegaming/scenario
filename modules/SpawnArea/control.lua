--- Creates a safe spawn area with chests and auto refilling turrets.
-- @module SpawnArea@4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Game = require('FactorioStdLib.Game')

-- Local Varibles
local turret_enabled = true
local turret_ammo = 'uranium-rounds-magazine'

local tile_positions = require(module_path..'/src/spawn_tiles')
local entity_positions = require(module_path..'/src/spawn_entities')

local global_offset = {x=0,y=-2}
local decon_radius = 20
local decon_tile = 'concrete'
local partern_radius = 50
local partern_tile = 'stone-path'

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Global Define
-- location of auto refill turrets
local global = global{
    {1,-3,-3},
    {1,-3,3},
    {1,3,-3},
    {1,3,3}
}

-- Function Define
function ThisModule.afk_belt(surface,offset)
    local belts = {{-0.5,-0.5,2},{0.5,-0.5,4},{-0.5,0.5,0},{0.5,0.5,6}}
    for _,pos in pairs(belts) do
        local position = {pos[1]+offset[1],pos[2]+offset[2]}
        local belt = surface.create_entity{name='transport-belt',position=position,force='neutral',direction=pos[3]}
        belt.destructible = false; belt.health = 0; belt.minable = false; belt.rotatable = false
    end
end

function ThisModule.auto_turret(surface,pos)
    if not turret_enabled then error('Auto Turrets are disabled.') end
    -- adds a new turrent to the global list, returns index
    local _return
    if surface then
        local surface = Game.get_surface(surface)
        if not surface then error('Surface is not valid.') end
        local posx = pos.x or pos[1] or error('Position is not valid.')
        local posy = pos.y or pos[2] or error('Position is not valid.')
        _return = table.insert(global,{surface.index,posx,posy})
    end
    -- spawns turrets and refills them
    if not game.forces['spawn'] then game.create_force('spawn').set_cease_fire('player',true) game.forces['player'].set_cease_fire('spawn',true) end
    for _,pos in pairs(global) do
        local surface = game.surfaces[pos[1]]
        local turret = surface.find_entity('gun-turret',{pos[2],pos[3]})
        if not turret then 
            turret = surface.create_entity{name='gun-turret',position={pos[2],pos[3]},force='spawn'} 
            turret.destructible = false; turret.health = 0; turret.minable = false; turret.rotatable = false; turret.operable = false; turret.health = 0
        end
        if turret.get_inventory(defines.inventory.turret_ammo).can_insert{name=turret_ammo,count=10} then
            turret.get_inventory(defines.inventory.turret_ammo).insert{name=turret_ammo,count=10}
        end
    end
end

-- Event Handlers Define
if turret_enabled then
    script.on_event(defines.events.on_tick,function(event)
        if event.tick % 3600 then
            ThisModule.auto_turret()
        end
    end)
end

script.on_event(defines.events.on_player_created, function(event)
    if event.player_index == 1 then
        local player = Game.get_player(event)
        local surface =  player.surface
        local offset = {x=0,y=0}
        local partern_base_tile = surface.get_tile(player.position).name
        if partern_base_tile == 'deepwater' or partern_base_tile == 'water' then partern_base_tile = 'grass-1' end
        local base_tiles = {}
        local tiles = {}
        -- generates a safe area of land and removes all entites
        for x = -partern_radius, partern_radius do
            for y = -partern_radius, partern_radius do
                if x^2+y^2 < decon_radius^2 then
                    table.insert(base_tiles,{name=decon_tile,position={x+offset.x,y+offset.y}})
                    local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                    for _,entity in pairs(entities) do if entity.name ~= 'player' then entity.destroy() end end
                elseif x^2+y^2 < partern_radius^2 then
                    table.insert(base_tiles,{name=partern_base_tile,position={x+offset.x,y+offset.y}})
                end
            end
        end
        surface.set_tiles(base_tiles)
        -- creates the partern in the spawn
        for _,position in pairs(tile_positions) do
            table.insert(tiles,{name=partern_tile,position={position[1]+offset.x+global_offset.x,position[2]+offset.y+global_offset.y}})
        end
        surface.set_tiles(tiles)
        -- spawns all the entites in spawn
        for _,entity in pairs(entity_positions) do
            local entity = surface.create_entity{name=entity[1],position={entity[2]+offset.x+global_offset.x,entity[3]+offset.y+global_offset.y},force='neutral'}
            entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
        end
        -- generates spawn turrents and afk belts
        if turret_enabled then ThisModule.auto_turret() end
        ThisModule.afk_belt(surface,{offset.x-5,offset.y-5})
        ThisModule.afk_belt(surface,{offset.x+5,offset.y-5})
        ThisModule.afk_belt(surface,{offset.x-5,offset.y+5})
        ThisModule.afk_belt(surface,{offset.x+5,offset.y+5})
        -- sets the spawn and moves the first player there
        player.force.set_spawn_position(offset,surface)
        player.teleport(offset,surface)
    end
end)

-- Module Return
return ThisModule 