-- Vlayer Config
-- @config Vlayer

return {
    enabled = true,
    update_tick = 10,
    -- 10 MJ
    energy_base_limit = 10000000,
    land = {
        enabled = false,
        tile = "landfill",
        result = 4
    },
    always_day = false,
    battery_limit = true,
    interface_limit = {
        storage_input = 1,
        energy_input = 1,
        energy_output = 1,
        circuit = 1
    }
}