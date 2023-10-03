-- Vlayer Config
-- @config Vlayer

return {
    update_tick = 10,
    -- MW and MJ
    default_energy = {
        ['solar-panel'] = 0.06,
        ['accumulator'] = 5
    },
    land = {
        enabled = false,
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
        ['energy'] = 1,
        ['circuit'] = 1
    },
    init_item = {
        ['solar-panel'] = {
            enabled = true,
            circuit = true,
            value = 10
        },
        ['accumulator'] = {
            enabled = true,
            circuit = true,
            value = 10
        },
        ['landfill'] = {
            enabled = false,
            circuit = true,
            value = 100
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