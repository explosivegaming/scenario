local Roles = require 'expcore.roles' --- @dep expcore.roles
local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.personal-logistic' --- @dep config.personal-logistic

local function pl(player, amount)
    local stats = player.force.item_production_statistics
    local start = config.start
    local required = config.production_required
    local c = player.clear_personal_logistic_slot
    local s = player.set_personal_logistic_slot
    
    for i = start, 200 + start do
        c(i)
    end;

    if amount == 0 then
        return
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
        s(start + 21, {min = 0, max = 0, name = 'express-transport-belt'})
        s(start + 22, {min = 0, max = 0, name = 'express-underground-belt'})
        s(start + 23, {min = 0, max = 0, name = 'express-splitter'})
        s(start + 11, {min = 500 * amount, max = 500 * amount, name = 'fast-transport-belt'})
        s(start + 12, {min = 150 * amount, max = 150 * amount, name = 'fast-underground-belt'})
        s(start + 13, {min = 100 * amount, max = 100 * amount, name = 'fast-splitter'})
        s(start + 1, {min = 500 * amount, max = 500 * amount, name = 'transport-belt'})
        s(start + 2, {min = 150 * amount, max = 150 * amount, name = 'underground-belt'})
        s(start + 3, {min = 100 * amount, max = 100 * amount, name = 'splitter'})
    else
        s(start + 21, {min = 0, max = 0, name = 'express-transport-belt'})
        s(start + 22, {min = 0, max = 0, name = 'express-underground-belt'})
        s(start + 23, {min = 0, max = 0, name = 'express-splitter'})
        s(start + 11, {min = 0, max = 0, name = 'fast-transport-belt'})
        s(start + 12, {min = 0, max = 0, name = 'fast-underground-belt'})
        s(start + 13, {min = 0, max = 0, name = 'fast-splitter'})
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
    elseif stats.get_input_count('assembling-machine-2') >= required.machine then
        s(start + 17, {min = 0, max = 0, name = 'assembling-machine-1'})
        s(start + 18, {min = 50 * amount, max = 50 * amount, name = 'assembling-machine-2'})
        s(start + 19, {min = 0, max = 50 * amount, name = 'assembling-machine-3'}) 
    else
        s(start + 17, {min = 0, max = 50 * amount, name = 'assembling-machine-1'})
        s(start + 18, {min = 0, max = 50 * amount, name = 'assembling-machine-2'})
        s(start + 19, {min = 0, max = 50 * amount, name = 'assembling-machine-3'}) 
    end

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
        s(start + 40, {min = 0, max = 0, name = 'landfill'})
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

end

Commands.new_command('personal-logistic', 'Set Personal Logistic')
:add_param('amount', 'integer-range', 0, 10)
:add_alias('pl')
:register(function(player, amount)
    pl(player, amount)
    return Commands.success
end)
