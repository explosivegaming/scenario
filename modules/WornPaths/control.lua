--- Makes paths which wear down and paths where entites are placed.
-- @module WornPaths@^4.0.0
-- @author Cooldude2606
-- @license https://github.com/explosivegaming/scenario/blob/master/LICENSE
-- @alais ThisModule 

-- Module Require
local Game = require('FactorioStdLib.Game@^0.8.0')

-- Local Varibles
local entites = require(module_path..'/src/entites')
local paths = require(module_path..'/src/paths')
for tile,value in pairs(paths) do value[1]=-1/value[1] end
local placed_paths = require(module_path..'/src/placed')

local adjacency_boost = 2 -- makes paths more lickly to be next to each other; must be greater than 0
adjacency_boost = 10/adjacency_boost -- dont change this line

-- Module Define
local module_verbose = false
local ThisModule = {}

-- Global Define
local global = global()

-- Function Define
local function global_key(surface,pos)
    return 'S'..surface.name..'X'..math.floor(pos.x)..'Y'..math.floor(pos.y)
end

--- Downgrads a tile in this position
-- @usage ThisModule.down_grade(surface,{x=10,y=10})
-- @tparam surface surface the surface the tile is on
-- @tparam table pos the position of the tile to change
function ThisModule.down_grade(surface,pos)
    local tile = surface.get_tile(pos).name
    local new_tile = paths[tile][2]
    if new_tile == 'world-gen' then
        new_tile = global[global_key(surface,pos)] or 'grass-1' 
    end
    surface.set_tiles{{name=new_tile,position=pos}}
end

-- Event Handlers Define
script.on_event({defines.events.on_player_built_tile,defines.events.on_robot_built_tile}, function(event)
    local surface = event.surface_index and game.surfaces[event.surface_index] or event.robot and event.robot.surface
    local old_tiles = event.tiles
    for _,old_tile in pairs(old_tiles) do
        if placed_paths[old_tile.old_tile.name] or old_tile.old_tile.name == 'water' or old_tile.old_tile.name == 'deepwater' then else
            global[global_key(surface,old_tile.position)]=old_tile.old_tile.name -- not a mistake, this makes it have dimising returns
        end
    end
end)

script.on_event(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    if player and player.valid and game.tick > 10 then else return end
    if player.afk_time > 300 then return end
    local surface = player.surface
    local pos = player.position
    local tile_name = surface.get_tile(pos).name 
    if not paths[tile_name] then return end
    local count = -9 -- this value is important
    for x = -1,1 do for y = -1,1 do
        local _pos = {pos.x+x,pos.y+y}
        if placed_paths[tile_name] and not placed_paths[surface.get_tile(_pos).name] 
        or surface.get_tile(_pos).name == paths[tile_name][2] 
        then count=count+1 end
    end end
    local chance = paths[tile_name][1]/(count-adjacency_boost)
    if math.random() < chance then
        down_grade(surface,pos)
    end
end)

script.on_event({defines.events.on_built_entity,on_robot_built_entity}, function(event)
    local entity = event.created_entity
    local surface = entity.surface
    if entites[entity.name] then
        local box = entity.prototype.collision_box
        local size = math.abs(box.left_top.x-box.right_bottom.x)*math.abs(box.left_top.y-box.right_bottom.y)
        for x = box.left_top.x,box.right_bottom.x do for y = box.left_top.y,box.right_bottom.y do
            local pos = {x=x,y=y}
            local tile = surface.get_tile(pos).name
            if paths[tile] and math.random() < paths[tile][1]*size/(-10) then
                ThisModule.down_grade(surface,pos)
            end
        end end
    end
end)
-- Module Return
-- when called it will downgrade a tile
return setmetatable(ThisModule,{__call=function(self,...) self.down_grade(...) end}) 

--[[
/interface 
local tile_name = surface.get_tile(position).name 
if not paths[tile_name] then return end
local count = -9 -- this value is important
for x = -1,1 do for y = -1,1 do
    local _pos = {position.x+x,position.y+y}
    if placed_paths[tile_name] and not placed_paths[surface.get_tile(_pos).name] 
    or surface.get_tile(_pos).name == paths[tile_name][2] 
    then count=count+1 end
end end
return paths[tile_name][1]/(count-adjacency_boost)
]]