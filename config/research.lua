--- Res Settings
-- @config Research

return {
    enabled = true,
    queue_amount = 3,
    bonus = {
        enabled = false,
        result = 'laboratory_productivity_bonus',
        rate = 1
    }
    --[[
    limit_research = false,
    limit_research_list = {
        {
            -- Mining Productivity
            name = 'mining-productivity-4',
            enabled = false,
            level = 4
        },
        {
            -- Robot Speed
            name = 'worker-robots-speed-6',
            enabled = false,
            level = 6
        },
        {
            -- Laser Damage
            name = 'energy-weapons-damage-7',
            enabled = false,
            level = 7
        },
        {
            -- Explosive Damage
            name = 'stronger-explosives-7',
            enabled = false,
            level = 7
        },
        {
            -- Bullet Damage
            name = 'physical-projectile-damage-7',
            enabled = false,
            level = 7
        },
        {
            -- Flame Damage
            name = 'refined-flammables-7',
            enabled = false,
            level = 7
        },
        {
            -- Artillery Range
            name = 'artillery-shell-range-1',
            enabled = false,
            level = 1
        },
        {
            -- Artillery Speed
            name = 'artillery-shell-speed-1',
            enabled = false,
            level = 1
        }
    }
    ]]
}
