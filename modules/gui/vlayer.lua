local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.gui.vlayer' --- @dep config.gui.player_list_actions
local Colors = require 'utils.color_presets' --- @dep utils.color_presets
local format_number = require('util').format_number

--[[
Item Count:
Solar Panel: 344,000
Accumulator: 369,000

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
    scroll_table.add{
        name = 'solar_panel_display_title',
        type = 'label',
        caption = '[img=entity/solar-panel] Solar Panel',
        style = 'heading_1_label'
    }
    local solar_panel_display_count =
    scroll_table.add{
        name = 'solar_panel_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }
    local accumulator_display_title =
    scroll_table.add{
        name = 'accumulator_display_title',
        type = 'label',
        caption = '[img=entity/accumulator] Accumulator',
        style = 'heading_1_label'
    }
    local accumulator_display_count =
    scroll_table.add{
        name = 'accumulator_display_count',
        type = 'label',
        caption = '0',
        style = 'heading_1_label'
    }
    
    solar_panel_display_title.style.width=150
    accumulator_display_title.style.width=150

    local power_production_peak_display_title =
    scroll_table.add{
        name = 'accumulator_display_title',
        type = 'label',
        caption = 'Power Production Peak',
        style = 'heading_1_label'
    }
    local power_production_peak_display_count =
    scroll_table.add{
        name = 'accumulator_display_count',
        type = 'label',
        caption = '0 kW',
        style = 'heading_1_label'
    }
    local power_production_sustained_display_title =
    scroll_table.add{
        name = 'accumulator_display_title',
        type = 'label',
        caption = 'Power Production Sustained',
        style = 'heading_1_label'
    }
    local power_production_sustained_display_count =
    scroll_table.add{
        name = 'accumulator_display_count',
        type = 'label',
        caption = '0 kW',
        style = 'heading_1_label'
    }
    power_production_peak_display_title.style.width=150
    power_production_sustained_display_title.style.width=150

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
        
        container.scroll.table.power_production_peak_display_count.caption = format_number(global.phi.vlayer.storage.item['solar-panel'] * 60) .. ' kW'
        container.scroll.table.power_production_sustained_display_count.caption = format_number(global.phi.vlayer.storage.item['solar-panel'] * 4365 / 104) .. ' kW'
    end
end)
