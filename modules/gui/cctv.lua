---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local player_list = {}

for _, player in pairs(game.players) do
    table.insert(player_list, {'', player.name})
end

local cctv_container

cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 300)
    Gui.header(container, 'CCTV', '', true)

    local scroll_table = Gui.scroll_table(container, 300, 1)
    scroll_table.add{
        type = 'drop-down',
        name = 'cctv_display_p',
        items = player_list
    }
    local frame = scroll_table.add{
        type = 'frame',
        name = 'cctv_display_f',
        direction = 'vertical',
        vertical_scroll_policy = 'never'
    }
    frame.add{
        type = 'minimap',
        name = 'cctv_display_m',
        surface_index = game.surfaces['nauvis'].index,
        chart_player_index = 1,
        zoom = 0.75
    }

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/radar', 'CCTV GUI', cctv_container, function(player)
	return Roles.player_allowed(player, 'gui/cctv')
end)

--[[
local function gui_update()
    player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, {'', player.name})
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        frame.container.scroll.table['cctv_display_p'] = player_list
    end
end

Event.add(defines.events.on_player_joined_game, function(event)
    gui_update()
end)

Event.add(defines.events.on_player_left_game, function(event)
    gui_update()
end)

player_list[frame.container.scroll.table['cctv_display_p'].selected_index]

Event.add(defines.events.on_gui_elem_changed, function(event)
    if event.element.elem_value ~= nil then
        local frame = Gui.get_left_element(event.player_index, cctv_container)
        frame.container.scroll.table['cctv_display_f']['cctv_display_m'].chart_player_index = game.players[].index
    end
end)

]]
