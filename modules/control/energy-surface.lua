--- Adds a surface to generate energy to save space.
-- @addon Energy surface

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event

-- @class energy_surface
local energy_surface = {}
Global.register(energy_surface, function(tbl)
    energy_surface = tbl
end)

energy_surface.inputs = {}

local energy_entities = {
    ['solar-panel'] = {
        position = {5, 5},
    },
    ['accumulator'] = {
        position = {0, 5},
    }
}

--- Returns the energy surface with only lab tiles.
-- @return LuaSurface The initialised surface.
function energy_surface.init()
    if energy_surface.surface_index then
        return game.surfaces[energy_surface.surface_index]
    end

    local nauvis = game.surfaces['nauvis']

    local surface = game.create_surface('energy_surface', {
        width = 18,
        height = 18,
        starting_area = 'none',
        autoplace_controls = {
            coal = { frequency = "none", size = "none", richness = "none" },
            stone = { frequency = "none", size = "none", richness = "none" },
            ['copper-ore'] = { frequency = "none", size = "none", richness = "none" },
            ['iron-ore'] = { frequency = "none", size = "none", richness = "none" },
            ['uranium-ore'] = { frequency = "none", size = "none", richness = "none" },
            ['crude-oil'] = { frequency = "none", size = "none", richness = "none" },
            trees = { frequency = "none", size = "none", richness = "none" },
            ['enemy-base'] = { frequency = "none", size = "none", richness = "none" }
        },
        property_expression_names = {
            cliffiness = '0',
            water = '0',
            temperature = '0',
        }
    })
    surface.daytime = nauvis.daytime
    surface.generate_with_lab_tiles = true
    energy_surface.surface_index = surface.index

    -- Create the electric pole
    energy_surface.link_to_surface(game.surfaces['nauvis'])

    return surface
end

-- @param LuaSurface surface the surface to link to
function energy_surface.link_to_surface(surface)
    if not surface then return end
    local energy_surface = energy_surface.init()
    local substation = energy_surface.create_entity({name = 'substation', position = {0, 0}, force = game.forces['player']})
    if not substation then return end
    local power_pole = surface.find_entities_filtered({type = 'electric-pole', area = {{-32, -32}, {32, 32}}})[1]
    if power_pole then
        power_pole.connect_neighbour(substation)
    end
end

-- @param entity_name string name of the entity to create
-- @param position LuaPosition position to create the entity at
-- @param number amount of solar panels to create (default 1)
function energy_surface.create_entity(entity_name, amount, position)
    local surface = energy_surface.init()
    for i = 1, amount or 1 do
        surface.create_entity({name = entity_name, position = position, force = game.forces['player']})
    end
end

--- Spawns a storage chest that will input its contents into the energy surface
-- @param LuaSurface surface
-- @param LuaPosition the position of the chest
-- @return boolean if the chest was created
function energy_surface.spawn_input_chest(surface, position)
    if not surface or not position then return false end
    local chest = surface.create_entity({name = 'logistic-chest-storage', position = position, force = game.forces['player']})
    if not chest then return false end
    chest.set_filter(1, 'solar-panel')
    rendering.draw_text({
        text = 'Energy surface input',
        surface = surface,
        target = chest,
        target_offset = {0, -1.5},
        color = {r = 1, g = 1, b = 1},
        scale = 1,
        font = 'default-game',
        alignment = 'center',
        scale_with_zoom = false
    })
    chest.minable = false
    energy_surface.inputs[chest.unit_number] = chest
end



-- Init the energy surface on player creation
Event.add(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    if not player or event.player_index ~= 1 then return end

    energy_surface.init()
end)

Event.on_nth_tick(60, function()
    local surface = energy_surface.init()
    if not surface then return end

    for _, chest in pairs(energy_surface.inputs) do
        if not chest or chest.valid ~= true then 
            energy_surface.inputs[chest.unit_number] = nil
            goto continue
        end

        -- Loop over entities in the chest and add them to the energy surface
        for entity_name, properties in pairs(energy_entities) do
            local count = chest.get_item_count(entity_name)
            if count > 0 then
                chest.remove_item({name = entity_name, count = count})
                energy_surface.create_entity(entity_name, count, properties.position)
            end
        end
        ::continue::
    end
end)

return energy_surface