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
    local stats = player.force.item_production_statistics
    local c = player.clear_personal_logistic_slot
    local s = player.set_personal_logistic_slot
`
    for k, v in pairs(config.request) do
        c(config.start + v.key)

        if (amount >= 0) then
            if v.upgrade_of ~= nil and v.type ~= nil then
                s(config.start + v.key, {min=math.floor(v.min * amount), max=math.floor(v.max * amount), name=k})
    
            else
                if stats.get_input_count(k) >= config.production_required[v.type] then
                    s(config.start + v.key, {min=math.floor(v.min * amount), max=math.floor(v.max * amount), name=k})
    
                    local vuo = v.upgrade_of
    
                    while (vuo ~= nil) do
                        s(config.start + config.request[vuo].key, {min=0, max=0, name=vuo})
                        vuo = config.request[vuo].upgrade_of
                    end
                else
                    s(config.start + v.key, {min=0, max=math.floor(v.max * amount), name=k})
                end
            end
        end
    end
end

Commands.new_command('personal-logistic', 'Set Personal Logistic (-1 to cancel all)')
:add_param('amount', 'integer-range', -1, 10)
:add_alias('pl')
:register(function(player, amount)
    pl(player, amount / 10)
    return Commands.success
end)
