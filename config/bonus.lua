--- Lists all bonuses which can be used, name followed by min max
-- @config Bonuses

return {
    player = {
        {
            name = 'character_mining_speed_modifier',
            enabled = true,
            max = 2
        },
        {
            name = 'character_running_speed_modifier',
            enabled = true,
            max = 2
        },
        {
            name = 'character_crafting_speed_modifier',
            enabled = true,
            max = 4
        },
        {
            name = 'character_reach_distance_bonus',
            enabled = true,
            max = 20
        },
        {
            name = 'character_resource_reach_distance_bonus',
            enabled = true,
            max = 20
        },
        {
            name = 'character_build_distance_bonus',
            enabled = true,
            max = 20
        },
        {
            name = 'character_item_pickup_distance_bonus',
            enabled = true,
            max = 10
        },
        {
            name = 'character_loot_pickup_distance_bonus',
            enabled = true,
            max = 10
        },
        {
            name = 'character_item_drop_distance_bonus',
            enabled = true,
            max = 20
        },
        {
            name = 'character_inventory_slots_bonus',
            enabled = true,
            max = 100
        },
        {
            name = 'character_health_bonus',
            enabled = true,
            max = 200
        }
    },
    force = {
        name = 'laboratory_speed_modifier',
        enabled = true,
        max = 0
    }
}