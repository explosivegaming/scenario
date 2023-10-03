--- Adds a virtual layer to store power to save space.
-- @addon Virtual Layer

local Global = require 'utils.global' --- @dep utils.global
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.vlayer' --- @dep config.vlayer

local vlayer = {}
Global.register(vlayer, function(tbl)
    vlayer = tbl
end)

vlayer.entity = {}
vlayer.entity.power = {}
vlayer.entity.storage = {}
vlayer.entity.storage.input = {}
vlayer.entity.circuit = {}

vlayer.storage = {}
vlayer.storage.item = {}
vlayer.storage.item_w = {}

vlayer.circuit = {}
vlayer.circuit.item = {}
vlayer.circuit.signal = {}

vlayer.power = {}
vlayer.power.energy = 0

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

if config.init_item then
    for k, v in pairs(config.init_item) do
        if v.enabled then
            vlayer.storage.item[k] = v

            if v.circuit then
                vlayer.circuit.item[k] = 0
            end
        end
    end
end

if config.land.enabled then
    vlayer.storage.item[config.land.tile] = 0
end

for k, _ in pairs(vlayer.storage.item) do
    vlayer.storage.item_w[k] = 0
end

vlayer.circuit.signal['signal-P'] = 0
vlayer.circuit.signal['signal-S'] = 0
vlayer.circuit.signal['signal-M'] = 0
vlayer.circuit.signal['signal-C'] = 0
vlayer.circuit.signal['signal-D'] = 0
vlayer.circuit.signal['signal-T'] = 0
vlayer.circuit.signal['signal-L'] = 0
vlayer.circuit.signal['signal-A'] = 0
vlayer.circuit.signal['signal-B'] = 0

local function vlayer_storage_input_handle()
    for k, v in pairs(vlayer.entity.storage.input) do
        if v == nil then
            vlayer.entity.storage.input[k] = nil

        elseif not v.valid then
            vlayer.entity.storage.input[k] = nil

        else
            local chest = v.get_inventory(defines.inventory.chest)

            for name, count in pairs(chest.get_contents()) do
                if vlayer.storage.item[name] then
                    vlayer.storage.item_w[name] = vlayer.storage.item_w[name] + count
                    chest.remove({name=name, count=count})

                elseif config.init_item_m[name] then
                    vlayer.storage.item_w[config.init_item_m[name].n] = vlayer.storage.item_w[config.init_item_m[name].n] + (count * config.init_item_m[name].m)
                end
            end
        end
    end
end

local function vlayer_storage_handle()
    if config.land.enabled then
        vlayer.storage.item[config.land.tile] = vlayer.storage.item[config.land.tile] + (vlayer.storage.item_w[config.land.tile] * config.land.result)
        vlayer.storage.item_w[config.land.tile] = 0

        local land_req = (vlayer.storage.item_w['solar-panel'] * config.land.requirement['solar-panel']) + (vlayer.storage.item_w['accumulator'] * config.land.requirement['accumulator'])
        local land_surplus = vlayer.storage.item[config.land.tile] - land_req

        if (vlayer.storage.item_w['solar-panel'] > 0) and (vlayer.storage.item_w['accumulator'] > 0) then
            local allocation = math.floor(land_surplus / (config.land.requirement['solar-panel'] + config.land.requirement['accumulator']))
            local s = math.min(vlayer.storage.item_w['solar-panel'], allocation)
            local a = math.min(vlayer.storage.item_w['accumulator'], allocation)
            vlayer.storage.item['solar-panel'] = vlayer.storage.item['solar-panel'] + s
            vlayer.storage.item['accumulator'] = vlayer.storage.item['accumulator'] + a
            vlayer.storage.item_w['solar-panel'] = vlayer.storage.item_w['solar-panel'] - s
            vlayer.storage.item_w['accumulator'] = vlayer.storage.item_w['accumulator'] - a
            vlayer.storage.item[config.land.tile] = land_surplus - (s * config.land.requirement['solar-panel']) - (a * config.land.requirement['accumulator'])

        elseif (vlayer.storage.item_w['solar-panel'] > 0 and vlayer.storage.item_w['accumulator'] == 0) then
            local allocation = math.floor(land_surplus / config.land.requirement['solar-panel'])
            local s = math.min(vlayer.storage.item_w['solar-panel'], allocation)
            vlayer.storage.item['solar-panel'] = vlayer.storage.item['solar-panel'] + s
            vlayer.storage.item_w['solar-panel'] = vlayer.storage.item_w['solar-panel'] - s
            vlayer.storage.item[config.land.tile] = land_surplus - (s * config.land.requirement['solar-panel'])

        else
            local allocation = math.floor(land_surplus / config.land.requirement['accumulator'])
            local a = math.min(vlayer.storage.item_w['accumulator'], allocation)
            vlayer.storage.item['accumulator'] = vlayer.storage.item['accumulator'] + a
            vlayer.storage.item_w['accumulator'] = vlayer.storage.item_w['accumulator'] - a
            vlayer.storage.item[config.land.tile] = land_surplus - (a * config.land.requirement['accumulator'])
        end
    else
        for k, v in pairs(vlayer.storage.item_w) do
            vlayer.storage.item[k] = vlayer.storage.item[k] + v
            vlayer.storage.item_w[k] = 0
        end
    end
