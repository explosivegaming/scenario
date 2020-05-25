--- Will move players items to spawn when they are banned or kicked, option to clear on leave
-- @addon Inventory-Clear

local Event = require 'utils.event' --- @dep utils.event
local events = require 'config.inventory_clear' --- @dep config.inventory_clear
local move_items = _C.move_items --- @dep expcore.common

local function clear_items(event)
    local player = game.players[event.player_index]
    local inv = player.get_main_inventory()
    move_items(inv.get_contents())
    inv.clear()
end

for _, event_name in ipairs(events) do Event.add(event_name, clear_items) end