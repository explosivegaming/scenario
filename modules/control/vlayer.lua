--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.vlayer
local move_items_stack = _C.move_items_stack

local mega = 1000000

local vlayer = {}
local vlayer_data = {
    entity_interfaces = {
        energy = {},
        circuit = {},
        storage_input = {},
        storage_output = {}
    },
    properties = {
        total_surface_area = 0,
        used_surface_area = 0,
        production = 0,
        capacity = 0,
    },
    storage = {
        items = {},
        energy = 0,
        unallocated = {}
    },
    surface = {
        always_day = false,
        solar_power_multiplier = 1
    }
}

Global.register(vlayer_data, function(tbl)
    vlayer_data = tbl
end)

-- For all modded items, create a config for them
for item_name, properties in pairs(config.modded_items) do
    local base_properties = config.allowed_items[properties.base_game_equivalent]
    local m = properties.multiplier

    config.allowed_items[item_name] = {
        starting_value = properties.starting_value or 0,
        required_area = base_properties.required_area or 0,
        surface_area = (base_properties.surface_area or 0) * m,
        production = (base_properties.production or 0) * m,
        capacity = (base_properties.capacity or 0) * m,
    }
end

--- Get all items in storage, do not modify
function vlayer.get_items()
    return vlayer_data.storage.items
end

--- Get interface counts
function vlayer.get_interface_counts()
    local interfaces = vlayer_data.entity_interfaces
    return {
        energy = #interfaces.energy,
        circuit = #interfaces.circuit,
        storage_input = #interfaces.storage_input,
        storage_output = #interfaces.storage_output,
    }
end

--[[
    25,000 / 416 s
    昼      208秒	ソーラー効率100%
    夕方    83秒	1秒ごとにソーラー発電量が約1.2%ずつ下がり、やがて0%になる
    夜      41秒	ソーラー発電量が0%になる
    朝方    83秒    1秒ごとにソーラー発電量が約1.2%ずつ上がり、やがて100%になる

    (surface.dawn)      0.75    18750   Day         12,500  208s
                        0.00    0       Noon
    (surface.dusk)      0.25    6250    Sunset      5,000   83s
    (surface.evening)   0.45    11250   Night       2,500   41s
    (surface.morning)   0.55    13750   Sunrise     5,000   83s
]]

--- Get the power multiplier based on the surface time
local function get_time_multiplier()
    if vlayer_data.surface.always_day then
        return 1
    end

    -- TODO maybe link this into vlayer_data.surface
    -- 25000 ticks per day, 0 is noon
    local tick = game.tick % 25000

    if tick <= 6250 then -- Noon to Sunset
        return 1

    elseif tick <= 11250 then -- Sunset to Night
        return 1 - ((tick - 6250) / 5000)

    elseif tick <= 13750 then -- Night to Sunrise
        return 0

    elseif tick <= 18750 then -- Sunrise to Morning
        return (tick - 13750) / 5000

    else -- Morning to Noon
        return 1
    end
end

--- Internal, Allocate items in the vlayer, this will increase the property values of the vlayer such as production and capacity
-- Does not increment item storage, so should not be called before insert_item unless during init
-- Does not validate area requirements, so checks must be performed before calling this function
-- Accepts negative count for deallocating items
function vlayer.allocate_item(item_name, count)
    local item_properties = config.allowed_items[item_name]
    assert(item_properties, 'Item not allowed in vlayer: ' .. tostring(item_name))

    if item_properties.production then
        vlayer_data.properties.production = vlayer_data.properties.production + item_properties.production * count
    end

    if item_properties.capacity then
        vlayer_data.properties.capacity = vlayer_data.properties.capacity + item_properties.capacity * count
    end

    if item_properties.surface_area then
        vlayer_data.properties.total_surface_area = vlayer_data.properties.total_surface_area + item_properties.surface_area * count
    end

    if item_properties.required_area and item_properties.required_area > 0 then
        vlayer_data.properties.used_surface_area = vlayer_data.properties.used_surface_area + item_properties.required_area * count
    end
end

-- For all allowed items, setup their starting values, default 0
for item_name, properties in pairs(config.allowed_items) do
    vlayer_data.storage.items[item_name] = properties.starting_value or 0

    if properties.required_area and properties.required_area > 0 then
        vlayer_data.storage.unallocated[item_name] = 0
    end

    vlayer.allocate_item(item_name, properties.starting_value)
end

