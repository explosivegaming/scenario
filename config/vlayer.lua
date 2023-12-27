-- Vlayer Config
-- @config Vlayer

return {
    update_tick_storage = 60,
    update_tick_energy = 10,
    update_tick_gui = 60,
    -- Cheat options
    unlimited_capacity = false,
    unlimited_surface_area = false,
    mimic_surface = 'nauvis', -- Surface name/index or nil to use config below
    surface = {
        always_day = false,
        solar_power_multiplier = 1,
    },
    interface_limit = {
        energy = 1, -- >1 allows for disconnected networks
        circuit = 10, -- No caveats
        storage_input = 10, -- No caveats
        storage_output = 1 -- >0 allows for item teleportation (allowed_items only)
    },
    allowed_items = {
        ['solar-panel'] = {
            starting_value = 0,
            required_area = 9,
            production = 0.06 -- MW
        },
        ['accumulator'] = {
            starting_value = 2,
            required_area = 4,
            capacity = 5 -- MJ
        },
        ['landfill'] = {
            starting_value = 0,
            required_area = 0,
            surface_area = 4 -- Tiles
        },
        -- TODO: Can convert wood directly to energy to reduce trash
        --[[
        ['wood'] = {},
        ['coal'] = {},
        ['stone'] = {},
        ['iron-ore'] = {},
        ['copper-ore'] = {},
        ['uranium-ore'] = {},
        ]]
    },
    modded_items = {
        ['solar-panel-2'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 4
        },
        ['solar-panel-3'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 16
        },
        ['solar-panel-4'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 64
        },
        ['solar-panel-5'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 256
        },
        ['solar-panel-6'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 1024
        },
        ['solar-panel-7'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 4096
        },
        ['solar-panel-8'] = {
            starting_value = 0,
            base_game_equivalent = 'solar-panel',
            multiplier = 16384
        },
        ['accumulator-2'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 4
        },
        ['accumulator-3'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 16
        },
        ['accumulator-4'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 64
        },
        ['accumulator-5'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 256
        },
        ['accumulator-6'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 1024
        },
        ['accumulator-7'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 4096
        },
        ['accumulator-8'] = {
            starting_value = 0,
            base_game_equivalent = 'accumulator',
            multiplier = 16384
        },
    }
}
