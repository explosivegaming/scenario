local Roles = require 'expcore.roles' --- @dep expcore.roles
local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.personal-logistic' --- @dep config.bonuses

local function pl(player, amount)
    local stats = player.force.item_production_statistics
    local start = config.start
    local required = config.production_required
    local c = player.clear_personal_logistic_slot
    local s = player.set_personal_logistic_slot
    
    for i = start, 200 do
        c(i)
    end;

    if amount == 0 then
        return
    else
        amount = amount / 10
    end

    -- belt
    if stats.get_input_count('express-transport-belt') >= required then
        s(start + 21, {min = 500 * amount, max = 500 * amount, name = 'express-transport-belt'})
        s(start + 22, {min = 150 * amount, max = 150 * amount, name = 'express-underground-belt'})
        s(start + 23, {min = 100 * amount, max = 100 * amount, name = 'express-splitter'})
        s(start + 11, {min = 500 * amount, max = 500 * amount, name = 'fast-transport-belt'})
        s(start + 12, {min = 150 * amount, max = 150 * amount, name = 'fast-underground-belt'})
        s(start + 13, {min = 100 * amount, max = 100 * amount, name = 'fast-splitter'})
        s(start + 1, {min = 0, max = 0, name = 'transport-belt'})
        s(start + 2, {min = 0, max = 0, name = 'underground-belt'})
        s(start + 3, {min = 0, max = 0, name = 'splitter'})
    elseif stats.get_input_count('fast-transport-belt') >= required then
        s(start + 21, {min = 0, max = 0, name = 'express-transport-belt'})
        s(start + 22, {min = 0, max = 0, name = 'express-underground-belt'})
        s(start + 23, {min = 0, max = 0, name = 'express-splitter'})
        s(start + 11, {min = 500 * amount, max = 500 * amount, name = 'fast-transport-belt'})
        s(start + 12, {min = 150 * amount, max = 150 * amount, name = 'fast-underground-belt'})
        s(start + 13, {min = 100 * amount, max = 100 * amount, name = 'fast-splitter'})
        s(start + 1, {min = 500 * amount, max = 500 * amount, name = 'transport-belt'})
        s(start + 2, {min = 150 * amount, max = 150 * amount, name = 'underground-belt'})
        s(start + 3, {min = 100 * amount, max = 100 * amount, name = 'splitter'})
    elseif stats.get_input_count('transport-belt') >= required then
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
end

Commands.new_command('personal-logistic', 'Set Personal Logistic')
:add_param('amount', 'integer-range', 0, 10)
:add_alias('pl')
:register(function(player, amount)
    pl(player, amount)
    return Commands.success
end)
