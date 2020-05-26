--- Adds a custom spawn area with chests and afk turrets
-- @addon Spawn-Area

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game
local config = require 'config.spawn_area' --- @dep config.spawn_area
local tiles = config.tiles
local entities = config.entities
local belts = config.afk_belts.locations
local turrets = config.infinite_ammo_turrets.locations

Global.register(turrets, function(tbl)
    turrets = tbl
end)

-- returns the Spawn force or creates it
local function get_spawn_force()
    local force = game.forces['Spawn']
    if force and force.valid then return force end
    force = game.create_force('Spawn')
    force.set_cease_fire('player', true)
    game.forces['player'].set_cease_fire('Spawn', true)
    return force
end

-- protects and entity so players cant do anything to it
local function protect_entity(entity, set_force)
    if entity and entity.valid then
        entity.destructible = false
        entity.minable = false
        entity.rotatable = false
        entity.operable = false
        if not set_force then entity.health = 0 end
        if set_force then entity.force = get_spawn_force() end
    end
end

-- handles the infinite ammo turrets
local function spawn_turrets()
    if config.infinite_ammo_turrets.enabled then
        for _, turret_pos in pairs(turrets) do
            local surface = game.surfaces[turret_pos.surface]
            local pos = turret_pos.position
            local turret = surface.find_entity('gun-turret', pos)
            -- Makes a new turret if it is not found
            if not turret or not turret.valid then
                turret = surface.create_entity{name='gun-turret', position=pos, force='Spawn'}
                protect_entity(turret, true)
            end
            -- adds ammo to the turret
            local inv = turret.get_inventory(defines.inventory.turret_ammo)
            if inv.can_insert{name=config.infinite_ammo_turrets.ammo_type, count=10} then
                inv.insert{name=config.infinite_ammo_turrets.ammo_type, count=10}
            end
        end
    end
end

-- makes a 2x2 afk belt where set in config
local function spawn_belts(surface, position)
    local belt_details = {{-0.5, -0.5, 2}, {0.5, -0.5, 4}, {-0.5, 0.5, 0}, {0.5, 0.5, 6}} -- x, y,dir
    for _, belt_set in pairs(belts) do
        local o = position
        local p = belt_set
        for _, belt in pairs(belt_details) do
            local pos = {x=o.x+p.x+belt[1], y=o.y+p.y+belt[2]}
            local belt_entity = surface.create_entity{name='transport-belt', position=pos, force='neutral', direction=belt[3]}
            protect_entity(belt_entity)
        end
    end
end

-- generates an area with no water and removes entities in the decon area
local function spawn_base(surface, position)
    local dr = config.corrections.deconstruction_radius
    local dr2 = dr^2
    local dtile = config.corrections.deconstruction_tile
    local pr = config.corrections.pattern_radius
    local pr2 = pr^2
    local ptile = surface.get_tile(position).name
    if ptile == 'deepwater' or ptile == 'water' then ptile = 'grass-1' end
    local tiles_to_make = {}
    for x = -pr, pr do -- loop over x
        local x2 = x^2
        for y = -pr, pr do -- loop over y
            local y2 = y^2
            local prod = x2+y2
            local p = {x=position.x+x, y=position.y+y}
            if prod < dr2 then
                -- if it is inside the decon radius
                table.insert(tiles_to_make, {name=dtile, position=p})
                local entities_to_remove = surface.find_entities_filtered{area={{p.x-1, p.y-1}, {p.x, p.y}}}
                for _, entity in pairs(entities_to_remove) do
                    if entity.name ~= 'character' then entity.destroy() end
                end
            elseif prod < pr2 then
                -- if it is inside the pattern radius
                table.insert(tiles_to_make, {name=ptile, position=p})
            end
        end
    end
    surface.set_tiles(tiles_to_make)
end

-- generates the pattern that is in the config
local function spawn_pattern(surface, position)
    local tiles_to_make = {}
    local ptile = config.corrections.pattern_tile
    local o = config.corrections.offset
    local p = {x=position.x+o.x, y=position.y+o.y}
    for _, tile in pairs(tiles) do
        table.insert(tiles_to_make, {name=ptile, position={tile[1]+p.x, tile[2]+p.y}})
    end
    surface.set_tiles(tiles_to_make)
end

-- generates the entities that are in the config
local function spawn_entities(surface, position)
    local o = config.corrections.offset
    local p = {x=position.x+o.x, y=position.y+o.y}
    for _, entity in pairs(entities) do
        entity = surface.create_entity{name=entity[1], position={entity[2]+p.x, entity[3]+p.y}, force='neutral'}
        protect_entity(entity)
        entity.operable = true
    end
end

local refill_time = 60*60*5 -- 5 minutes
Event.on_nth_tick(refill_time, function()
    if game.tick < 10 then return end
    spawn_turrets()
end)

Event.add(defines.events.on_player_created, function(event)
    if event.player_index ~= 1 then return end
    local player = Game.get_player_by_index(event.player_index)
    local p = {x=0, y=0}
    local s = player.surface
    spawn_base(s, p)
    spawn_pattern(s, p)
    get_spawn_force()
    spawn_entities(s, p)
    spawn_belts(s, p)
    spawn_turrets()
    player.teleport(p, s)
end)

-- Way to access global table
return turrets