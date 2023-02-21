--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.advanced_start
local Global = require 'utils.global' --- @dep utils.global

--[[
TODO
unit of energy is kJ

signal-P Power Production Peak
solar x 60 kW

signal-S Power Production Sustained
solar x 4365 / 104 kW

signal-M Battery Max
accu x 5 MJ

signal-C
accu level
]]

if not config.enabled then
    return
end

function vlayer_power_input_handle()
    global.phi.vlayer.power.energy_history = global.phi.vlayer.power.energy

    for k, v in pairs(global.phi.vlayer.power.input) do
        if (v.power == nil) or (not v.power.valid) or (v.circuit == nil) or (not v.circuit.valid) then
            global.phi.vlayer.power.input[k] = nil
        
        -- 1 000 000
        -- 1 MJ
        elseif (v.power.energy > (1000000)) then
            local circuit_signal = v.circuit.get_or_create_control_behavior().get_signal(1)
                
            if ((circuit_signal ~= nil) and (circuit_signal.signal ~= nil) and (circuit_signal.signal.name == "signal-C")) then
                -- circuit is in MJ, divided by 60 ups (updated in 5)
                v.power.power_usage = math.min(v.power.energy - (1000000), math.floor(circuit_signal.count * 250000 / 3, global.phi.vlayer.power.limit.input))
            else
                v.power.power_usage = math.min(v.power.energy - (1000000), 0, global.phi.vlayer.power.limit.input)
            end

            global.phi.vlayer.power.energy = global.phi.vlayer.power.energy + v.power.power_usage

        else
            v.power.power_usage = 0
        end
    end
end

function vlayer_power_storage_handle()
    --[[
    25,000 / 416 s
    昼      208秒	ソーラー効率100%
    夕方	83秒	1秒ごとにソーラー発電量が約1.2%ずつ下がり、やがて0%になる
    夜	    41秒	ソーラー発電量が0%になる
    朝方	83秒	1秒ごとにソーラー発電量が約1.2%ずつ上がり、やがて100%になる
    
    0.75    Day     12,500  208s
    0.25    Sunset  5,000   83s
    0.45    Night   2,500   41s
    0.55    Sunrise 5,000   83s

    player.surface.daytime = [0, 1)
    ]]

    local tick = 0
    local solar_eff = 0

    if config.always_day then
        tick = 0
        solar_eff = 1
    else
        tick = game.tick % 25000

        if tick <= 5000 or tick > 17500 then
            solar_eff = 1
    
        elseif tick <= 10000 then
            solar_eff = 1 - ((tick - 5000) / 5000)
    
        elseif tick <= 12500 then
            solar_eff = 0
    
        elseif tick <= 17500 then
            solar_eff = (tick - 5000) / 5000
        end
    end

    local new_energy = math.floor(global.phi.vlayer.storage.item['solar-panel'] * 5000 * solar_eff)

    if not config.battery_limit then
        global.phi.vlayer.power.energy = global.phi.vlayer.power.energy + new_energy
    else
        local battery_limit = global.phi.vlayer.storage.item['accumulator'] * 5000000

        if (global.phi.vlayer.power.energy + new_energy) >= battery_limit then
            global.phi.vlayer.power.energy = battery_limit
        else
            global.phi.vlayer.power.energy = global.phi.vlayer.power.energy + new_energy
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
            local circuit_i = v.input.get_or_create_control_behavior()
            circuit_i.set_signal(1, {signal={type="virtual", name="signal-P"}, count=1})
            circuit_i.set_signal(2, {signal={type="virtual", name="signal-S"}, count=1})
            circuit_i.set_signal(3, {signal={type="virtual", name="signal-B"}, count=1})
            circuit_i.set_signal(4, {signal={type="virtual", name="signal-C"}, count=1})
            circuit_i.set_signal(5, {signal={type="virtual", name="signal-T"}, count=1})
            circuit_i.set_signal(6, {signal={type="virtual", name="signal-D"}, count=1})
            circuit_i.set_signal(7, {signal={type="item", name="solar-panel"}, count=1})
            circuit_i.set_signal(8, {signal={type="item", name="accumulator"}, count=1})

            local circuit_o = v.output.get_or_create_control_behavior()
            circuit_o.set_signal(1, {signal={type="virtual", name="signal-P"}, count=math.min(math.floor(global.phi.vlayer.storage.item['solar-panel'] * 60), 2147483647)})
            circuit_o.set_signal(2, {signal={type="virtual", name="signal-S"}, count=math.min(math.floor(global.phi.vlayer.storage.item['solar-panel'] * 4365 / 104), 2147483647)})
            circuit_o.set_signal(3, {signal={type="virtual", name="signal-B"}, count=math.min(math.floor(global.phi.vlayer.storage.item['accumulator'] * 5), 2147483647)})
            circuit_o.set_signal(4, {signal={type="virtual", name="signal-C"}, count=math.min(math.floor(global.phi.vlayer.power.energy), 2147483647)})
            circuit_o.set_signal(5, {signal={type="virtual", name="signal-T"}, count=math.min(math.floor(game.tick), 2147483647)})
            circuit_o.set_signal(6, {signal={type="virtual", name="signal-D"}, count=math.min(math.floor(game.tick % 25000), 2147483647)})
            circuit_o.set_signal(7, {signal={type="item", name="solar-panel"}, count=math.min(math.floor(global.phi.vlayer.storage.item['solar-panel']), 2147483647)})
            circuit_o.set_signal(8, {signal={type="item", name="accumulator"}, count=math.min(math.floor(global.phi.vlayer.storage.item['accumulator']), 2147483647)})

            if circuit_i.signals_count >= 9 then
                for i=9, circuit_i.signals_count do
                    local circuit_input_signal = circuit_i.get_signal(i)
    
                    if ((circuit_input_signal ~= nil) and (circuit_input_signal.signal ~= nil) and (circuit_input_signal.signal.type == "item")) then
                        local item_amount = global.phi.vlayer.storage.item[circuit_signal[i]]

                        if item_amount == nil then 
                            item_amount = 0 
                        end

                        circuit_o.set_signal(i, {signal={type="item", name=circuit_signal[i]}, count=math.min(item_amount, 2147483647)})
                    end
                end
            end
        end
    end
end

function vlayer_handle()
    vlayer_power_input_handle()
    vlayer_power_storage_handle()
    vlayer_power_output_handle()
    vlayer_storage_handle()
    vlayer_circuit_handle()
end

Event.add(defines.events.on_init, function(event)
    global.phi = {}
    global.phi.vlayer = {}
    global.phi.vlayer.storage = {}
    global.phi.vlayer.storage.item = {}
    global.phi.vlayer.storage.item['solar-panel'] = 0
    global.phi.vlayer.storage.item['accumulator'] = 0
    -- global.phi.vlayer.storage.item['landfill'] = 0
    global.phi.vlayer.storage.input = {}
    global.phi.vlayer.power = {}
    global.phi.vlayer.power.limit = {input=0, output=0}
    global.phi.vlayer.power.input = {}
    global.phi.vlayer.power.output = {}
    global.phi.vlayer.power.energy = 0
    global.phi.vlayer.power.energy_history = 0
    global.phi.vlayer.power.circuit = {}
end)

-- Event.add(defines.events.on_tick, function(event)
Event.on_nth_tick(5, function(event)
    vlayer_handle()
end)