end

local function vlayer_circuit_handle()
    vlayer.circuit.signal['signal-P'] = math.floor(vlayer.storage.item['solar-panel'] * 0.06 * game.surfaces['nauvis'].solar_power_multiplier)
    vlayer.circuit.signal['signal-S'] = math.floor(vlayer.storage.item['solar-panel'] * 873 * game.surfaces['nauvis'].solar_power_multiplier / 20800)
    vlayer.circuit.signal['signal-M'] = vlayer.storage.item['accumulator'] * 5
    vlayer.circuit.signal['signal-C'] = math.floor(vlayer.power.energy / 1000000)
    vlayer.circuit.signal['signal-D'] = math.floor(game.tick / 25000)
    vlayer.circuit.signal['signal-T'] = game.tick % 25000
    vlayer.circuit.signal['signal-A'] = vlayer.storage.item_w['solar-panel']
    vlayer.circuit.signal['signal-B'] = vlayer.storage.item_w['accumulator']

    if config.land.enabled then
        vlayer.circuit.signal['signal-L'] = (vlayer.storage.item[config.land.tile] * config.land.result) - (vlayer.storage.item['solar-panel'] * config.land.requirement['solar-panel']) - (vlayer.storage.item['accumulator'] * config.land.requirement['accumulator'])
    end

    for k, _ in pairs(vlayer.circuit.item) do
        vlayer.circuit.item[k] = vlayer.storage.item[k]
    end

    for k, v in pairs(vlayer.entity.circuit) do
        if v == nil then
            vlayer.entity.circuit[k] = nil

        elseif not v.valid then
            vlayer.entity.circuit[k] = nil

        else
            local circuit_o = v.get_or_create_control_behavior()
            local count = 1

            for kc, vc in pairs(vlayer.circuit.signal) do
                circuit_o.set_signal(count, {signal={type='virtual', name=kc}, count=vc})
                count = count + 1
            end

            for kc, vc in pairs(vlayer.circuit.item) do
                circuit_o.set_signal(count, {signal={type='item', name=kc}, count=vc})
                count = count + 1
            end
        end
    end
end

local function vlayer_power_handle()
    if config.always_day or game.surfaces['nauvis'].always_day then
        vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * game.surfaces['nauvis'].solar_power_multiplier)

    else
        local tick = game.tick % 25000

        if tick <= 5000 or tick > 17500 then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * game.surfaces['nauvis'].solar_power_multiplier)

        elseif tick <= 10000 then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * game.surfaces['nauvis'].solar_power_multiplier * (1 - ((tick - 5000) / 5000)))

        elseif (tick > 12500) and (tick <= 17500) then
            vlayer.power.energy = vlayer.power.energy + math.floor(vlayer.storage.item['solar-panel'] * 60000 / config.update_tick * game.surfaces['nauvis'].solar_power_multiplier * ((tick - 5000) / 5000))
        end
    end

    -- 5 MJ each, a part is stored as vlayer energy, so to share energy to other stuff
    local vlayer_power_capacity_total = math.floor(vlayer.storage.item['accumulator'] * 5000000)
    local vlayer_power_capacity = math.ceil(vlayer_power_capacity_total / math.max(#vlayer.entity.power, 1))

    for k, v in pairs(vlayer.entity.power) do
        if v == nil then
            vlayer.entity.power[k] = nil

        elseif not v.valid then
            vlayer.entity.power[k] = nil

        else
            v.electric_buffer_size = vlayer_power_capacity
            v.power_production = math.floor(vlayer_power_capacity / 60)
            v.power_usage = math.floor(vlayer_power_capacity / 60)

            if v.energy < vlayer_power_capacity then
                local power = math.min(vlayer_power_capacity - v.energy, vlayer.power.energy)
                v.energy = v.energy + power
                vlayer.power.energy = vlayer.power.energy - power
            end
        end
    end

    if config.battery_limit then
        if vlayer.power.energy > vlayer_power_capacity_total then
            vlayer.power.energy = vlayer_power_capacity_total
        end
    end
end

Event.on_nth_tick(config.update_tick, function(_)
    vlayer_storage_input_handle()
    vlayer_storage_handle()
    vlayer_circuit_handle()
    vlayer_power_handle()
end)

return vlayer