--- Insert an item into the vlayer, this will increment its count in storage and allocate it if possible
function vlayer.insert_item(item_name, count)
    local item_properties = config.allowed_items[item_name]
    assert(item_properties, 'Item not allowed in vlayer: ' .. tostring(item_name))
    vlayer_data.storage.items[item_name] = vlayer_data.storage.items[item_name] + count

    if not config.unlimited_surface_area and item_properties.required_area and item_properties.required_area > 0 then
        -- Calculate how many can be allocated
        local surplus_area = vlayer_data.properties.total_surface_area - vlayer_data.properties.used_surface_area
        local allocate_count = math.min(count, math.floor(surplus_area / item_properties.required_area))

        if allocate_count > 0 then
            vlayer.allocate_item(item_name, allocate_count)
        end

        vlayer_data.storage.unallocated[item_name] = vlayer_data.storage.unallocated[item_name] + count - allocate_count

    else
        vlayer.allocate_item(item_name, count)
    end
end

--- Remove an item from the vlayer, this will decrement its count in storage and prioritise unallocated items over deallocation
-- Can not always fulfil the remove request for items which provide surface area, therefore returns the amount actually removed
function vlayer.remove_item(item_name, count)
    local item_properties = config.allowed_items[item_name]
    assert(item_properties, "Item not allowed in vlayer: "..tostring(item_name))

    local remove_unallocated = 0
    if not config.unlimited_surface_area and item_properties.required_area and item_properties.required_area > 0 then
        -- Remove from the unallocated storage first
        remove_unallocated = math.min(count, vlayer_data.storage.unallocated[item_name])

        if remove_unallocated > 0 then
            vlayer_data.storage.items[item_name] = vlayer_data.storage.items[item_name] - count
            vlayer_data.storage.unallocated[item_name] = vlayer_data.storage.unallocated[item_name] - count
        end

        -- Check if any more items need to be removed
        count = count - remove_unallocated
        if count == 0 then
            return remove_unallocated
        end
    end

    -- Calculate the amount to remove based on items in storage
    local remove_count = math.min(count, vlayer_data.storage.items[item_name])

    if item_properties.surface_area and item_properties.surface_area > 0 then
        -- If the item provides surface area then it has additional limitations
        local surplus_area = vlayer_data.properties.total_surface_area - vlayer_data.properties.used_surface_area
        remove_count = math.min(remove_count, math.floor(surplus_area / item_properties.surface_area))

        if remove_count <= 0 then
            return remove_unallocated
        end
    end

    -- Remove the item from allocated storage
    vlayer_data.storage.items[item_name] = vlayer_data.storage.items[item_name] - remove_count
    vlayer.allocate_item(item_name, -remove_count)
    return remove_unallocated + remove_count
end

--- Create a new storage input interface
function vlayer.create_input_interface(surface, pos, last_user)
    local interface = surface.create_entity{name='logistic-chest-storage', position=pos, force='neutral'}
    table.insert(vlayer_data.entity_interfaces.storage_input, interface)

    if last_user then
        interface.last_user = last_user
    end

    interface.destructible = false
    interface.minable = false
    interface.operable = true
end

--- Handle all input interfaces, will take their contents and insert it into the vlayer storage
local function handle_input_interfaces()
    for index, interface in pairs(vlayer_data.entity_interfaces.storage_input) do
        if not interface.valid then
            vlayer_data.entity_interfaces.storage_input[index] = nil

        else
            local inventory = interface.get_inventory(defines.inventory.chest)

            for name, count in pairs(inventory.get_contents()) do
                if config.allowed_items[name] then
                    vlayer.insert_item(name, count)
                    inventory.remove({ name = name, count = count })
                end
            end
        end
    end
end

--- Create a new storage output interface
function vlayer.create_output_interface(surface, pos, last_user)
    local interface = surface.create_entity{name='logistic-chest-requester', position=pos, force='neutral'}
    table.insert(vlayer_data.entity_interfaces.storage_output, interface)

    if last_user then
        interface.last_user = last_user
    end

    interface.destructible = false
    interface.minable = false
    interface.operable = true
end

