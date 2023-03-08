--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.vlayer

local vlayer = {}
Global.register(vlayer, function(tbl)
    vlayer = tbl
end)

vlayer.storage = {}
vlayer.storage.item = {}
vlayer.storage.input = {}
vlayer.power = {}
vlayer.power.entity = {}
vlayer.power.energy = 0
vlayer.power.circuit = {}

vlayer.storage.item['solar-panel'] = 0
vlayer.storage.item['accumulator'] = 0

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
]]

Event.on_nth_tick(config.update_tick, function()
    -- storage handle
    for k, v in pairs(vlayer.storage.input) do
        if ((v.storage == nil) or (not v.storage.valid)) then
            vlayer.storage.input[k] = nil
        else
            local chest = v.storage.get_inventory(defines.inventory.chest)

            for item_name, count in pairs(chest.get_contents()) do
                if (vlayer.storage.item[item_name] ~= nil) then
                    vlayer.storage.item[item_name] = vlayer.storage.item[item_name] + count
                    chest.remove({name=item_name, count=count})
                end
            end
        end
    end

    -- power handle
    local vlayer_power_capacity_total = math.floor(((vlayer.storage.item['accumulator'] * 5000000) + (config.energy_base_limit * #vlayer.power.entity)) / 2)
    local vlayer_power_capacity = math.floor(vlayer_power_capacity_total / #vlayer.power.entity)

    if config.always_day or game.players[1].surface.always_day then
        vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick)
    else
        local tick = game.tick % 25000

        if tick <= 5000 or tick > 17500 then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick)
    
        elseif tick <= 10000 then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * (1 - ((tick - 5000) / 5000)))
    
        elseif (tick > 12500) and (tick <= 17500) then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * ((tick - 5000) / 5000))
        end
    end

    if config.battery_limit then
        if vlayer.power.energy > vlayer_power_capacity_total then
            vlayer.power.energy = vlayer_power_capacity_total
        end
    end

    for k, v in pairs(vlayer.power.entity) do
        if (v.power == nil) or (not v.power.valid)then
            vlayer.power.entity[k] = nil
        else
            v.power.electric_buffer_size = vlayer_power_capacity
            v.power.power_production = math.floor(vlayer_power_capacity / 60)
            v.power.power_usage = math.floor(vlayer_power_capacity / 60)

            if vlayer.power.energy < vlayer_power_capacity then
                v.power.energy = math.floor((v.power.energy + vlayer.power.energy) / 2)
                vlayer.power.energy = v.power.energy
            elseif v.power.energy < vlayer_power_capacity then
                local energy_change = vlayer_power_capacity - v.power.energy

                if energy_change < vlayer.power.energy then
                    v.power.energy = v.power.energy + energy_change
                    vlayer.power.energy = vlayer.power.energy - energy_change
                else
                    v.power.energy = v.power.energy + vlayer.power.energy
                    vlayer.power.energy = 0
                end
            end
        end
    end

    -- circuit handle
    for k, v in pairs(vlayer.power.circuit) do
        if (v.input == nil) or (v.output == nil) or (not v.input.valid) or (not v.output.valid) then
            vlayer.power.circuit[k] = nil
        else
            local circuit_i = v.input.get_or_create_control_behavior()
            circuit_i.set_signal(1, {signal={type='virtual', name='signal-P'}, count=1})
            circuit_i.set_signal(2, {signal={type='virtual', name='signal-S'}, count=1})
            circuit_i.set_signal(3, {signal={type='virtual', name='signal-M'}, count=1})
            circuit_i.set_signal(4, {signal={type='virtual', name='signal-C'}, count=1})
            circuit_i.set_signal(5, {signal={type='virtual', name='signal-D'}, count=1})
            circuit_i.set_signal(6, {signal={type='virtual', name='signal-T'}, count=1})
            circuit_i.set_signal(7, {signal={type='item', name='solar-panel'}, count=1})
            circuit_i.set_signal(8, {signal={type='item', name='accumulator'}, count=1})

            local circuit_o = v.output.get_or_create_control_behavior()
            circuit_o.set_signal(1, {signal={type='virtual', name='signal-P'}, count=(math.floor(vlayer.storage.item['solar-panel'] * 0.06) % 1000000000)})
            circuit_o.set_signal(2, {signal={type='virtual', name='signal-S'}, count=(math.floor(vlayer.storage.item['solar-panel'] * 873 / 20800) % 1000000000)})
            circuit_o.set_signal(3, {signal={type='virtual', name='signal-M'}, count=((vlayer.storage.item['accumulator'] * 5) % 1000000000)})
            circuit_o.set_signal(4, {signal={type='virtual', name='signal-C'}, count=(math.floor(vlayer.power.energy / 1000000) % 1000000000)})
            circuit_o.set_signal(5, {signal={type='virtual', name='signal-D'}, count=(math.floor(game.tick / 25000))})
            circuit_o.set_signal(6, {signal={type='virtual', name='signal-T'}, count=(game.tick % 25000)})
            circuit_o.set_signal(7, {signal={type='item', name='solar-panel'}, count=(vlayer.storage.item['solar-panel'] % 1000000000)})
            circuit_o.set_signal(8, {signal={type='item', name='accumulator'}, count=(vlayer.storage.item['accumulator'] % 1000000000)})
        end
    end
end)

return vlayer
