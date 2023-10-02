-- Vlayer Config
-- @config Vlayer

return {
    update_tick = 10,
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
        ['solar-panel'] = 10,
        ['accumulator'] = 10
    },
    init_circuit = {
        {
            index = 1,
            type = 'virtual',
            name = 'signal-P'
        },
        {
            index = 2,
            type = 'virtual',
            name = 'signal-S'
        },
        {
            index = 3,
            type = 'virtual',
            name = 'signal-M'
        },
        {
            index = 4,
            type = 'virtual',
            name = 'signal-C'
        },
        {
            index = 5,
            type = 'virtual',
            name = 'signal-D'
        },
        {
            index = 6,
            type = 'virtual',
            name = 'signal-T'
        },
        {
            index = 7,
            type = 'virtual',
            name = 'signal-L'
        },
        {
            index = 8,
            type = 'virtual',
            name = 'signal-A'
        },
        {
            index = 9,
            type = 'virtual',
            name = 'signal-B'
        },
        {
            index = 10,
            type = 'item',
            name = 'solar-panel'
        },
        {
            index = 11,
            type = 'item',
            name = 'accumulator'
        }
    },
    init_gui = {
        {
            index = 1,
            disp = 'Solar Panel',
            type = 'item',
            name = 'solar-panel'
        },
        {
            index = 2,
            disp = 'Accumulator',
            type = 'item',
            name = 'accumulator'
        },
        {
            index = 3,
            disp = 'Peak Production',
            type = 'virtual',
            name = 'signal-P'
        },
        {
            index = 4,
            disp = 'Sustained Production',
            type = 'virtual',
            name = 'signal-S'
        },
        {
            index = 5,
            disp = 'Max Battery',
            type = 'virtual',
            name = 'signal-M'
        },
        {
            index = 6,
            disp = 'Current Battery',
            type = 'virtual',
            name = 'signal-C'
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