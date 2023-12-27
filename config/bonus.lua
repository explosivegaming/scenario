--- Lists all bonuses which can be used, name followed by min max
-- @config Bonuses

return {
    -- level of player bonus for lower roles, 1 level is 10 %
    player_bonus_level = 1,
    player_bonus = {
        {
            name = 'character_mining_speed_modifier',
            enabled = true,
            min = 0,
            max = 2
        },
        {
            name = 'character_running_speed_modifier',
            enabled = true,
            min = 0,
            max = 1.5
        },
        {
            name = 'character_crafting_speed_modifier',
            enabled = true,
            min = 0,
            max = 5
        },
        {
            name = 'character_reach_distance_bonus',
            enabled = true,
            min = 0,
            max = 10
        },
        {
            name = 'character_resource_reach_distance_bonus',
            enabled = true,
            min = 0,
            max = 10
        },
        {
            name = 'character_build_distance_bonus',
            enabled = true,
            min = 0,
            max = 10
        },
        {
            name = 'character_item_pickup_distance_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'character_loot_pickup_distance_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'character_item_drop_distance_bonus',
            enabled = false,
            min = 0,
            max = 5
        },
        {
            name = 'character_inventory_slots_bonus',
            enabled = true,
            min = 0,
            max = 100
        },
        {
            name = 'character_health_bonus',
            enabled = true,
            min = 0,
            max = 200
        }
    },
    force_bonus = {
        {
            name = 'manual_mining_speed_modifier',
            enabled = false,
            min = 0,
            max = 2
        },
        {
            name = 'character_running_speed_modifier',
            enabled = false,
            min = 0,
            max = 1
        },
        {
            name = 'character_crafting_speed_modifier',
            enabled = false,
            min = 0,
            max = 5
        },
        {
            name = 'character_reach_distance_bonus',
            enabled = false,
            min = 0,
            max = 10
        },
        {
            name = 'character_resource_reach_distance_bonus',
            enabled = false,
            min = 0,
            max = 10
        },
        {
            name = 'character_build_distance_bonus',
            enabled = false,
            min = 0,
            max = 10
        },
        {
            name = 'character_item_pickup_distance_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'character_loot_pickup_distance_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'character_item_drop_distance_bonus',
            enabled = false,
            min = 0,
            max = 5
        },
        {
            name = 'character_inventory_slots_bonus',
            enabled = false,
            min = 0,
            max = 100
        },
        {
            name = 'character_health_bonus',
            enabled = false,
            min = 0,
            max = 200
        },
        {
            name = 'worker_robots_speed_modifier',
            enabled = false,
            min = 0,
            max = 1.3
        },
        {
            name = 'worker_robots_battery_modifier',
            enabled = true,
            min = 0,
            max = 1
        },
        {
            name = 'worker_robots_storage_bonus',
            enabled = true,
            min = 0,
            max = 1
        },
        {
            name = 'following_robots_lifetime_modifier',
            enabled = true,
            min = 0,
            max = 1
        },
        {
            name = 'character_trash_slot_count',
            enabled = false,
            min = 0,
            max = 20
        },
        {
            name = 'mining_drill_productivity_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'train_braking_force_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'laboratory_speed_modifier',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'laboratory_productivity_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'inserter_stack_size_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'stack_inserter_capacity_bonus',
            enabled = false,
            min = 0,
            max = 0
        },
        {
            name = 'artillery_range_modifier',
            enabled = false,
            min = 0,
            max = 0
        }
    },
    surface_bonus = {
        {
            name = 'solar_power_multiplier',
            enabled = false,
            min = 0,
            max = 0
        }
    }
}