--- Handle all output interfaces, will take their requests and remove it from the vlayer storage
local function handle_output_interfaces()
    for index, interface in pairs(vlayer_data.entity_interfaces.storage_output) do
        if not interface.valid then
            vlayer_data.entity_interfaces.storage_output[index] = nil

        else
            local inventory = interface.get_inventory(defines.inventory.chest)

            for i = 1, interface.request_slot_count do
                local request = interface.get_request_slot(i)

                if request and config.allowed_items[request.name] then
                    local current_amount = inventory.get_item_count(request.name)
                    local request_amount = math.min(request.count - current_amount, vlayer_data.storage.items[request.name])

                    if request_amount > 0 and inventory.can_insert({ name = request.name, count = request_amount }) then
                        local removed_item_count = vlayer.remove_item(request.name, request_amount)

                        if removed_item_count > 0 then
                            inventory.insert({ name = request.name, count = removed_item_count })
                        end
                    end
                end
            end
        end
    end
end

--- Handle the unallocated items because more surface area may have been added
local function handle_unallocated()
    -- unallocated cant happen when its unlimited
    if config.unlimited_surface_area then
        return
    end

    -- Get the total unallocated area so items can be allocated in equal amounts
    local unallocated_area = 0

    for item_name, count in pairs(vlayer_data.storage.unallocated) do
        local item_properties = config.allowed_items[item_name]
        unallocated_area = unallocated_area + item_properties.required_area * count
    end

    if unallocated_area == 0 then
        return
    end

    -- Allocate items in an equal distribution
    local surplus_area = vlayer_data.properties.total_surface_area - vlayer_data.properties.used_surface_area
    for item_name, count in pairs(vlayer_data.storage.unallocated) do
        local allocation_count = math.min(count, math.floor(count * surplus_area / unallocated_area))

        if allocation_count > 0 then
            vlayer_data.storage.unallocated[item_name] = vlayer_data.storage.unallocated[item_name] - allocation_count
            vlayer.allocate_item(item_name, allocation_count)
        end
    end
end

--- Get the statistics for the vlayer
function vlayer.get_statistics()
    return {
        total_surface_area = vlayer_data.properties.total_surface_area,
        used_surface_area = vlayer_data.properties.used_surface_area,
        energy_production = vlayer_data.properties.production * mega * get_time_multiplier() * vlayer_data.surface.solar_power_multiplier,
        energy_sustained = vlayer_data.properties.production * mega * (vlayer_data.surface.always_day and 1 or 291 / 416) * vlayer_data.surface.solar_power_multiplier,
        energy_capacity = vlayer_data.properties.capacity * mega,
        energy_storage = vlayer_data.storage.energy,
        day = math.floor(game.tick / 25000),
        time = game.tick % 25000,
    }
end

--- Circuit signals used for the statistics
local circuit_signals = {
    total_surface_area = 'signal-A',
    used_surface_area = 'signal-B',
    energy_production = 'signal-P',
    energy_sustained = 'signal-S',
    energy_capacity = 'signal-C',
    energy_storage = 'signal-E',
    day = 'signal-D',
    time = 'signal-T',
}

function vlayer.create_circuit_interface(surface, pos, last_user)
    local interface = surface.create_entity{name='constant-combinator', position=pos, force='neutral'}
    table.insert(vlayer_data.entity_interfaces.circuit, interface)

    if last_user then
        interface.last_user = last_user
    end

    interface.destructible = false
    interface.minable = false
    interface.operable = true
end

--- Handle all circuit interfaces, updating their signals to match the vlayer statistics
local function handle_circuit_interfaces()
    local stats = vlayer.get_statistics()

    for index, interface in pairs(vlayer_data.entity_interfaces.circuit) do
        if not interface.valid then
            vlayer_data.entity_interfaces.circuit[index] = nil

        else
            local circuit_oc = interface.get_or_create_control_behavior()
            local signal_index = 1

            for stat_name, signal_name in pairs(circuit_signals) do
                if stat_name:find('energy') then
                    circuit_oc.set_signal(signal_index, {signal={type='virtual', name=signal_name}, count=math.floor(stats[stat_name] / mega)})

                else
                    circuit_oc.set_signal(signal_index, {signal={type='virtual', name=signal_name}, count=math.floor(stats[stat_name])})
                end

                signal_index = signal_index + 1
            end

            for item_name, count in pairs(vlayer_data.storage.items) do
                if game.item_prototypes[item_name] then
                    circuit_oc.set_signal(signal_index, {signal={type='item', name=item_name}, count=count})
                    signal_index = signal_index + 1
                end
            end
        end
    end
end

