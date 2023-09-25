return {
    -- type of machine to handle together
    default_module_row_count = 4,
    module_slot_max = 4,
    machine_prod_disallow = {
        ['beacon'] = true
    },
    machine_type = {
        ['assembling-machine'] = true,
        ['electric-furnace'] = true,
        ['lab'] = true,
        ['mining-drill'] = true
    },
    machine = {
        ['electric-mining-drill'] = 'effectivity-module',
        ['assembling-machine-2'] = 'productivity-module',
        ['assembling-machine-3'] = 'productivity-module-3',
        ['electric-furnace'] = 'productivity-module-3',
        ['beacon'] = 'speed-module-3',
        ['oil-refinery'] = 'productivity-module-3',
        ['chemical-plant'] = 'productivity-module-3',
        ['centrifuge'] = 'productivity-module-3',
        ['lab'] = 'productivity-module-3',
        ['rocket-silo'] = 'productivity-module-3'
    }
}