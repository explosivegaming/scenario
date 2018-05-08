-- made by cooldude
-- idea from Mylon - Dirt Path

local paths = {
    -- ['tile name'] = {health,convert to}
    -- health is the average (aim for 75%) number of steps in hundards before it changes
    ['refined-concrete']={40,'concrete'},
    ['refined-hazard-concrete-right']={40,'hazard-concrete-right'},
    ['refined-hazard-concrete-left']={40,'hazard-concrete-left'},
    ['concrete']={30,'stone-path'},
    ['hazard-concrete-right']={30,'stone-path'},
    ['hazard-concrete-left']={30,'stone-path'},
    ['stone-path']={15,'world-gen'}, -- world-gen just makes it pick the last tile not placed by a player
    ['sand-1']={3,'sand-2'},
    ['sand-2']={8,'sand-3'},
    ['sand-3']={3,'red-desert-3'},
    ['red-desert-3']={3,'red-desert-2'},
    ['red-desert-2']={8,'dirt-1'},
    ['grass-2']={3,'grass-1'},
    ['grass-1']={3,'grass-3'},
    ['grass-3']={8,'red-desert-0'},
    ['red-desert-0']={3,'red-desert-1'},
    ['red-desert-1']={8,'dirt-1'},
    ['dirt-1']={3,'dirt-2'},
    ['dirt-2']={3,'dirt-3'},
    ['dirt-3']={8,'dirt-4'},
    ['dirt-4']={3,'dirt-5'},
    ['dirt-5']={3,'dirt-6'},
    ['grass-4']={8,'dirt-4'}
}
for tile,value in pairs(paths) do
    value[1]=1/(value[1]*150)
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
        if old_tile.old_tile.name ~= 'refined-concrete' and old_tile.old_tile.name ~= 'refined-hazard-concrete-right' 
        and old_tile.old_tile.name ~= 'refined-hazard-concrete-left' and old_tile.old_tile.name ~= 'concrete'
        and old_tile.old_tile.name ~= 'hazard-concrete-right' and old_tile.old_tile.name ~= 'hazard-concrete-left'
        and old_tile.old_tile.name ~= 'stone-path' and old_tile.old_tile.name ~= 'water' and old_tile.old_tile.name ~= 'deep-water' then
            if global.paths == nil then global.paths = {} end -- nil as you can set to false to disable
            global.paths[global_key(surface,old_tile.position)]=old_tile.old_tile.name
        end
    end
end)

Event.register(defines.events.on_player_changed_position, function(event)
    local player = Game.get_player(event)
    local surface = player.surface
    local pos = player.position
    if not paths[surface.get_tile(pos).name] then return end
    if math.random() < paths[surface.get_tile(pos).name][1] then
        down_grade(surface,pos)
    end
end)