--- Create a new energy interface
function vlayer.create_energy_interface(surface, pos, last_user)
    if not surface.can_place_entity{name='electric-energy-interface', position=pos} then
        return false
    end

    local interface = surface.create_entity{name='electric-energy-interface', position=pos, force='neutral'}
    table.insert(vlayer_data.entity_interfaces.energy, interface)

    if last_user then
        interface.last_user = last_user
    end

    interface.destructible = false
    interface.minable = false
    interface.operable = false
    interface.electric_buffer_size = 0
    interface.power_production = 0
    interface.power_usage = 0
    interface.energy = 0

    return true
end

--- Handle all energy interfaces as well as the energy storage
local function handle_energy_interfaces()
    -- Add the newly produced power
    local production = vlayer_data.properties.production * mega * (config.update_tick_energy / 60) * vlayer_data.surface.solar_power_multiplier
    local average_capacity = (vlayer_data.properties.capacity * mega) / #vlayer_data.entity_interfaces.energy
    vlayer_data.storage.energy = vlayer_data.storage.energy + math.floor(production * get_time_multiplier())
    -- Calculate how much power is present in the network, that is storage + all interfaces
    if #vlayer_data.entity_interfaces.energy > 0 then
        local available_energy = vlayer_data.storage.energy

        for index, interface in pairs(vlayer_data.entity_interfaces.energy) do
            if not interface.valid then
                vlayer_data.entity_interfaces.energy[index] = nil

            else
                available_energy = available_energy + interface.energy
            end
        end

        -- Distribute the energy between all interfaces
        local fill_to = math.min(average_capacity, math.floor(available_energy / #vlayer_data.entity_interfaces.energy))

        for index, interface in pairs(vlayer_data.entity_interfaces.energy) do
            interface.electric_buffer_size = average_capacity
            local delta = fill_to - interface.energy -- positive means storage to interface
            vlayer_data.storage.energy = vlayer_data.storage.energy - delta
            interface.energy = interface.energy + delta
        end
    end

    -- Cap the stored energy to the allowed capacity
    if not config.unlimited_capacity and vlayer_data.storage.energy > vlayer_data.properties.capacity * mega then
        vlayer_data.storage.energy = vlayer_data.properties.capacity * mega
    end
end

--- Remove the closest entity interface to the given position
function vlayer.remove_closest_interface(surface, position, radius)
    local entities = surface.find_entities_filtered{
        name = {'logistic-chest-storage', 'logistic-chest-requester', 'constant-combinator', 'electric-energy-interface'},
        force = 'neutral',
        position = position,
        radius = radius,
        limit = 1
    }

    -- Get the details which will be returned
    if #entities == 0 then
        return nil, nil
    end

    local interface = entities[1]
    local name = interface.name
    local pos = interface.position

    -- Return the type of interface removed and do some clean up
    if name == 'logistic-chest-storage' then
        move_items_stack(interface.get_inventory(defines.inventory.chest).get_contents())
        table.remove_element(vlayer_data.entity_interfaces.storage_input, interface)
        interface.destroy()
        return 'storage input', pos

    elseif name == 'logistic-chest-requester' then
        move_items_stack(interface.get_inventory(defines.inventory.chest).get_contents())
        table.remove_element(vlayer_data.entity_interfaces.storage_output, interface)
        interface.destroy()
        return 'storage output', pos

    elseif name == 'constant-combinator' then
        table.remove_element(vlayer_data.entity_interfaces.circuit, interface)
        interface.destroy()
        return 'circuit', pos

    elseif name == 'electric-energy-interface' then
        vlayer_data.storage.energy = vlayer_data.storage.energy + interface.energy
        table.remove_element(vlayer_data.entity_interfaces.energy, interface)
        interface.destroy()
        return 'energy', pos
    end
end

local function update_surface_handle()
    if config.always_day == true then
        vlayer_data.surface.always_day = true

    else
        vlayer_data.surface.always_day = game.surfaces[config.surface_selected].always_day
    end

    if config.solar_power_multiplier ~= 1 then
        vlayer_data.surface.solar_power_multiplier = config.solar_power_multiplier

    else
        vlayer_data.surface.solar_power_multiplier = game.surfaces[config.surface_selected].solar_power_multiplier
    end
end

--- Handle all storage IO and attempt allocation of unallocated items
Event.on_nth_tick(config.update_tick_storage, function(_)
    handle_input_interfaces()
    handle_output_interfaces()
    handle_unallocated()
end)

--- Handle all energy and circuit updates
Event.on_nth_tick(config.update_tick_energy, function(_)
    handle_circuit_interfaces()
    handle_energy_interfaces()
end)

Event.on_nth_tick(config.update_tick_surface, function(_)
    update_surface_handle()
end)

return vlayer
