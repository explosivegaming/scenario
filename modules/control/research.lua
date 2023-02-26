local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.research' --- @dep config.research

local inf_res = {
    -- Mining Productivity
    'mining-productivity-4',
    -- Robot Speed
    'worker-robots-speed-6',
    -- Laser Damage
    'energy-weapons-damage-7',
    -- Explosive Damage
    'stronger-explosives-7',
    -- Bullet Damage
    'physical-projectile-damage-7',
    -- Flame Damage
    'refined-flammables-7',
    -- Artillery Range
    'artillery-shell-range-1',
    -- Artillery Speed
    'artillery-shell-speed-1'
}

local function research_notification(event)
    game.print{'research.msg', event.research.name}
end

if config.enabled then
    Event.add(defines.events.on_research_finished, research_notification)
end
