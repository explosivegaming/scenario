-- made by cooldude
-- idea from Mylon - Dirt Path

local adjacency_boost = 2 -- makes paths more lickly to be next to each other; must be greater than 0
local sizes = {
    ['stone-furnace']=2,
    ['steel-furnace']=2,
    ['electric-furnace']=3,
    ['assembling-machine-1']=3,
    ['assembling-machine-2']=3,
    ['assembling-machine-3']=3,
    ['beacon']=3,
    ['centrifuge']=3,
    ['chemical-plant']=3,
    ['oil-refinery']=7,
    ['storage-tank']=3,
    ['nuclear-reactor']=5,
    ['steam-engine']=4,
    ['steam-turbine']=4,
    ['boiler']=3,
    ['heat-exchanger']=3,
    ['stone-wall']=1,
    ['gate']=1,
    ['gun-turret']=2,
    ['laser-turret']=2,
    ['radar']=3,
    ['lab']=3,
    ['big-electric-pole']=2,
    ['substation']=2,
    ['rocket-silo']=7
}
local placed_paths = {
    ['refined-concrete']=true,
    ['refined-hazard-concrete-right']=true,
    ['refined-hazard-concrete-left']=true,
    ['concrete']=true,
    ['hazard-concrete-right']=true,
    ['hazard-concrete-left']=true,
    ['stone-path']=true
}
local paths = {
    -- ['tile name'] = {health,convert to}
    -- health is the average number of steps in hundards before it changes
    ['refined-concrete']={70,'concrete'},
    ['refined-hazard-concrete-right']={70,'hazard-concrete-right'},
    ['refined-hazard-concrete-left']={70,'hazard-concrete-left'},
    ['concrete']={50,'stone-path'},
    ['hazard-concrete-right']={50,'stone-path'},
    ['hazard-concrete-left']={50,'stone-path'},
    ['stone-path']={40,'world-gen'}, -- world-gen just makes it pick the last tile not placed by a player
    ['sand-1']={1,'sand-2'},
    ['sand-2']={3,'sand-3'},
    ['sand-3']={1,'red-desert-3'},
    ['red-desert-3']={1,'red-desert-2'},
    ['red-desert-2']={3,'dirt-1'},
    ['grass-2']={1,'grass-1'},
    ['grass-1']={1,'grass-3'},
    ['grass-3']={3,'red-desert-0'},
    ['red-desert-0']={1,'red-desert-1'},
    ['red-desert-1']={3,'dirt-1'},
    ['dirt-1']={1,'dirt-2'},
    ['dirt-2']={1,'dirt-3'},
    ['dirt-3']={3,'dirt-4'},
    ['dirt-4']={1,'dirt-5'},
    ['dirt-5']={1,'dirt-6'},
    ['grass-4']={3,'dirt-4'}
}
for tile,value in pairs(paths) do
    value[1]=1/(value[1]*125)
end

local function global_key(surface,pos)
    return 'S'..surface.name..'X'..math.floor(pos.x)..'Y'..math.floor(pos.y)
end

local function down_grade(surface,pos)
    local tile = surface.get_tile(pos).name
    local new_tile = paths[tile][2]
    if new_tile == 'world-gen' then
        if global.paths == nil then global.paths = {} end -- nil as you can set to false to disable
        new_tile = global.paths[global_key(surface,pos)] or 'grass-1' 
    end
    surface.set_tiles{{name=new_tile,position=pos}}
end

Event.register({defines.events.on_player_built_tile,defines.events.on_robot_built_tile}, function(event)
    local surface = event.surface_index and game.surfaces[event.surface_index] or event.robot and event.robot.surface
    local old_tiles = event.tiles
    for _,old_tile in pairs(old_tiles) do
        if placed_paths[old_tile.old_tile.name] or old_tile.old_tile.name == 'water' or old_tile.old_tile.name == 'deepwater' then else
            if global.paths == nil then global.paths = {} end -- nil as you can set to false to disable
            global.paths[global_key(surface,old_tile.position)]=old_tile.old_tile.name -- not a mistake, this makes it have dimising returns
        end
    end
end)

Event.register(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    if player and player.valid and game.tick > 10 then else return end
    if player.afk_time > 300 then return end
    local surface = player.surface
    local pos = player.position
    local tile_name = surface.get_tile(pos).name 
    if not paths[tile_name] then return end
    local chance = paths[tile_name][1]
    local count = 1
    for x = -1,1 do for y = -1,1 do
        local _pos = {pos.x+x,pos.y+y}
        if placed_paths[tile_name] and not placed_paths[surface.get_tile(_pos).name] 
        or surface.get_tile(_pos).name == paths[tile_name][2] 
        then chance=chance*((adjacency_boost+8)/count) count=count+1 end
    end end
    if math.random() < chance then
        down_grade(surface,pos)
    end
end)

Event.register({defines.events.on_built_entity,on_robot_built_entity}, function(event)
    local entity = event.created_entity
    local surface = entity.surface
    if sizes[entity.name] then
        local size = sizes[entity.name]
        for x = 0,size do for y = 0,size do
            local pos = {entity.position.x+x,entity.position.y+y}
            local tile = surface.get_tile(pos).name
            if math.random() < paths[tile]*size*10 then
                down_grade(surface,pos)
            end
        end end
    end
end)

--[[
/interface 
local tile_name = tile.name 
local chance = paths[tile_name][1]
local count = 1
for x = -1,1 do for y = -1,1 do
    local _pos = {position.x+x,position.y+y}
    if paths[tile_name][2] == 'world-gen' and not placed_paths[surface.get_tile(_pos).name]
    or surface.get_tile(_pos).name == paths[tile_name][2]
    then game.print('boost '..tostring(count)) chance=chance=chance*(adjacency_boost/count) count=count+1 end end 
end 
return chance
]]
