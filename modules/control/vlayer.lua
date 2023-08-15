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
vlayer.storage.item_m = {}

vlayer.power = {}
vlayer.power.entity = {}
vlayer.power.energy = 0
vlayer.power.circuit = {}

vlayer.circuit = {}
vlayer.circuit.output = {}

for i=1, 11 do
    vlayer.circuit.output[i] = {}
    vlayer.circuit.output[i].count = 0
end

vlayer.circuit.output[1].signal = {type='virtual', name='signal-P'}
vlayer.circuit.output[2].signal = {type='virtual', name='signal-S'}
vlayer.circuit.output[3].signal = {type='virtual', name='signal-M'}
vlayer.circuit.output[4].signal = {type='virtual', name='signal-C'}
vlayer.circuit.output[5].signal = {type='virtual', name='signal-D'}
vlayer.circuit.output[6].signal = {type='virtual', name='signal-T'}
vlayer.circuit.output[7].signal = {type='virtual', name='signal-L'}
vlayer.circuit.output[8].signal = {type='virtual', name='signal-A'}
vlayer.circuit.output[9].signal = {type='virtual', name='signal-B'}
vlayer.circuit.output[10].signal = {type='item', name='solar-panel'}
vlayer.circuit.output[11].signal = {type='item', name='accumulator'}

vlayer.storage.item['solar-panel'] = 0
vlayer.storage.item['accumulator'] = 0

if config.land.enabled then
    vlayer.storage.item[config.land.tile] = 0
    vlayer.storage.item_a = {}
    vlayer.storage.item_a['solar-panel'] = 0
    vlayer.storage.item_a['accumulator'] = 0
end

local vlayer_storage_item = {}

for i=2, 8 do
    vlayer_storage_item['solar-panel-' .. i] = {name='solar-panel', multiplier=4 ^ (i - 1)}
    vlayer_storage_item['accumulator-' .. i] = {name='accumulator', multiplier=4 ^ (i - 1)}
