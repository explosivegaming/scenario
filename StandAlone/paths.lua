-- made by cooldude
-- idea from Mylon - Dirt Path

local paths = {
    -- ['tile name'] = {health,convert to}
    -- health is in hundrads of steps
    ['refined-concrete']={60,'concrete'},
    ['refined-hazard-concrete-right']={60,'hazard-concrete-right'},
    ['refined-hazard-concrete-left']={60,'hazard-concrete-left'},
    ['concrete']={40,'stone-path'},
    ['hazard-concrete-right']={40,'stone-path'},
    ['hazard-concrete-left']={40,'stone-path'},
    ['stone-path']={20,'world-gen'}, -- world-gen just makes it pick the last tile not placed by a player
    ['sand-1']={5,'sand-2'},
    ['sand-2']={10,'sand-3'},
    ['sand-3']={5,'red-desert-3'},
    ['red-desert-3']={5,'red-desert-2'},
    ['red-desert-2']={10,'dirt-1'},
    ['grass-2']={5,'grass-1'},
    ['grass-1']={5,'grass-3'},
    ['grass-3']={10,'red-desert-0'},
    ['red-desert-0']={5,'red-desert-1'},
    ['red-desert-1']={10,'dirt-1'},
    ['dirt-1']={5,'dirt-2'},
    ['dirt-2']={5,'dirt-3'},
    ['dirt-3']={10,'dirt-4'},
    ['dirt-4']={5,'dirt-5'},
    ['dirt-5']={5,'dirt-6'},
    ['dirt-6']={1000,'dirt-6'},
    ['grass-4']={10,'dirt-4'}
}
for tile,value in pairs(paths) do
    value[1]=value[1]*100
end

local function global_key(surface,pos)
    local key = 'S'..surface.name..'X'..math.floor(pos.x)..'Y'..math.floor(pos.y)
    if not global.paths then global.paths = {} end
    if not global.paths[key] then 
        local tile = surface.get_tile(pos).name
        global.paths[key] = {tile,paths[tile][1]} 
    end
    return global.paths[key]
end

local function down_grade(surface,pos)
    local tile = surface.get_tile(pos).name
    local new_tile = paths[tile][2]
    if new_tile == 'world-gen' then new_tile = global_key(surface,pos)[1] or 'grass-1' end
    surface.set_tiles{{name=new_tile,position=pos}}
    global_key(surface,pos)[2]=paths[new_tile][1]
end

Event.register(defines.events.on_player_built_tile, function(event)
    local surface = game.surfaces[event.surface_index]
    local old_tiles = event.tiles
    for _,old_tile in pairs(old_tiles) do
        if old_tile.old_tile.name ~= 'refined-concrete' and old_tile.old_tile.name ~= 'refined-hazard-concrete-right' 
        and old_tile.old_tile.name ~= 'refined-hazard-concrete-left' and old_tile.old_tile.name ~= 'concrete'
        and old_tile.old_tile.name ~= 'hazard-concrete-right' and old_tile.old_tile.name ~= 'hazard-concrete-left'
        and old_tile.old_tile.name ~= 'stone-path' and old_tile.old_tile.name ~= 'water' and old_tile.old_tile.name ~= 'deep-water' then
            global_key(surface,old_tile.position)[1]=old_tile.old_tile.name
        end
        global_key(surface,old_tile.position)[2]=paths[surface.get_tile(old_tile.position).name][1]
    end
end)

Event.register(defines.events.on_player_mined_tile, function(event)
    local surface = game.surfaces[event.surface_index]
    local old_tiles = event.tiles
    for _,old_tile in pairs(old_tiles) do
        global_key(surface,old_tile.position)[2]=paths[surface.get_tile(old_tile.position).name][1]
    end
end)

Event.register(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    local surface = player.surface
    local pos = player.position
    global_key(surface,pos)[2] = global_key(surface,pos)[2]-1
    if global_key(surface,pos)[2] <= 0 then
        down_grade(surface,pos)
    end
end)