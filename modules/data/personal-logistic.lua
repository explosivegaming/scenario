local Roles = require 'expcore.roles' --- @dep expcore.roles
local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.personal-logistic' --- @dep config.personal-logistic

--[[
Command 2: 
add filter based of inventory

Command 3:
add filter of those not in inventory: all 0

game.item_prototypes
]]

local function pl(player, amount)
    local stats = player.force.item_production_statistics
    local start = config.start
    local required = config.production_required
    local c = player.clear_personal_logistic_slot
    local s = player.set_personal_logistic_slot
    
    for i = start + 1, start + 220 do
        c(i)
    end;

    if amount == 0 then
        return nil
    else
        amount = amount / 10
    end

    -- belt
    if stats.get_input_count('express-transport-belt') >= required.belt then
        s(start + 21, {min = 500 * amount, max = 500 * amount, name = 'express-transport-belt'})
        s(start + 22, {min = 150 * amount, max = 150 * amount, name = 'express-underground-belt'})
        s(start + 23, {min = 100 * amount, max = 100 * amount, name = 'express-splitter'})
        s(start + 11, {min = 500 * amount, max = 500 * amount, name = 'fast-transport-belt'})
        s(start + 12, {min = 150 * amount, max = 150 * amount, name = 'fast-underground-belt'})
        s(start + 13, {min = 100 * amount, max = 100 * amount, name = 'fast-splitter'})
        s(start + 1, {min = 0, max = 0, name = 'transport-belt'})
        s(start + 2, {min = 0, max = 0, name = 'underground-belt'})
        s(start + 3, {min = 0, max = 0, name = 'splitter'})
    elseif stats.get_input_count('fast-transport-belt') >= required.belt then
        s(start + 21, {min = 0, max = 500 * amount, name = 'express-transport-belt'})
        s(start + 22, {min = 0, max = 150 * amount, name = 'express-underground-belt'})
        s(start + 23, {min = 0, max = 100 * amount, name = 'express-splitter'})
        s(start + 11, {min = 500 * amount, max = 500 * amount, name = 'fast-transport-belt'})
        s(start + 12, {min = 150 * amount, max = 150 * amount, name = 'fast-underground-belt'})
        s(start + 13, {min = 100 * amount, max = 100 * amount, name = 'fast-splitter'})
        s(start + 1, {min = 500 * amount, max = 500 * amount, name = 'transport-belt'})
        s(start + 2, {min = 150 * amount, max = 150 * amount, name = 'underground-belt'})
        s(start + 3, {min = 100 * amount, max = 100 * amount, name = 'splitter'})
    else
        s(start + 21, {min = 0, max = 500 * amount, name = 'express-transport-belt'})
        s(start + 22, {min = 0, max = 150 * amount, name = 'express-underground-belt'})
        s(start + 23, {min = 0, max = 100 * amount, name = 'express-splitter'})
        s(start + 11, {min = 0, max = 500 * amount, name = 'fast-transport-belt'})
        s(start + 12, {min = 0, max = 150 * amount, name = 'fast-underground-belt'})
        s(start + 13, {min = 0, max = 100 * amount, name = 'fast-splitter'})
        s(start + 1, {min = 500 * amount, max = 500 * amount, name = 'transport-belt'})
        s(start + 2, {min = 150 * amount, max = 150 * amount, name = 'underground-belt'})
        s(start + 3, {min = 100 * amount, max = 100 * amount, name = 'splitter'})
    end

    -- power
    if stats.get_input_count('solar-panel') >= required.power then
        s(start + 4, {min = 50 * amount, max = 50 * amount, name = 'solar-panel'})
        s(start + 5, {min = 50 * amount, max = 50 * amount, name = 'accumulator'})
        s(start + 6, {min = 0, max = 0, name = 'boiler'})
        s(start + 7, {min = 0, max = 0, name = 'steam-engine'})
    else
        s(start + 4, {min = 0, max = 50 * amount, name = 'solar-panel'})
        s(start + 5, {min = 0, max = 50 * amount, name = 'accumulator'})
        s(start + 6, {min = 0, max = 0, name = 'boiler'})
        s(start + 7, {min = 0, max = 0, name = 'steam-engine'})
    end

    -- miner
    if stats.get_input_count('electric-mining-drill') >= required.miner then
        s(start + 8, {min = 0, max = 0, name = 'burner-mining-drill'})
        s(start + 9, {min = 250 * amount, max = 250 * amount, name = 'electric-mining-drill'})
        s(start + 10, {min = 20 * amount, max = 20 * amount, name = 'pumpjack'})
    else
        s(start + 8, {min = 0, max = 50 * amount, name = 'burner-mining-drill'})
        s(start + 9, {min = 0, max = 250 * amount, name = 'electric-mining-drill'})
        s(start + 10, {min = 0, max = 20 * amount, name = 'pumpjack'})
    end

    -- furnace
    if stats.get_input_count('electric-furnace') >= required.furnace then
        s(start + 14, {min = 0, max = 0, name = 'stone-furnace'})
        s(start + 15, {min = 0, max = 0, name = 'steel-furnace'})
        s(start + 16, {min = 50 * amount, max = 50 * amount, name = 'electric-furnace'})
    elseif stats.get_input_count('steel-furnace') >= required.furnace then
        s(start + 14, {min = 0, max = 0, name = 'stone-furnace'})
        s(start + 15, {min = 50 * amount, max = 50 * amount, name = 'steel-furnace'})
        s(start + 16, {min = 0, max = 50 * amount, name = 'electric-furnace'})   
    else
        s(start + 14, {min = 0, max = 50 * amount, name = 'stone-furnace'})
        s(start + 15, {min = 0, max = 50 * amount, name = 'steel-furnace'})
        s(start + 16, {min = 0, max = 50 * amount, name = 'electric-furnace'})   
    end

    -- machine
    if stats.get_input_count('assembling-machine-3') >= required.machine then
        s(start + 17, {min = 0, max = 0, name = 'assembling-machine-1'})
        s(start + 18, {min = 0, max = 0, name = 'assembling-machine-2'})
        s(start + 19, {min = 50 * amount, max = 50 * amount, name = 'assembling-machine-3'})
        s(start + 24, {min = 10 * amount, max = 10 * amount, name = 'oil-refinery'})
        s(start + 25, {min = 10 * amount, max = 10 * amount, name = 'chemical-plant'})
    elseif stats.get_input_count('assembling-machine-2') >= required.machine then
        s(start + 17, {min = 0, max = 0, name = 'assembling-machine-1'})
        s(start + 18, {min = 50 * amount, max = 50 * amount, name = 'assembling-machine-2'})
        s(start + 19, {min = 0, max = 50 * amount, name = 'assembling-machine-3'}) 
        s(start + 24, {min = 10 * amount, max = 10 * amount, name = 'oil-refinery'})
        s(start + 25, {min = 10 * amount, max = 10 * amount, name = 'chemical-plant'})
    else
        s(start + 17, {min = 0, max = 50 * amount, name = 'assembling-machine-1'})
        s(start + 18, {min = 0, max = 50 * amount, name = 'assembling-machine-2'})
        s(start + 19, {min = 0, max = 50 * amount, name = 'assembling-machine-3'})
        s(start + 24, {min = 0, max = 10 * amount, name = 'oil-refinery'})
        s(start + 25, {min = 0, max = 10 * amount, name = 'chemical-plant'})
    end

    s(start + 26, {min = 0, max = 0, name = 'centrifuge'})
    s(start + 27, {min = 0, max = 0, name = 'lab'})
    s(start + 20, {min = 0, max = 0, name = 'nuclear-reactor'})
    s(start + 28, {min = 0, max = 0, name = 'heat-pipe'})
    s(start + 29, {min = 0, max = 0, name = 'heat-exchanger'})
    s(start + 30, {min = 0, max = 0, name = 'steam-turbine'})
    s(start + 60, {min = 0, max = 0, name = 'rocket-silo'})

    -- pole
    if stats.get_input_count('substation') >= required.pole then
        s(start + 31, {min = 50 * amount, max = 50 * amount, name = 'substation'})
        s(start + 32, {min = 100 * amount, max = 100 * amount, name = 'big-electric-pole'})
        s(start + 33, {min = 100 * amount, max = 100 * amount, name = 'medium-electric-pole'})
        s(start + 34, {min = 0, max = 0, name = 'small-electric-pole'})
    elseif stats.get_input_count('medium-electric-pole') >= required.pole then
        s(start + 31, {min = 0, max = 0, name = 'substation'})
        s(start + 32, {min = 100 * amount, max = 100 * amount, name = 'big-electric-pole'})
        s(start + 33, {min = 100 * amount, max = 100 * amount, name = 'medium-electric-pole'})
        s(start + 34, {min = 0, max = 0, name = 'small-electric-pole'})
    else
        s(start + 31, {min = 0, max = 0, name = 'substation'})
        s(start + 32, {min = 0, max = 0, name = 'big-electric-pole'})
        s(start + 33, {min = 0, max = 0, name = 'medium-electric-pole'})
        s(start + 34, {min = 100 * amount, max = 100 * amount, name = 'small-electric-pole'})
    end

    -- bot
    if stats.get_input_count('construction-robot') >= required.bot then
        s(start + 35, {min = 20 * amount, max = 20 * amount, name = 'roboport'})
        s(start + 36, {min = 50 * amount, max = 50 * amount, name = 'construction-robot'})
        s(start + 37, {min = 0, max = 0, name = 'logistic-robot'})
        s(start + 38, {min = 60 * amount, max = 60 * amount, name = 'cliff-explosives'})
        s(start + 39, {min = 100 * amount, max = 100 * amount, name = 'repair-pack'})
        s(start + 40, {min = 500 * amount, max = 500 * amount, name = 'landfill'})
    else
        s(start + 35, {min = 0, max = 0, name = 'roboport'})
        s(start + 36, {min = 0, max = 50 * amount, name = 'construction-robot'})
        s(start + 37, {min = 0, max = 0, name = 'logistic-robot'})
        s(start + 38, {min = 60 * amount, max = 60 * amount, name = 'cliff-explosives'})
        s(start + 39, {min = 0, max = 100 * amount, name = 'repair-pack'})
        s(start + 40, {min = 0, max = 500 * amount, name = 'landfill'})
    end

    -- inserter
    if stats.get_input_count('stack-inserter') >= required.inserter then
        s(start + 41, {min = 0, max = 0, name = 'burner-inserter'})
        s(start + 42, {min = 0, max = 0, name = 'inserter'})
        s(start + 43, {min = 50 * amount, max = 50 * amount, name = 'long-handed-inserter'})
        s(start + 44, {min = 100 * amount, max = 100 * amount, name = 'fast-inserter'})
        s(start + 45, {min = 50 * amount, max = 50 * amount, name = 'filter-inserter'})
        s(start + 46, {min = 100 * amount, max = 100 * amount, name = 'stack-inserter'})
        s(start + 47, {min = 50 * amount, max = 50 * amount, name = 'stack-filter-inserter'})
    elseif stats.get_input_count('fast-inserter') >= required.inserter then
        s(start + 41, {min = 0, max = 0, name = 'burner-inserter'})
        s(start + 42, {min = 0, max = 0, name = 'inserter'})
        s(start + 43, {min = 50 * amount, max = 50 * amount, name = 'long-handed-inserter'})
        s(start + 44, {min = 100 * amount, max = 100 * amount, name = 'fast-inserter'})
        s(start + 45, {min = 50 * amount, max = 50 * amount, name = 'filter-inserter'})
        s(start + 46, {min = 0, max = 0, name = 'stack-inserter'})
        s(start + 47, {min = 0, max = 0, name = 'stack-filter-inserter'})
    else
        s(start + 41, {min = 0, max = 50, name = 'burner-inserter'})
        s(start + 42, {min = 50, max = 50, name = 'inserter'})
        s(start + 43, {min = 50 * amount, max = 50 * amount, name = 'long-handed-inserter'})
        s(start + 44, {min = 0, max = 0, name = 'fast-inserter'})
        s(start + 45, {min = 0, max = 0, name = 'filter-inserter'})
        s(start + 46, {min = 0, max = 0, name = 'stack-inserter'})
        s(start + 47, {min = 0, max = 0, name = 'stack-filter-inserter'})
    end

    -- pipe
    s(start + 48, {min = 100 * amount, max = 100 * amount, name = 'pipe'})
    s(start + 49, {min = 100 * amount, max = 100 * amount, name = 'pipe-to-ground'})
    s(start + 50, {min = 50 * amount, max = 50 * amount, name = 'pump'})
    s(start + 59, {min = 50 * amount, max = 50 * amount, name = 'storage-tank'})

    -- Chest
    if stats.get_input_count('logistic-chest-requester') >= required.chest then
        s(start + 51, {min = 0, max = 0, name = 'wooden-chest'})
        s(start + 52, {min = 0, max = 0, name = 'iron-chest'})
        s(start + 53, {min = 50 * amount, max = 50 * amount, name = 'steel-chest'})
        s(start + 54, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-passive-provider'})
        s(start + 55, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-storage'})
        s(start + 56, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-requester'})
        s(start + 57, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-buffer'})
        s(start + 58, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-active-provider'})
    elseif stats.get_input_count('logistic-chest-passive-provider') >= required.chest then
        s(start + 51, {min = 0, max = 0, name = 'wooden-chest'})
        s(start + 52, {min = 0, max = 0, name = 'iron-chest'})
        s(start + 53, {min = 50 * amount, max = 50 * amount, name = 'steel-chest'})
        s(start + 54, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-passive-provider'})
        s(start + 55, {min = 50 * amount, max = 50 * amount, name = 'logistic-chest-storage'})
        s(start + 56, {min = 0, max = 0, name = 'logistic-chest-requester'})
        s(start + 57, {min = 0, max = 0, name = 'logistic-chest-buffer'})
        s(start + 58, {min = 0, max = 0, name = 'logistic-chest-active-provider'})
    else
        s(start + 51, {min = 0, max = 50 * amount, name = 'wooden-chest'})
        s(start + 52, {min = 0, max = 50 * amount, name = 'iron-chest'})
        s(start + 53, {min = 50 * amount, max = 50 * amount, name = 'steel-chest'})
        s(start + 54, {min = 0, max = 0, name = 'logistic-chest-passive-provider'})
        s(start + 55, {min = 0, max = 0, name = 'logistic-chest-storage'})
        s(start + 56, {min = 0, max = 0, name = 'logistic-chest-requester'})
        s(start + 57, {min = 0, max = 0, name = 'logistic-chest-buffer'})
        s(start + 58, {min = 0, max = 0, name = 'logistic-chest-active-provider'})
    end

    -- Train
    if stats.get_input_count('rail') >= required.rail then
        s(start + 61, {min = 1000 * amount, max = 1000 * amount, name = 'rail'})
        s(start + 62, {min = 10 * amount, max = 10 * amount, name = 'train-stop'})
        s(start + 63, {min = 100 * amount, max = 100 * amount, name = 'rail-signal'})
        s(start + 64, {min = 100 * amount, max = 100 * amount, name = 'rail-chain-signal'})
        s(start + 65, {min = 5 * amount, max = 5 * amount, name = 'locomotive'})
        s(start + 66, {min = 10 * amount, max = 10 * amount, name = 'cargo-wagon'})
        s(start + 67, {min = 5 * amount, max = 5 * amount, name = 'fluid-wagon'})
        s(start + 68, {min = 0, max = 0, name = 'artillery-wagon'})
    else
        s(start + 61, {min = 0, max = 0, name = 'rail'})
        s(start + 62, {min = 0, max = 0, name = 'train-stop'})
        s(start + 63, {min = 0, max = 0, name = 'rail-signal'})
        s(start + 64, {min = 0, max = 0, name = 'rail-chain-signal'})
        s(start + 65, {min = 0, max = 0, name = 'locomotive'})
        s(start + 66, {min = 0, max = 0, name = 'cargo-wagon'})
        s(start + 67, {min = 0, max = 0, name = 'fluid-wagon'})
        s(start + 68, {min = 0, max = 0, name = 'artillery-wagon'})
    end

    s(start + 71, {min = 50 * amount, max = 50 * amount, name = 'constant-combinator'})
    s(start + 72, {min = 50 * amount, max = 50 * amount, name = 'arithmetic-combinator'})
    s(start + 73, {min = 50 * amount, max = 50 * amount, name = 'decider-combinator'})
    s(start + 74, {min = 100 * amount, max = 100 * amount, name = 'small-lamp'})
    s(start + 75, {min = 200 * amount, max = 200 * amount, name = 'red-wire'})
    s(start + 76, {min = 200 * amount, max = 200 * amount, name = 'green-wire'})
    s(start + 77, {min = 200 * amount, max = 200 * amount, name = 'copper-cable'})
    s(start + 78, {min = 50 * amount, max = 50 * amount, name = 'power-switch'})
    s(start + 79, {min = 50 * amount, max = 50 * amount, name = 'programmable-speaker'})
    s(start + 80, {min = 20 * amount, max = 20 * amount, name = 'offshore-pump'})

    -- Module
    if stats.get_input_count('speed-module-3') >= required.mod then
        s(start + 81, {min = 40 * amount, max = 40 * amount, name = 'beacon'})
        s(start + 82, {min = 250 * amount, max = 250 * amount, name = 'speed-module'})
        s(start + 83, {min = 0, max = 0, name = 'speed-module-2'})
        s(start + 84, {min = 250 * amount, max = 250 * amount, name = 'speed-module-3'})
        s(start + 85, {min = 0, max = 0, name = 'productivity-module'})
        s(start + 86, {min = 0, max = 0, name = 'productivity-module-2'})
        s(start + 87, {min = 150 * amount, max = 150 * amount, name = 'productivity-module-3'})
        s(start + 88, {min = 0, max = 0, name = 'effectivity-module'})
        s(start + 89, {min = 0, max = 0, name = 'effectivity-module-2'})
        s(start + 90, {min = 50 * amount, max = 50 * amount, name = 'effectivity-module-3'})
    elseif stats.get_input_count('speed-module-2') >= required.mod then
        s(start + 81, {min = 40 * amount, max = 40 * amount, name = 'beacon'})
        s(start + 82, {min = 250 * amount, max = 250 * amount, name = 'speed-module'})
        s(start + 83, {min = 0, max = 50 * amount, name = 'speed-module-2'})
        s(start + 84, {min = 0, max = 250 * amount, name = 'speed-module-3'})
        s(start + 85, {min = 0, max = 0, name = 'productivity-module'})
        s(start + 86, {min = 0, max = 0, name = 'productivity-module-2'})
        s(start + 87, {min = 0, max = 150 * amount, name = 'productivity-module-3'})
        s(start + 88, {min = 0, max = 0, name = 'effectivity-module'})
        s(start + 89, {min = 0, max = 50 * amount, name = 'effectivity-module-2'})
        s(start + 90, {min = 0, max = 50 * amount, name = 'effectivity-module-3'})
    else
        s(start + 81, {min = 40 * amount, max = 40 * amount, name = 'beacon'})
        s(start + 82, {min = 250 * amount, max = 250 * amount, name = 'speed-module'})
        s(start + 83, {min = 0, max = 50 * amount, name = 'speed-module-2'})
        s(start + 84, {min = 0, max = 250 * amount, name = 'speed-module-3'})
        s(start + 85, {min = 150 * amount, max = 150 * amount, name = 'productivity-module'})
        s(start + 86, {min = 0, max = 0, name = 'productivity-module-2'})
        s(start + 87, {min = 0, max = 150 * amount, name = 'productivity-module-3'})
        s(start + 88, {min = 150 * amount, max = 150 * amount, name = 'effectivity-module'})
        s(start + 89, {min = 0, max = 50 * amount, name = 'effectivity-module-2'})
        s(start + 90, {min = 0, max = 50 * amount, name = 'effectivity-module-3'})
    end

    -- Defense
    if stats.get_input_count('laser-turret') >= required.defense then
        s(start + 91, {min = 100 * amount, max = 100 * amount, name = 'stone-wall'})
        s(start + 92, {min = 50 * amount, max = 50 * amount, name = 'gate'})
        s(start + 93, {min = 0, max = 0, name = 'gun-turret'})
        s(start + 94, {min = 100 * amount, max = 100 * amount, name = 'laser-turret'})
        s(start + 95, {min = 0, max = 0, name = 'flamethrower-turret'})
        s(start + 96, {min = 0, max = 0, name = 'artillery-turret'})
    else
        s(start + 91, {min = 100 * amount, max = 100 * amount, name = 'stone-wall'})
        s(start + 92, {min = 50 * amount, max = 50 * amount, name = 'gate'})
        s(start + 93, {min = 0, max = 100 * amount, name = 'gun-turret'})
        s(start + 94, {min = 0, max = 100 * amount, name = 'laser-turret'})
        s(start + 95, {min = 0, max = 0, name = 'flamethrower-turret'})
        s(start + 96, {min = 0, max = 0, name = 'artillery-turret'})
    end

    -- Rocket
    if stats.get_input_count('atomic-bomb') >= required.rocket then
        s(start + 101, {min = 0, max = 0, name = 'rocket'})
        s(start + 102, {min = 0, max = 0, name = 'explosive-rocket'})
        s(start + 103, {min = 100 * amount, max = 100 * amount, name = 'atomic-bomb'})
        s(start + 104, {min = 1, max = 1, name = 'rocket-launcher'})
        s(start + 105, {min = 1, max = 1, name = 'flamethrower'})
        s(start + 106, {min = 0, max = 0, name = 'pistol'})
        s(start + 107, {min = 0, max = 0, name = 'submachine-gun'})
        s(start + 108, {min = 0, max = 0, name = 'shotgun'})
        s(start + 109, {min = 0, max = 0, name = 'combat-shotgun'})
        s(start + 110, {min = 0, max = 0, name = 'land-mine'})
    elseif stats.get_input_count('explosive-rocket') >= required.rocket then
        s(start + 101, {min = 0, max = 0, name = 'rocket'})
        s(start + 102, {min = 2000 * amount, max = 2000 * amount, name = 'explosive-rocket'})
        s(start + 103, {min = 0, max = 100 * amount, name = 'atomic-bomb'})
        s(start + 104, {min = 1, max = 1, name = 'rocket-launcher'})
        s(start + 105, {min = 1, max = 1, name = 'flamethrower'})
        s(start + 106, {min = 0, max = 0, name = 'pistol'})
        s(start + 107, {min = 0, max = 0, name = 'submachine-gun'})
        s(start + 108, {min = 0, max = 0, name = 'shotgun'})
        s(start + 109, {min = 0, max = 0, name = 'combat-shotgun'})
        s(start + 110, {min = 0, max = 0, name = 'land-mine'})
    else
        s(start + 101, {min = 0, max = 0, name = 'rocket'})
        s(start + 102, {min = 0, max = 2000 * amount, name = 'explosive-rocket'})
        s(start + 103, {min = 0, max = 100 * amount, name = 'atomic-bomb'})
        s(start + 104, {min = 0, max = 1, name = 'rocket-launcher'})
        s(start + 105, {min = 0, max = 1, name = 'flamethrower'})
        s(start + 106, {min = 0, max = 0, name = 'pistol'})
        s(start + 107, {min = 0, max = 1, name = 'submachine-gun'})
        s(start + 108, {min = 0, max = 0, name = 'shotgun'})
        s(start + 109, {min = 0, max = 0, name = 'combat-shotgun'})
        s(start + 110, {min = 0, max = 0, name = 'land-mine'})
    end

    -- Ammo
    if stats.get_input_count('uranium-rounds-magazine') >= required.ammo then
        s(start + 111, {min = 0, max = 0, name = 'firearm-magazine'})
        s(start + 112, {min = 0, max = 0, name = 'piercing-rounds-magazine'})
        s(start + 113, {min = 0, max = 0, name = 'uranium-rounds-magazine'})
        s(start + 114, {min = 100 * amount, max = 100 * amount, name = 'flamethrower-ammo'})
        s(start + 115, {min = 0, max = 0, name = 'shotgun-shell'})
        s(start + 116, {min = 0, max = 0, name = 'piercing-shotgun-shell'})
        s(start + 117, {min = 0, max = 0, name = 'cannon-shell'})
        s(start + 118, {min = 0, max = 0, name = 'explosive-cannon-shell'})
        s(start + 119, {min = 0, max = 0, name = 'uranium-cannon-shell'})
        s(start + 120, {min = 0, max = 0, name = 'explosive-uranium-cannon-shell'})
    else
        s(start + 111, {min = 0, max = 0, name = 'firearm-magazine'})
        s(start + 112, {min = 0, max = 1000 * amount, name = 'piercing-rounds-magazine'})
        s(start + 113, {min = 0, max = 0, name = 'uranium-rounds-magazine'})
        s(start + 114, {min = 100 * amount, max = 100 * amount, name = 'flamethrower-ammo'})
        s(start + 115, {min = 0, max = 0, name = 'shotgun-shell'})
        s(start + 116, {min = 0, max = 0, name = 'piercing-shotgun-shell'})
        s(start + 117, {min = 0, max = 0, name = 'cannon-shell'})
        s(start + 118, {min = 0, max = 0, name = 'explosive-cannon-shell'})
        s(start + 119, {min = 0, max = 0, name = 'uranium-cannon-shell'})
        s(start + 120, {min = 0, max = 0, name = 'explosive-uranium-cannon-shell'})
    end

    s(start + 121, {min = 0, max = 0, name = 'artillery-shell'})
    s(start + 122, {min = 0, max = 0, name = 'poison-capsule'})
    s(start + 123, {min = 0, max = 0, name = 'slowdown-capsule'})
    s(start + 124, {min = 0, max = 0, name = 'defender-capsule'})
    s(start + 125, {min = 0, max = 0, name = 'distractor-capsule'})
    s(start + 126, {min = 0, max = 0, name = 'destroyer-capsule'})
    s(start + 127, {min = 0, max = 0, name = 'car'})
    s(start + 128, {min = 0, max = 0, name = 'tank'})
    s(start + 129, {min = 0, max = 0, name = 'spidertron'})
    s(start + 130, {min = 0, max = 0, name = 'spidertron-remote'})

    if stats.get_input_count('cluster-grenade') >= required.ammo then
        s(start + 97, {min = 0, max = 0, name = 'grenade'})
        s(start + 98, {min = 0, max = 0, name = 'cluster-grenade'})
    else
        s(start + 97, {min = 0, max = 100 * amount, name = 'grenade'})
        s(start + 98, {min = 0, max = 0, name = 'cluster-grenade'})
    end

    s(start + 99, {min = 50 * amount, max = 50 * amount, name = 'radar'})

    -- Armor
    if stats.get_input_count('power-armor-mk2') >= required.armor then
        s(start + 131, {min = 0, max = 0, name = 'light-armor'})
        s(start + 132, {min = 0, max = 0, name = 'heavy-armor'})
        s(start + 133, {min = 0, max = 0, name = 'modular-armor'})
        s(start + 134, {min = 0, max = 0, name = 'power-armor'})
        s(start + 135, {min = 1, max = 1, name = 'power-armor-mk2'})
    elseif stats.get_input_count('power-armor') >= required.armor then
        s(start + 131, {min = 0, max = 0, name = 'light-armor'})
        s(start + 132, {min = 0, max = 0, name = 'heavy-armor'})
        s(start + 133, {min = 0, max = 0, name = 'modular-armor'})
        s(start + 134, {min = 1, max = 1, name = 'power-armor'})
        s(start + 135, {min = 0, max = 1, name = 'power-armor-mk2'})
    elseif stats.get_input_count('modular-armor') >= required.armor then
        s(start + 131, {min = 0, max = 0, name = 'light-armor'})
        s(start + 132, {min = 0, max = 0, name = 'heavy-armor'})
        s(start + 133, {min = 1, max = 1, name = 'modular-armor'})
        s(start + 134, {min = 0, max = 1, name = 'power-armor'})
        s(start + 135, {min = 0, max = 1, name = 'power-armor-mk2'})
    else
        s(start + 131, {min = 0, max = 0, name = 'light-armor'})
        s(start + 132, {min = 0, max = 0, name = 'heavy-armor'})
        s(start + 133, {min = 0, max = 1, name = 'modular-armor'})
        s(start + 134, {min = 0, max = 1, name = 'power-armor'})
        s(start + 135, {min = 0, max = 1, name = 'power-armor-mk2'})
    end

    -- Armor Equipment
    if stats.get_input_count('fusion-reactor-equipment') >= required.armor_equipment then
        s(start + 136, {min = 0, max = 6, name = 'fusion-reactor-equipment'})
        s(start + 137, {min = 0, max = 0, name = 'solar-panel-equipment'})
    else
        s(start + 136, {min = 0, max = 6, name = 'fusion-reactor-equipment'})
        s(start + 137, {min = 0, max = 20, name = 'solar-panel-equipment'})
    end

    if stats.get_input_count('battery-mk2-equipment') >= required.armor_equipment then
        s(start + 138, {min = 0, max = 0, name = 'battery-equipment'})
        s(start + 139, {min = 0, max = 4, name = 'battery-mk2-equipment'})
    else
        s(start + 138, {min = 0, max = 4, name = 'battery-equipment'})
        s(start + 139, {min = 0, max = 4, name = 'battery-mk2-equipment'})
    end

    s(start + 140, {min = 0, max = 2, name = 'exoskeleton-equipment'})

    if stats.get_input_count('personal-roboport-mk2-equipment') >= required.armor_equipment then
        s(start + 141, {min = 0, max = 0, name = 'personal-roboport-equipment'})
        s(start + 142, {min = 0, max = 2, name = 'personal-roboport-mk2-equipment'})
    else
        s(start + 141, {min = 0, max = 2, name = 'personal-roboport-equipment'})
        s(start + 142, {min = 0, max = 2, name = 'personal-roboport-mk2-equipment'})
    end

    if stats.get_input_count('energy-shield-mk2-equipment') >= required.armor_equipment then
        s(start + 143, {min = 0, max = 0, name = 'energy-shield-equipment'})
        s(start + 144, {min = 0, max = 4, name = 'energy-shield-mk2-equipment'})
    else
        s(start + 143, {min = 0, max = 4, name = 'energy-shield-equipment'})
        s(start + 144, {min = 0, max = 4, name = 'energy-shield-mk2-equipment'})
    end

    s(start + 145, {min = 0, max = 1, name = 'belt-immunity-equipment'})
    s(start + 146, {min = 0, max = 1, name = 'night-vision-equipment'})
    s(start + 147, {min = 0, max = 10, name = 'personal-laser-defense-equipment'})
    s(start + 148, {min = 0, max = 0, name = 'discharge-defense-equipment'})
    s(start + 149, {min = 0, max = 0, name = 'discharge-defense-remote'})
    s(start + 150, {min = 1, max = 1, name = 'artillery-targeting-remote'})

    -- Path
    s(start + 151, {min = 0, max = 0, name = 'stone-brick'})
    s(start + 152, {min = 0, max = 0, name = 'concrete'})
    s(start + 153, {min = 0, max = 0, name = 'hazard-concrete'})
    s(start + 154, {min = 0, max = 0, name = 'refined-concrete'})
    s(start + 155, {min = 0, max = 0, name = 'refined-hazard-concrete'})

    -- Ore
    s(start + 161, {min = 0, max = 0, name = 'wood'})
    s(start + 162, {min = 0, max = 0, name = 'coal'})
    s(start + 163, {min = 0, max = 0, name = 'stone'})
    s(start + 164, {min = 0, max = 0, name = 'iron-ore'})
    s(start + 165, {min = 0, max = 0, name = 'copper-ore'})
    s(start + 166, {min = 0, max = 0, name = 'uranium-ore'})
    s(start + 167, {min = 0, max = 0, name = 'raw-fish'})
    s(start + 168, {min = 0, max = 0, name = 'iron-stick'})
    s(start + 169, {min = 0, max = 0, name = 'iron-gear-wheel'})
    s(start + 170, {min = 0, max = 0, name = 'satellite'})

    -- Barrel
    s(start + 171, {min = 0, max = 0, name = 'crude-oil-barrel'})
    s(start + 172, {min = 0, max = 0, name = 'heavy-oil-barrel'})
    s(start + 173, {min = 0, max = 0, name = 'light-oil-barrel'})
    s(start + 174, {min = 0, max = 0, name = 'lubricant-barrel'})
    s(start + 175, {min = 0, max = 0, name = 'petroleum-gas-barrel'})
    s(start + 176, {min = 0, max = 0, name = 'sulfuric-acid-barrel'})
    s(start + 177, {min = 0, max = 0, name = 'water-barrel'})
    s(start + 178, {min = 0, max = 0, name = 'empty-barrel'})
    s(start + 179, {min = 0, max = 0, name = 'uranium-fuel-cell'})
    s(start + 180, {min = 0, max = 0, name = 'used-up-uranium-fuel-cell'})

    -- Science and Circuit
    s(start + 181, {min = 0, max = 0, name = 'automation-science-pack'})
    s(start + 182, {min = 0, max = 0, name = 'logistic-science-pack'})
    s(start + 183, {min = 0, max = 0, name = 'military-science-pack'})
    s(start + 184, {min = 0, max = 0, name = 'chemical-science-pack'})
    s(start + 185, {min = 0, max = 0, name = 'production-science-pack'})
    s(start + 186, {min = 0, max = 0, name = 'utility-science-pack'})
    s(start + 187, {min = 0, max = 0, name = 'space-science-pack'})
    s(start + 188, {min = 0, max = 0, name = 'electronic-circuit'})
    s(start + 189, {min = 0, max = 0, name = 'advanced-circuit'})
    s(start + 190, {min = 0, max = 0, name = 'processing-unit'})

    -- Intermediate
    s(start + 191, {min = 0, max = 0, name = 'iron-plate'})
    s(start + 192, {min = 0, max = 0, name = 'copper-plate'})
    s(start + 193, {min = 0, max = 0, name = 'steel-plate'})
    s(start + 194, {min = 0, max = 0, name = 'plastic-bar'})
    s(start + 195, {min = 0, max = 0, name = 'sulfur'})
    s(start + 196, {min = 0, max = 0, name = 'battery'})
    s(start + 197, {min = 0, max = 0, name = 'explosives'})

    s(start + 201, {min = 0, max = 0, name = 'engine-unit'})
    s(start + 202, {min = 0, max = 0, name = 'electric-engine-unit'})
    s(start + 203, {min = 0, max = 0, name = 'flying-robot-frame'})
    s(start + 204, {min = 0, max = 0, name = 'rocket-control-unit'})
    s(start + 205, {min = 0, max = 0, name = 'low-density-structure'})
    s(start + 206, {min = 0, max = 0, name = 'solid-fuel'})
    s(start + 207, {min = 10, max = 10, name = 'rocket-fuel'})
    s(start + 208, {min = 2, max = 2, name = 'nuclear-fuel'})
    s(start + 209, {min = 0, max = 0, name = 'uranium-235'})
    s(start + 210, {min = 0, max = 0, name = 'uranium-238'})
   
end

Commands.new_command('personal-logistic', 'Set Personal Logistic')
:add_param('amount', 'integer-range', 0, 10)
:add_alias('pl')
:register(function(player, amount)
    pl(player, amount)
    return Commands.success
end)
