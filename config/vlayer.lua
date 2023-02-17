-- Vlayer Config
-- @config Vlayer

return {
    enabled = true,
    land = {
        enabled = false,
        tile = "landfill",
        result = 4
    },
    always_day = false,
    battery_limit = true,
    interface_limit = {
        energy_input=1,
        energy_output=1
    }
}