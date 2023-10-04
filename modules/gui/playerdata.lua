---- module pd
-- @addon pd

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
require 'modules.data.statistics'
local format_time = _C.format_time --- @dep expcore.common
local format_number = require('util').format_number --- @dep util

local pd_container
--[[
local pd_disp_n = {
    'DamageDeathRatio',
    'KillDeathRatio',
    'SessionTime',
    'BuildRatio',
    'RocketPerHour',
    'TreeKillPerMinute',
    'NetPlayTime',
    'AFKTimeRatio'
}
]]

local pd_player =
Gui.element(function(name, parent, player_list)
    return parent.add{
        name = name,
        type = 'drop-down',
        items = player_list,
        selected_index = #player_list > 0 and 1
    }
end)

local pd_update =
Gui.element{
    type = 'button',
    caption = 'Update'
}:style{
    width = 96
}:on_click(function(_, element, _)
    local display = element.parent.parent.parent.cctv_display
    if display.zoom > 0.2 then
        display.zoom = display.zoom - 0.05
    end
end)

local pd_set =
Gui.element(function(_, parent, name, player_list)
    local pd_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(pd_set, 320, 2, 'disp')

    pd_player(disp, player_list)
    pd_update(disp)

    return pd_set
end)

local pd_data =
Gui.element(function(_, parent, name, caption, width)
    return parent.add{
        type = 'label',
        name = name,
        caption = caption,
        style = 'heading_1_label'
    }:style{
        width = width
    }
end)

local pd_data_display =
Gui.element(function(_, parent, name, player_name)
    local pd_data_display = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(pd_set, 320, 2, 'disp')
    local data = PlayerData.Statistics

    for _, stat_name in pairs(PlayerData.Statistics.metadata.display_order) do
        pd_data(disp, 'pd_stat_' .. stat_name .. 'n', stat_name, 110)

        if name == 'Playtime' or name == 'AfkTime' then
            pd_data(disp, 'pd_stat_' .. stat_name .. 'c', format_time(data[stat_name]:get(player_name), {hours=true, minutes=true, seconds=true, time=true, string=true}), 90)

        else
            pd_data(disp, 'pd_stat_' .. stat_name .. 'c', format_number(data[stat_name]:get(player_name)), 90)

        end
    end

    return pd_data_display
end)

pd_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 320)
    local player_list = {}

    for _, player in pairs(game.players) do
        table.insert(player_list, player.name)
    end

    pd_set(container, 'pd_st_1', player_list)
    pd_data_display(container, 'pd_st_2', player_list, Gui.get_player_from_element(parent))

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('item/power-armor-mk2', 'Player Data GUI', pd_container, function(player)
	return Roles.player_allowed(player, 'gui/playerdata')
end)

local function gui_player_list_update()
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, pd_container)
        frame.container['pd_st_1'].disp.table[pd_player.name].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, gui_player_list_update)
Event.add(defines.events.on_player_left_game, gui_player_list_update)
