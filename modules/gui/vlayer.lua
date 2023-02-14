local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.gui.vlayer' --- @dep config.gui.player_list_actions
local Colors = require 'utils.color_presets' --- @dep utils.color_presets

--[[
344,000
369,000

Power Production:
Peak: 344 k x 60 kW
Average sustained: 344 x 60 kW x 291 / 416

Battery Storage:
369k x 5.0 MJ = ....

Net Power Production:
- 5,000 MW 
]]

local vlayer_container =
Gui.element(function(event_trigger, parent)
    local player = Gui.get_player_from_element(parent)
    local container = Gui.container(parent, event_trigger, 300)

    local header = Gui.header(container, 'VLAYER', '', true)

    -- Draw the scroll table for the warps
    local scroll_table = Gui.scroll_table(container, 250, 3)
    -- Set the scroll panel to always show the scrollbar (not doing this will result in a changing gui size)
    scroll_table.parent.vertical_scroll_policy = 'always'

    -- Change the style of the scroll table
    local scroll_table_style = scroll_table.style
    scroll_table_style.top_cell_padding = 3
    scroll_table_style.bottom_cell_padding = 3

    -- Draw the warp cooldown progress bar
    local warp_timer_element = warp_timer(container)

    -- Change the progress of the warp timer
    local timer = PlayerCooldown:get(player)
    if timer > 0 then
        warp_timer_element.tooltip = {'warp-list.timer-tooltip', math.floor(timer/config.update_smoothing)}
        warp_timer_element.value = 1 - (timer/config.update_smoothing/config.cooldown_duration)
    else
        warp_timer_element.tooltip = {'warp-list.timer-tooltip-zero', config.cooldown_duration}
        warp_timer_element.value = 1
    end

    -- Add any existing warps
    update_all_warps(player, scroll_table)

    -- Return the external container
    return container.parent
end)
:add_to_left_flow()


Gui.left_toolbar_button(
    "item/solar-panel",
    {"vlayer.main-tooltip"},
    vlayer_container,
    function(player)
        return Roles.player_allowed(player, "gui/vlayer")
    end
)

Event.on_nth_tick(60, function()
    end
end)