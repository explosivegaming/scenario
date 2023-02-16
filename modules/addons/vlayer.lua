--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.advanced_start

--[[
TODO
signal-P Power Production Peak 
solar x 60 kW

signal-S Power Production Sustained
solar x 4365 / 104 kW
]]

if not config.enabled then
    return
end

function vlayer_convert_chest(player)
    local entities = player.surface.find_entities_filtered{position=player.position, radius=16, name="steel-chest", force=player.force}
    
    if (not entities or (#entities == 0)) then 
        return nil
    end
        
    local target_chest = player.surface.get_closest(player.position, entities)

    if (not target_chest) then
        player.print("No Steel Chest Detected")
        return nil
    end

    if (not target_chest.get_inventory(defines.inventory.chest).is_empty()) then
        player.print("Chest is not emptied")
        return nil
    end

    local pos = target_chest.position

    if (not target_chest.destroy()) then
        player.print("Unable to convert chest")
        return nil
    end

    return {x=math.floor(pos.x),y=math.floor(pos.y)}
end

function vlayer_convert_chest_storage_input(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        local vlayer_storage = player.surface.create_entity{name="logistic-chest-storage", position={pos.x, pos.y}, force="neutral"}
        vlayer_storage.destructible = false
        vlayer_storage.minable = false
        vlayer_storage.last_user = player
    
        table.insert(global.phi.vlayer.storage.input, {type="INPUT", storage=vlayer_storage})
        return true
    end

    return false
end

function vlayer_convert_chest_power_input(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        if (player.surface.can_place_entity{name="electric-energy-interface", position=pos}) and 
            (player.surface.can_place_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}}) then
                local vlayer_power = player.surface.create_entity{name="electric-energy-interface", position=pos, force="neutral"}
                vlayer_power.destructible = false
                vlayer_power.minable = false
                vlayer_power.operable = false
                vlayer_power.last_user = player
                vlayer_power.electric_buffer_size = global.phi.vlayer.power.limit.input
                vlayer_power.power_production = 0
                vlayer_power.power_usage = 0
                vlayer_power.energy = 0
            
                local vlayer_circuit = player.surface.create_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}, force="neutral"}
                vlayer_circuit.destructible = false
                vlayer_circuit.minable = false
                vlayer_circuit.operable = true
                vlayer_circuit.last_user = player
                vlayer_circuit.get_or_create_control_behavior().set_signal(1, {signal={type="virtual", name="signal-M"}, count=1})
            
                table.insert(global.phi.vlayer.power.input, {power=vlayer_power, circuit=vlayer_circuit})
            return true

        else
            player.print("Unable to build energy input")
        end
    end

    return false
end

function vlayer_convert_chest_power_output(player)
    local pos = vlayer_convert_chest(player)

    if (pos) then
        if (player.surface.can_place_entity{name="electric-energy-interface", position=pos}) and 
            (player.surface.can_place_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}}) then
                local vlayer_power = player.surface.create_entity{name="electric-energy-interface", position=pos, force="neutral"}
                vlayer_power.destructible = false
                vlayer_power.minable = false
                vlayer_power.operable = false
                vlayer_power.last_user = player
                vlayer_power.electric_buffer_size = global.phi.vlayer.power.limit.output
                vlayer_power.power_production = 0
                vlayer_power.power_usage = 0
                vlayer_power.energy = 0
            
                local vlayer_circuit = player.surface.create_entity{name="constant-combinator", position={x=pos.x+1, y=pos.y}, force="neutral"}
                vlayer_circuit.destructible = false
                vlayer_circuit.minable = false
                vlayer_circuit.operable = false
                vlayer_circuit.last_user = player
            
                table.insert(global.phi.vlayer.power.output, {power=vlayer_power, circuit=vlayer_circuit})
            return true

        else
            player.print("Unable to build energy output")
        end
    end

    return false
end

function vlayer_circuit(player, pos_i, pos_o)
    local circuit_i = player.surface.create_entity{name="constant-combinator", position=pos_i, force="neutral"}
    circuit_i.destructible = false
    circuit_i.minable = false
    circuit_i.last_user = player
    circuit_i.get_or_create_control_behavior().set_signal(1, {signal={type="item", name="solar-panel"}, count=1})

    local circuit_o = player.surface.create_entity{name="constant-combinator", position=pos_o, force="neutral"}
    circuit_o.destructible = false
    circuit_o.minable = false
    circuit_o.operable = false
    circuit_o.last_user = player

    table.insert(global.phi.vlayer.power.circuit, {input=circuit_i, output=circuit_o})
end

