local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.research' --- @dep config.research

local res_queue_enable = false

local inf_res = {
    {
        -- Mining Productivity
        name = 'mining-productivity-4',
        level = 4
    },
    {
        -- Robot Speed
        name = 'worker-robots-speed-6',
        level = 6
    },
    {
        -- Laser Damage
        name = 'energy-weapons-damage-7',
        level = 7
    },
    {
        -- Explosive Damage
        name = 'stronger-explosives-7',
        level = 7
    },
    {
        -- Bullet Damage
        name = 'physical-projectile-damage-7',
        level = 7
    },
    {
        -- Flame Damage
        name = 'refined-flammables-7',
        level = 7
    },
    {
        -- Artillery Range
        name = 'artillery-shell-range-1',
        level = 1
    },
    {
        -- Artillery Speed
        name = 'artillery-shell-speed-1',
        level = 1
    }
}

local function research_notification(event)
    if not (event.by_script) then
        local is_inf_res = false
        
        for i=1, #inf_res do
            if event.research.name == inf_res[i].name then
                is_inf_res = true
            end
        end

        if is_inf_res then
            game.print{'research.inf_msg', event.research.name, event.research.level}
        else
            game.print{'research.msg', event.research.name}
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

Commands.new_command('auto-research', 'Automatically queue up research')
:add_alias('ares')
:register(function(player)
    res_queue_enable = not res_queue_enable

    if res_queue_enable then
        res_queue(player.force)
    end

    return Commands.success
end)

if config.enabled then
    Event.add(defines.events.on_research_finished, function(event)
        research_notification(event)

        if config.bonus.enabled and force.technologies['mining-productivity-4'].level > 4 then
            event.research.force[config.bonus.result] = force.technologies['mining-productivity-4'].level * config.bonus.rate
        end

        if res_queue_enable then
            res_queue(event.research.force)
        end
    end)
end
