local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.research' --- @dep config.research

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
    game.print{'research.msg', event.research.name}
end

if config.enabled then
    Event.add(defines.events.on_research_finished, research_notification)
end
