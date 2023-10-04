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

local pd_data_playtime_name =
Gui.element{
    type = 'label',
    caption = 'Playtime',
    style = 'heading_1_label'
}:style{
    width = 180
}

local pd_data_playtime_count =
Gui.element{
    type = 'label',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 140
}

local pd_data_distance_travelled_name =
Gui.element{
    type = 'label',
    caption = 'Distance Travelled',
    style = 'heading_1_label'
}:style{
    width = 180
}

local pd_data_distance_travelled_count =
Gui.element{
    type = 'label',
    caption = '0',
    style = 'heading_1_label'
}:style{
    width = 140
}


local pd_data_set =
Gui.element(function(_, parent, name)
    local pd_data_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(pd_data_set, 320, 2, 'disp')

    pd_data_playtime_name(disp)
    pd_data_playtime_count(disp)
    pd_data_distance_travelled_name(disp)
    pd_data_distance_travelled_count(disp)

    return pd_data_set
end)

local pd_username_player =
Gui.element(function(name, parent, player_list)
    return parent.add{
        name = name,
        type = 'drop-down',
        items = player_list,
        selected_index = #player_list > 0 and 1
    }
end)

local pd_username_update =
Gui.element{
    type = 'button',
    caption = 'update'
}:style{
    width = 96
}:on_click(function(_, element, _)
    local player_name = game.players[element.parent[pd_username_player.name].selected_index]
    local data = PlayerData.Statistics
    local table = element.parent.parent.parent.parent['pd_st_2'].disp.table
    table[pd_data_playtime_count.name].caption = format_time(data['Playtime']:get(player_name), {hours=true, minutes=true, seconds=true, time=true, string=true})
    table[pd_data_distance_travelled_count.name].caption = format_number(data['DistanceTravelled']:get(player_name))
end)

local pd_username_set =
Gui.element(function(_, parent, name, player_list)
    local pd_username_set = parent.add{type='flow', direction='vertical', name=name}
    local disp = Gui.scroll_table(pd_username_set, 320, 2, 'disp')

    pd_username_player(disp, player_list)
    pd_username_update(disp)
    disp.table[pd_username_player.name].width = 224

    return pd_username_set
end)

pd_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 320)
    local player_list = {}

    for _, player in pairs(game.players) do
        table.insert(player_list, player.name)
    end

    pd_username_set(container, 'pd_st_1', player_list)
    pd_data_set(container, 'pd_st_2')

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
        frame.container['pd_st_1'].disp.table[pd_username_player.name].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, gui_player_list_update)
Event.add(defines.events.on_player_left_game, gui_player_list_update)
