local Event = require 'utils.event' --- @dep utils.event
local Common = require 'expcore.common' --- @dep utils.event
local Global = require 'utils.global' --- @dep utils.global
local config = require 'config.research' --- @dep config.research
local config_bonus = Common.opt_require 'config.bonus' --- @dep config.bonus
local Commands = require 'expcore.commands' --- @dep expcore.commands
local format_time = _C.format_time --- @dep expcore.common

local research = {}
Global.register(research, function(tbl)
    research = tbl
end)

local research_time_format = {hours=true, minutes=true, seconds=true, time=true, string=true}
research.res_queue_enable = false
local base_rate = 0

if config.bonus.enabled then
    for k, _ in pairs(config_bonus.force_bonus) do
        if config_bonus.force_bonus[k].name == config.bonus.name then
            base_rate = config_bonus.force_bonus[k].max
        end
    end
end

local function research_notification(event)
    local is_inf_res = false

    for i=1, #config.inf_res do
        if (event.research.name == config.inf_res[i].name) and (event.research.level >= config.inf_res[i].level) then
            is_inf_res = true
        end
    end

    if config.bonus_inventory.enabled then
        if (event.research.force.mining_drill_productivity_bonus * 10) <= (config.bonus_inventory.limit / config.bonus_inventory.rate) then
            if event.research.force.technologies['toolbelt'].researched then
                event.research.force[config.bonus_inventory.name] = (math.floor(event.research.force.mining_drill_productivity_bonus * 10) * config.bonus_inventory.rate) + 10
            else
                event.research.force[config.bonus_inventory.name] = math.floor(event.research.force.mining_drill_productivity_bonus * 10) * config.bonus_inventory.rate
            end
        end
    end

    if is_inf_res then
        if event.research.name == 'mining-productivity-4' and event.research.level > 4 then
            if config.bonus.enabled then
                event.research.force[config.bonus.name] = base_rate + event.research.level * config.bonus.rate
            end

            if config.pollution_ageing_by_research then
                game.map_settings.pollution.ageing = math.min(10, event.research.level / 5)
            end
        end

        if not (event.by_script) then
            game.print{'expcom-res.inf', format_time(game.tick, research_time_format), event.research.name, event.research.level - 1}
        end
    else
        if not (event.by_script) then
            game.print{'expcom-res.msg', format_time(game.tick, research_time_format), event.research.name}
        end
    end
end

local function res_queue(force)
    if force.rockets_launched == 0 or force.technologies['mining-productivity-4'].level <= 4 then
        return
    end

    local res_q = force.research_queue

    if #res_q < config.queue_amount then
        for i=1, config.queue_amount - #res_q do
            force.add_research(force.technologies['mining-productivity-4'])
        end
    end
end

local function research_queue_logic(event)
    research_notification(event)

    if research.res_queue_enable then
        res_queue(event.research.force)
    end
end

Event.add(defines.events.on_research_finished, function(event)
    research_queue_logic(event)
end)

Event.add(defines.events.on_research_cancelled, function(event)
    research_queue_logic(event)
end)

Commands.new_command('auto-research', 'Automatically queue up research')
:add_alias('ares')
:register(function(player)
    research.res_queue_enable = not research.res_queue_enable

    if research.res_queue_enable then
        res_queue(player.force)
    end

    return game.print{'expcom-res.res', research.res_queue_enable}
end)
