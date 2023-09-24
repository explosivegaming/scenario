---- module pd
-- @addon pd

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data

local pd_container
local pd_disp_n = {

}

pd_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 400)
    local scroll_table_1 = Gui.scroll_table(container, 400, 4, 'pd_st_1')
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    scroll_table_1.add{
        type = 'drop-down',
        name = 'pd_display_1p',
        items = player_list,
        selected_index = 1
    }

    local scroll_table_2 = Gui.scroll_table(container, 400, 4, 'pd_st_2')

    for _, name in pairs(PlayerData.Statistics.metadata.display_order) do
        scroll_table_2.add{
            name = 'pd_display_' .. i,
            caption = '',
            type = 'label',
            style = config.gui.style
        }
    end

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('armor/power-armor-mk2', 'Player Data GUI', pd_container, function(player)
	return Roles.player_allowed(player, 'gui/playerdata')
end)

local function gui_update()
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, pd_container)
        frame.container['pd_st_1'].table['pd_display_1p'].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, function(_)
    gui_update()
end)

Event.add(defines.events.on_player_left_game, function(_)
    gui_update()
end)

--[[
Event.on_nth_tick(60, function()

end)
]]

Event.add(defines.events.on_gui_elem_changed, function(event)
    if event.element.name == 'pd_display_1p' then
        local frame = Gui.get_left_element(game.players[event.player_index], pd_container)

        for _, name in pairs(PlayerData.Statistics.metadata.display_order) do
            PlayerData.Statistics[name]:get(game.players[event.player_index].name)
        end
    end
end)
