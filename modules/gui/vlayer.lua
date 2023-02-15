local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.gui.vlayer' --- @dep config.gui.player_list_actions
local Colors = require 'utils.color_presets' --- @dep utils.color_presets
local format_number = require('util').format_number

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
    local scroll_table = Gui.scroll_table(container, 300, 2)
    local solar_panel_display_title =
    scroll_table.parent.add{
        name = 'solar_panel_display_title',
        type = 'label',
        caption = 'Solar Panel'
    }
    local solar_panel_display_count =
    scroll_table.parent.add{
        name = 'solar_panel_display_count',
        type = 'label',
        caption = '0'
    }
    local accumulator_display_title =
    scroll_table.parent.add{
        name = 'accumulator_display_title',
        type = 'label',
        caption = 'Accumulator'
    }
    local accumulator_display_count =
    scroll_table.parent.add{
        name = 'accumulator_display_count',
        type = 'label',
        caption = '0'
    }
    --[[
    local solar_panel_display_title = Gui.centered_label(scroll_table, 150, 'Solar Panel')
    local solar_panel_display_count = Gui.centered_label(scroll_table, 150, '0')
    local accumulator_display_title = Gui.centered_label(scroll_table, 150, 'Accumulator')
    local accumulator_display_count = Gui.centered_label(scroll_table, 150, '0')
    ]]
    -- Return the external container
    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/solar-panel', {'vlayer.main-tooltip'}, vlayer_container, function (player)
	return Roles.player_allowed(player, 'gui/vlayer')
end)

Event.on_nth_tick(60, function()
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, player_list_container)
        local container = frame.container
        
        container.scroll.table.solar_panel_display_count.caption = format_number(global.phi.vlayer.storage.item['solar-panel'])
        container.scroll.table.accumulator_display_count.caption = format_number(global.phi.vlayer.storage.item['accumulator'])
    end
end)
