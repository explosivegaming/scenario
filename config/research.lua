--- Res Settings
-- @config Research

return {
    enabled = true,
    pollution_ageing_by_research = false,
    queue_amount = 3,
    bonus = {
        enabled = false,
        name = 'laboratory_productivity_bonus',
        rate = 1
    },
    -- this enable 20 more inventory for each mining productivity level up to 4
    bonus_inventory = {
        enabled = true,
        name = 'character_inventory_slots_bonus',
        rate = 5,
        limit = 20
    },
    milestone = {
        {
            name = 'automation',
            time = 600
        },
        {
            name = 'logistics',
            time = 300
        },
        {
            name = 'steel-processing',
            time = 300
        },
        {
            name = 'logistic-science-pack',
            time = 300
        },
        {
            name = 'electronics',
            time = 300
        },
        {
            name = 'fast-inserter',
            time = 300
        },
        {
            name = 'steel-axe',
            time = 300
        },
        {
            name = 'automation-2',
            time = 300
        },
        {
            name = 'advanced-material-processing',
            time = 300
        },
        {
            name = 'engine',
            time = 300
        },
        {
            name = 'fluid-handling',
            time = 300
        },
        {
            name = 'oil-processing',
            time = 300
        },
        {
            name = 'sulfur-processing',
            time = 300
        },
        {
            name = 'plastics',
            time = 300
        },
        {
            name = 'advanced-electronics',
            time = 300
        },
        {
            name = 'chemical-science-pack',
            time = 300
        },
        {
            name = 'modules',
            time = 300
        },
        {
            name = 'logistics-2',
            time = 300
        },
        {
            name = 'railway',
            time = 300
        },
        {
            name = 'research-speed-1',
            time = 300
        },
        {
            name = 'research-speed-2',
            time = 300
        },
        {
            name = 'battery',
            time = 300
        },
        {
            name = 'concrete',
            time = 300
        },
        {
            name = 'flammables',
            time = 300
        },
        {
            name = 'low-density-structure',
            time = 300
        },
        {
            name = 'advanced-material-processing-2',
            time = 300
        },
        {
            name = 'productivity-module',
            time = 300
        },
        {
            name = 'production-science-pack',
            time = 300
        },
        {
            name = 'advanced-electronics-2',
            time = 300
        },
        {
            name = 'advanced-oil-processing',
            time = 300
        },
        {
            name = 'lubricant',
            time = 300
        },
        {
            name = 'electric-engine',
            time = 300
        },
        {
            name = 'robotics',
            time = 300
        },
        {
            name = 'construction-robotics',
            time = 300
        },
        {
            name = 'worker-robots-speed-1',
            time = 300
        },
        {
            name = 'worker-robots-speed-2',
            time = 300
        },
        {
            name = 'utility-science-pack',
            time = 300
        },
        {
            name = 'productivity-module-2',
            time = 300
        },
        {
            name = 'speed-module-2',
            time = 300
        },
        {
            name = 'rocket-fuel',
            time = 300
        },
        {
            name = 'effect-transmission',
            time = 300
        },
        {
            name = 'productivity-module-3',
            time = 300
        },
        {
            name = 'rocket-control-unit',
            time = 300
        },
        {
            name = 'speed-module-3',
            time = 300
        },
        {
            name = 'rocket-silo',
            time = 300
        },
        {
            name = 'space-science-pack',
            time = 300
        }
    },
    inf_res = {
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
