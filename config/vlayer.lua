-- Vlayer Config
-- @config Vlayer

return {
    enabled = true,
    update_tick = 10,
    -- 10 MJ
    energy_base_limit = 10000000,
    land = {
        enabled = true,
        tile = 'landfill',
        result = 4,
        requirement = {
            ['solar-panel'] = 9,
            ['accumulator'] = 4
        }
    },
    always_day = false,
    battery_limit = true,
    -- setting to a value greater than 1 will allow for wireless energy transfer
    interface_limit = {
        storage_input = 1,
        energy = 1,
        circuit = 1
    },
    print_out = {
        ['electric-energy-interface'] = 'energy interface',
        ['constant-combinator'] = 'circuit output',
        ['logistic-chest-storage'] = 'storage input'
    },
    gui = {
        style = 'heading_1_label',
        type = 'label',
        content = {
            {
                title = 'Storage',
                type = nil,
                name = nil
            },
            {
                title = '',
                type = nil,
                name = nil
            },
            {
                title = '[img=entity/solar-panel] Solar Panel',
                type = nil,
                name = nil
            },
            {
                title = 0,
                type = 'item',
                name = 'solar-panel'
            },
            {
                title = '[img=entity/accumulator] Accumulator',
                type = nil,
                name = nil
            },
            {
                title = 0,
                type = 'item',
                name = 'accumulator'
            },
            {
                title = '[virtual-signal=signal-L] Landfill',
                type = nil,
                name = nil
            },
            {
                title = 0,
                type = 'signal',
                name = 7
            },
            {
                title = '[virtual-signal=signal-A] Solar Available',
                type = nil,
                name = nil
            },
            {
                title = 0,
                type = 'signal',
                name = 8
            },
            {
                title = '[virtual-signal=signal-B] Acc Available',
                type = nil,
                name = nil
            },
            {
                title = 0,
                type = 'signal',
                name = 9
            },
            {
                title = 'Power Production',
                type = nil,
                name = nil
            },
            {
                title = 'MW',
                type = nil,
                name = nil
            },
            {
                title = '[virtual-signal=signal-P] Peak',
                type = nil,
                name = nil
            },
            {
                title = '0',
                type = 'signal',
                name = 1
            },
            {
                title = '[virtual-signal=signal-S] Sustained',
                type = nil,
                name = nil
            },
            {
                title = '0',
                type = 'signal',
                name = 2
            },
            {
                title = 'Battery',
                type = nil,
                name = nil
            },
            {
                title = 'MJ',
                type = nil,
                name = nil
            },
            {
                title = '[virtual-signal=signal-M] Max',
                type = nil,
                name = nil
            },
            {
                title = '0',
                type = 'signal',
                name = 3
            },
            {
                title = '[virtual-signal=signal-C] Current',
                type = nil,
                name = nil
            },
            {
                title = '0',
                type = 'signal',
                name = 4
            },
            {
                title = 'Convert',
                type = nil,
                name = nil
            },
            {
                title = '',
                type = nil,
                name = nil
            }
        }
    }
}