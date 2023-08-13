local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.personal_logistic' --- @dep config.personal-logistic

--[[
Command 2:
add filter based of inventory

Command 3:
add filter of those not in inventory: all 0
game.item_prototypes

Command 4:
Spidertron request
]]

local function pl(player, amount)
    local c = player.clear_personal_logistic_slot

    for k, v in pairs(config.request) do
        c(config.start + v.key)
    end

    if (amount == 0) then
        return
    else
        local stats = player.force.item_production_statistics
        local s = player.set_personal_logistic_slot

        for k, v in pairs(config.request) do
            local v_min = math.ceil(v.min * amount)
            local v_max = math.ceil(v.max * amount)

            if v.stack ~= nil and v.stack ~= 1 and v.type ~= 'weapon' then
                v_min = math.floor(v_min / v.stack) * v.stack
                v_max = math.ceil(v_max / v.stack) * v.stack
            end

            if v.upgrade_of == nil then
                if v.type ~= nil then
                    if stats.get_input_count(k) < config.production_required[v.type] then
                        v_min = 0
                    end
                end

                s(config.start + v.key, {name=k, min=v_min, max=v_max})

            else
                if v.type ~= nil then
                    if stats.get_input_count(k) >= config.production_required[v.type] then
                        s(config.start + v.key, {name=k, min=v_min, max=v_max})
                        local vuo = v.upgrade_of

                        while (vuo ~= nil) do
                            s(config.start + config.request[vuo].key, {name=vuo, min=0, max=0})
                            vuo = config.request[vuo].upgrade_of
                        end
                    else
                        s(config.start + v.key, {name=k, min=0, max=v_max})
                    end
                end
            end
        end
    end
end

Commands.new_command('personal-logistic', 'Set Personal Logistic (0 to cancel all)')
:add_param('amount', 'integer-range', 0, 10)
:add_alias('pl')
:register(function(player, amount)
    if player.force.technologies['logistic-robotics'].researched then
        pl(player, amount / 10)
        return Commands.success
    else
        player.print('Player logistic not researched')
    end
end)
