return {
    --[[
        d = default
        p = prouctivity allowed
    ]]
    -- type of machine to handle together
    module_row = 4,
    module_slot_max = 4,
    machine = {
        ['electric-mining-drill'] = {
            d = 'effectivity-module',
            p = true
        },
        ['assembling-machine-2'] = {
            d = 'productivity-module',
            p = true
        },
        ['assembling-machine-3'] = {
            d = 'productivity-module-3',
            p = true
        },
        ['electric-furnace'] = {
            d = 'productivity-module-3',
            p = true
        },
        ['beacon'] = {
            d = 'speed-module-3',
            p = false
        },
        ['oil-refinery'] = {
            d = 'productivity-module-3',
            p = true
        },
        ['chemical-plant'] = {
            d = 'productivity-module-3',
            p = true
        },
        ['centrifuge'] = {
            d = 'productivity-module-3',
            p = true
        },
        ['lab'] = {
            d = 'productivity-module-3',
            p = true
        },
        ['rocket-silo'] = {
            d = 'productivity-module-3',
            p = true
        }
    }
}