end

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
        if ((v == nil) or (not v.valid)) then
            vlayer.input[k] = nil

        else
            local chest = v.get_inventory(defines.inventory.chest)
            local chest_content = chest.get_contents()

            if config.land.enabled then
                for item_name, count in pairs(chest_content) do
                    if (vlayer.storage.item[item_name] ~= nil) then
                        if item_name == config.land.tile then
                            vlayer.storage.item[item_name] = vlayer.storage.item[item_name] + count
                        else
                            vlayer.storage.item_a[item_name] = vlayer.storage.item_a[item_name] + count
                        end
                        chest.remove({name=item_name, count=count})

                    elseif (vlayer_storage_item[item_name] ~= nil) then
                        vlayer.storage.item_a[vlayer_storage_item[item_name].name] = vlayer.storage.item_a[vlayer_storage_item[item_name].name] + (count * vlayer_storage_item[item_name].multiplier)
                        chest.remove({name=item_name, count=count})
                    end
                end

                local land_req = (vlayer.storage.item['solar-panel'] * config.land.requirement['solar-panel']) + (vlayer.storage.item['accumulator'] * config.land.requirement['accumulator'])
                local land_surplus = (vlayer.storage.item[config.land.tile] * config.land.result) - land_req

                if (vlayer.storage.item_a['solar-panel'] > 0 and vlayer.storage.item_a['accumulator'] > 0) then
                    local land_allocation = math.floor(land_surplus / (config.land.requirement['solar-panel'] + config.land.requirement['accumulator']))
                    vlayer.storage.item['solar-panel'] = vlayer.storage.item['solar-panel'] + math.min(vlayer.storage.item_a['solar-panel'], land_allocation)
                    vlayer.storage.item_a['solar-panel'] = vlayer.storage.item_a['solar-panel'] - math.min(vlayer.storage.item_a['solar-panel'], land_allocation)
                    vlayer.storage.item['accumulator'] = vlayer.storage.item['accumulator'] + math.min(vlayer.storage.item_a['accumulator'], land_allocation)
                    vlayer.storage.item_a['accumulator'] = vlayer.storage.item_a['accumulator'] - math.min(vlayer.storage.item_a['accumulator'], land_allocation)

                elseif (vlayer.storage.item_a['solar-panel'] > 0 and vlayer.storage.item_a['accumulator'] == 0) then
                    local land_allocation = math.floor(land_surplus / config.land.requirement['solar-panel'])
                    vlayer.storage.item['solar-panel'] = vlayer.storage.item['solar-panel'] + math.min(vlayer.storage.item_a['solar-panel'], land_allocation)
                    vlayer.storage.item_a['solar-panel'] = vlayer.storage.item_a['solar-panel'] - math.min(vlayer.storage.item_a['solar-panel'], land_allocation)

                else
                    local land_allocation = math.floor(land_surplus / config.land.requirement['accumulator'])
                    vlayer.storage.item['accumulator'] = vlayer.storage.item['accumulator'] + math.min(vlayer.storage.item_a['accumulator'], land_allocation)
                    vlayer.storage.item_a['accumulator'] = vlayer.storage.item_a['accumulator'] - math.min(vlayer.storage.item_a['accumulator'], land_allocation)
                end

                vlayer.circuit.output[1].count = math.floor(vlayer.storage.item['solar-panel'] * 0.06 * game.surfaces['nauvis'].solar_power_multiplier)
                vlayer.circuit.output[2].count = math.floor(vlayer.storage.item['solar-panel'] * 873 * game.surfaces['nauvis'].solar_power_multiplier / 20800)
                vlayer.circuit.output[3].count = vlayer.storage.item['accumulator'] * 5
                vlayer.circuit.output[7].count = (vlayer.storage.item[config.land.tile] * config.land.result) - (vlayer.storage.item['solar-panel'] * config.land.requirement['solar-panel']) - (vlayer.storage.item['accumulator'] * config.land.requirement['accumulator'])
                vlayer.circuit.output[8].count = vlayer.storage.item_a['solar-panel']
                vlayer.circuit.output[9].count = vlayer.storage.item_a['accumulator']
                vlayer.circuit.output[10].count = vlayer.storage.item['solar-panel']
                vlayer.circuit.output[11].count = vlayer.storage.item['accumulator']

            else
                for item_name, count in pairs(chest_content) do
                    if (vlayer.storage.item[item_name] ~= nil) then
                        vlayer.storage.item[item_name] = vlayer.storage.item[item_name] + count
                        chest.remove({name=item_name, count=count})

                    elseif (vlayer_storage_item[item_name] ~= nil) then
                        vlayer.storage.item[vlayer_storage_item[item_name].name] = vlayer.storage.item[vlayer_storage_item[item_name].name] + (count * vlayer_storage_item[item_name].multiplier)
                        chest.remove({name=item_name, count=count})
                    end
                end

                vlayer.circuit.output[1].count = math.floor(vlayer.storage.item['solar-panel'] * 0.06 * game.surfaces['nauvis'].solar_power_multiplier)
                vlayer.circuit.output[2].count = math.floor(vlayer.storage.item['solar-panel'] * 873 * game.surfaces['nauvis'].solar_power_multiplier / 20800)
                vlayer.circuit.output[3].count = (vlayer.storage.item['accumulator'] * 5) + (config.energy_base_limit / 1000000)
                vlayer.circuit.output[10].count = vlayer.storage.item['solar-panel']
                vlayer.circuit.output[11].count = vlayer.storage.item['accumulator']
            end
        end
    end

    -- power handle
    local vlayer_power_capacity_total = math.floor(((vlayer.storage.item['accumulator'] * 5000000) + (config.energy_base_limit * #vlayer.power.entity)) / 2)
    local vlayer_power_capacity = math.floor(vlayer_power_capacity_total / #vlayer.power.entity)

    if config.always_day or game.surfaces['nauvis'].always_day then
        vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 * game.surfaces['nauvis'].solar_power_multiplier / config.update_tick)

    else
        local tick = game.tick % 25000

        if tick <= 5000 or tick > 17500 then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 * game.surfaces['nauvis'].solar_power_multiplier / config.update_tick)

        elseif tick <= 10000 then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 * game.surfaces['nauvis'].solar_power_multiplier / config.update_tick * (1 - ((tick - 5000) / 5000)))

        elseif (tick > 12500) and (tick <= 17500) then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 * game.surfaces['nauvis'].solar_power_multiplier / config.update_tick * ((tick - 5000) / 5000))
        end
    end

    if config.battery_limit then
        if vlayer.power.energy > vlayer_power_capacity_total then
            vlayer.power.energy = vlayer_power_capacity_total
        end
    end

    for k, v in pairs(vlayer.power.entity) do
        if (v == nil) or (not v.valid)then
            vlayer.power.entity[k] = nil

        else
            v.electric_buffer_size = vlayer_power_capacity
            v.power_production = math.floor(vlayer_power_capacity / 60)
            v.power_usage = math.floor(vlayer_power_capacity / 60)

            if vlayer.power.energy < vlayer_power_capacity then
                v.energy = math.floor((v.energy + vlayer.power.energy) / 2)
                vlayer.power.energy = v.energy

            elseif v.energy < vlayer_power_capacity then
                local energy_change = vlayer_power_capacity - v.energy

                if energy_change < vlayer.power.energy then
                    v.energy = v.energy + energy_change
                    vlayer.power.energy = vlayer.power.energy - energy_change

                else
                    v.energy = v.energy + vlayer.power.energy
                    vlayer.power.energy = 0
                end
            end
        end
    end

    -- circuit handle
    vlayer.circuit.output[4].count = math.floor(vlayer.power.energy / 1000000)
    vlayer.circuit.output[5].count = math.floor(game.tick / 25000)
    vlayer.circuit.output[6].count = game.tick % 25000

    for k, v in pairs(vlayer.power.circuit) do
        if (v == nil) or (not v.valid) then
            vlayer.power.circuit[k] = nil

        else
            local circuit_o = v.get_or_create_control_behavior()

            for i=1, #vlayer.circuit.output do
                circuit_o.set_signal(i, {signal=vlayer.circuit.output[i].signal, count=vlayer.circuit.output[i].count})
            end
        end
    end
end)

return vlayer