function vlayer_convert_undo(player)
    local entities = player.surface.find_entities_filtered{name={"electric-energy-interface", "constant-combinator", "logistic-chest-storage"}, position=player.position, radius=16, force={"neutral"}}

    if (#entities == 0) then
        player.print("Entity not found")
        return
    end

    local entity = player.surface.get_closest(player.position, entities)

    if (entity) then
        -- entity.last_user can also be used
        if (player.admin) then
            --[[
            local name = entity.name

            if (name == "electric-energy-interface") then
                if (entity.electric_buffer_size == global.phi.vlayer.power.limit.input) then
                    -- global.phi.vlayer.power.energy = global.phi.vlayer.power.energy + 0
                else
            ]]
            
            entity.destroy()
            player.print("Entity removed")

        else
            player.print("You are not allowed to remove the enity")
        end

    else
        player.print("Entity not found")
    end
end

function vlayer_power_input_handle()
    global.phi.vlayer.power.energy_history = global.phi.vlayer.power.energy

    for k, v in pairs(global.phi.vlayer.power.input) do
        if (v.power == nil) or (not v.power.valid) or (bv.circuit == nil) or (not v.circuit.valid) then
            global.phi.vlayer.power.input[k] = nil
        
        -- 1 000 000
        -- 1 MJ
        elseif (v.power.energy > (1000000)) then
            local circuit_signal = v.circuit.get_or_create_control_behavior().get_signal(1)
                
            if ((circuit_signal ~= nil) and (circuit_signal.signal ~= nil) and (circuit_signal.signal.name == "signal-M")) then
                -- circuit is in MJ, divided by 60 ups
                v.power.power_usage = math.min(b.power.energy - (1000000), math.floor(circuit_signal.count * 50000 / 3, global.phi.vlayer.power.limit.input))
            else
                v.power.power_usage = math.min(b.power.energy - (1000000), 0, global.phi.vlayer.power.limit.input)
            end

            global.phi.vlayer.power.energy = global.phi.vlayer.power.energy + v.power.power_usage

        else
            v.power.power_usage = 0
        end
    end
end

function vlayer_power_output_handle()
    local energy_available = math.floor(global.phi.vlayer.power.energy / (#global.phi.vlayer.power.output))

    for k, v in pairs(global.phi.vlayer.power.output) do
        if (v.power == nil) or (not v.power.valid) or (v.circuit == nil) or (not v.circuit.valid) then
            global.phi.vlayer.power.output[k] = nil
        
        else
            if (v.power.energy < (global.phi.vlayer.power.limit.output)) then
                local power_output_space = global.phi.vlayer.power.limit.output - v.power.energy
                v.power.power_production = math.min(power_output_space, energy_available)
                global.phi.vlayer.power.energy = global.phi.vlayer.power.energy - v.power.power_production
            
            else
                v.power.power_production = 0
            end

            v.circuit.get_or_create_control_behavior().set_signal(1, {signal={type="virtual", name="signal-M"}, count=math.min(math.floor(global.phi.vlayer.power.energy/1000000), 2147483647)})
        end
    end
end

function vlayer_storage_handle()
    for k, v in pairs(global.phi.vlayer.storage.input) do
        local chest = v.entity

        if ((chest == nil) or (not chest.valid)) then
            global.phi.vlayer.storage.input[k] = nil
        
        elseif (chest_info.type == "INPUT") then
            chest = chest.get_inventory(defines.inventory.chest)

            if (chest == nil) then 
                return 
            elseif (chest.is_empty()) then 
                return 
            end
        
            local chest_content = chest.get_contents()
            local item_handle_status = false

            for item_name, count in pairs(chest_content) do
                if (global.phi.vlayer.storage.item[item_name] ~= nil) then
                    global.phi.vlayer.storage.item[item_name] = global.phi.vlayer.storage.item[item_name] + count
                    item_handle_status = true
                    
                else
                    item_handle_status = false
                end

                if (item_handle_status) then
                    chest_content.remove({name=item_name, count=count})
                end
            end
        end
    end
end


function vlayer_circuit_handle()
    for k, v in pairs(global.phi.vlayer.power.circuit) do
        if (v.input == nil) or (v.output == nil) or (not v.input.valid) or (not v.output.valid) then
            global.phi.vlayer.power.circuit[k] = nil

        else
            local circuit_input = v.input.get_or_create_control_behavior()
            local circuit_signal = {}

            for i=1, circuit_input.signals_count do
                local circuit_input_signal = circuit_input.get_signal(i)

                if ((circuit_input_signal ~= nil) and (circuit_input_signal.signal ~= nil) and (circuit_input_signal.signal.type == "item")) then
                    table.insert(circuit_signal, circuit_input_signal.signal.name)
                end
            end
            
            local circuit_output = v.output.get_or_create_control_behavior()
            
            for i=1, circuit_output.signals_count do
                if (circuit_signal[i] ~= nil) then
                    local item_amount = global.phi.vlayer.storage.item[circuit_signal[i]]

                    if item_amount == nil then 
                        item_amount = 0 
                    end

                    circuit_output.set_signal(i, {signal={type="item", name=circuit_signal[i]}, count=math.min(item_amount, 2147483647)})
                
                else
                    circuit_output.set_signal(i, nil)
                end
            end
        end
    end
end

function vlayer_handle()
    vlayer_power_input_handle()
    vlayer_power_output_handle()

    if ((game.tick % (60)) == 0) then
        vlayer_storage_handle()
        vlayer_circuit_handle()
    end
end

Event.add(defines.events.on_init, function(event)
    global.phi = {}
    global.phi.vlayer = {}
    global.phi.vlayer.storage = {}
    global.phi.vlayer.storage.item = {}
    global.phi.vlayer.storage.item['solar-panel'] = 0
    global.phi.vlayer.storage.item['accumulator'] = 0
    global.phi.vlayer.storage.input = {}
    global.phi.vlayer.power = {}
    global.phi.vlayer.power.limit = {input=0, output=0}
    global.phi.vlayer.power.input = {}
    global.phi.vlayer.power.output = {}
    global.phi.vlayer.power.energy = 0
    global.phi.vlayer.power.energy_history = 0
    global.phi.vlayer.power.circuit = {}
end)

Event.add(defines.events.on_tick, function(event)
    vlayer_handle()
end)
