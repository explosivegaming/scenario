-- Vlayer Config
-- @config Vlayer

return {
    update_tick = 10,
    update_tick_storage = 6,
    update_tick_power = 1,
    -- MW and MJ
    default_energy = {
        ['solar-panel'] = 0.06,
        ['accumulator'] = 5
    },
    land = {
        enabled = true,
        init_value = 100,
        tile = 'landfill',
        result = 4,
        requirement = {
            ['solar-panel'] = 9,
            ['accumulator'] = 4
        }
    },
    always_day = false,
    battery_limit = true,
    -- setting to a value greater than 1
    -- will allow wireless energy or item transfer
    interface_limit = {
        ['storage_input'] = 1,
        ['storage_output'] = 0,
        ['energy'] = 1,
        ['circuit'] = 1
    },
    init_item = {
        ['solar-panel'] = {
            enabled = true,
            circuit = true,
            direct = false,
            value = 10
        },
        ['accumulator'] = {
            enabled = true,
            circuit = true,
            direct = false,
            value = 10
        },
        -- TODO: Can convert wood directly to energy to reduce trash
        ['wood'] = {
            enabled = false,
            circuit = true,
            direct = true,
            value = 0
        },
        ['coal'] = {
            enabled = false,
            circuit = true,
            direct = true,
            value = 0
        },
        ['stone'] = {
            enabled = false,
            circuit = true,
            direct = true,
            value = 0
        },
        ['iron-ore'] = {
            enabled = false,
            circuit = true,
            direct = true,
            value = 0
        },
        ['copper-ore'] = {
            enabled = false,
            circuit = true,
            direct = true,
            value = 0
        },
        ['uranium-ore'] = {
            enabled = false,
            circuit = true,
            direct = true,
            value = 0
        }
    },
    -- for modded power
    init_item_m = {
        ['solar-panel-2'] = {
            n = 'solar-panel',
            m = 4
        },
        ['solar-panel-3'] = {
            n = 'solar-panel',
            m = 16
        },
        ['solar-panel-4'] = {
            n = 'solar-panel',
            m = 64
        },
        ['solar-panel-5'] = {
            n = 'solar-panel',
            m = 256
        },
        ['solar-panel-6'] = {
            n = 'solar-panel',
            m = 1024
        },
        ['solar-panel-7'] = {
            n = 'solar-panel',
            m = 4096
        },
        ['solar-panel-8'] = {
            n = 'solar-panel',
            m = 16384
        },
        ['accumulator-2'] = {
            n = 'accumulator',
            m = 4
        },
        ['accumulator-3'] = {
            n = 'accumulator',
            m = 16
        },
        ['accumulator-4'] = {
            n = 'accumulator',
            m = 64
        },
        ['accumulator-5'] = {
            n = 'accumulator',
            m = 256
        },
        ['accumulator-6'] = {
            n = 'accumulator',
            m = 1024
        },
        ['accumulator-7'] = {
            n = 'accumulator',
            m = 4096
        },
        ['accumulator-8'] = {
            n = 'accumulator',
            m = 16384
        },
    }
}
