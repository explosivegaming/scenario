-- made by cooldude
-- idea from Mylon - Dirt Path

local adjacency_boost = 1.3 -- makes paths more lickly to be next to each other
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
    ['refined-concrete']={30,'concrete'},
    ['refined-hazard-concrete-right']={30,'hazard-concrete-right'},
    ['refined-hazard-concrete-left']={30,'hazard-concrete-left'},
    ['concrete']={25,'stone-path'},
    ['hazard-concrete-right']={25,'stone-path'},
    ['hazard-concrete-left']={25,'stone-path'},
    ['stone-path']={10,'world-gen'}, -- world-gen just makes it pick the last tile not placed by a player
    ['sand-1']={1,'sand-2'},
    ['sand-2']={5,'sand-3'},
    ['sand-3']={1,'red-desert-3'},
    ['red-desert-3']={1,'red-desert-2'},
    ['red-desert-2']={5,'dirt-1'},
    ['grass-2']={1,'grass-1'},
    ['grass-1']={1,'grass-3'},
    ['grass-3']={5,'red-desert-0'},
    ['red-desert-0']={1,'red-desert-1'},
    ['red-desert-1']={5,'dirt-1'},
    ['dirt-1']={1,'dirt-2'},
    ['dirt-2']={1,'dirt-3'},
    ['dirt-3']={5,'dirt-4'},
    ['dirt-4']={1,'dirt-5'},
    ['dirt-5']={1,'dirt-6'},
    ['grass-4']={5,'dirt-4'}
}
for tile,value in pairs(paths) do
    value[1]=1/(value[1]*150) -- 150 do make it so about 75% will change by the expected value
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

Event.register(defines.events.on_player_built_tile, function(event)
    local surface = game.surfaces[event.surface_index]
    local old_tiles = event.tiles
    for _,old_tile in pairs(old_tiles) do
        if placed_paths[old_tile.old_tile.name] or old_tile.old_tile.name == 'water' or old_tile.old_tile.name == 'deep-water' then else
            if global.paths == nil then global.paths = {} end -- nil as you can set to false to disable
            global.paths[global_key(surface,old_tile.position)]=old_tile.old_tile.name
        end
    end
end)

Event.register(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    if player.afk_time > 300 then return end
    local surface = player.surface
    local pos = player.position
    local tile_name = surface.get_tile(pos).name 
    if not paths[tile_name] then return end
    local chance = paths[tile_name][1]
    for x = -1,1 do for y = -1,1 do
        local _pos = {pos.x+x,pos.y+y}
        if paths[tile_name][2] == 'world-gen' and not placed_paths[surface.get_tile(_pos).name] or surface.get_tile(_pos).name == paths[tile_name][2] then chance=chance*adjacency_boost end
    end end
    if math.random() < chance then
        down_grade(surface,pos)
    end
end)