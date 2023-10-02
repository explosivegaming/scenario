---- module surveillance
-- @addon surveillance

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event

local cctv_container
local player_list = {}

local cctv_player =
Gui.Element{
    type = 'drop-down',
    name = 'cctv_player',
    items = player_list,
    selected_index = 1
}

local cctv_type =
Gui.Element{
    type = 'drop-down',
    name = 'cctv_status',
    items = {'Enable', 'Disable'},
    selected_index = 1
}:style{
    width = 96
}:on_click(function(_, element, _)
    if element.selected_index == 1 then
        element.parent.parent.cctv_display.visible = true
    else
        element.parent.parent.cctv_display.visible = false
    end
end)

local cctv_status =
Gui.Element{
    type = 'drop-down',
    name = 'cctv_status',
    items = {'Player', 'Static'},
    selected_index = 1
}:style{
    width = 96
}:on_click(function(_, element, _)
    if element.selected_index == 1 then
        element.parent.parent.cctv_display.visible = true
    else
        element.parent.parent.cctv_display.visible = false
    end
end)

local cctv_location =
Gui.Element{
    type = 'button',
    caption = 'set'
}:style{
    width = 48
}:on_click(function(player, element, _)
    element.parent.parent.cctv_display.position = player.position
end)

local zoom_in =
Gui.Element{
    type = 'button',
    caption = '+'
}:style{
    width = 36
}:on_click(function(_, element, _)
    if element.parent.parent.cctv_display.zoom < 2.0 then
        element.parent.parent.cctv_display.zoom = element.parent.parent.cctv_display.zoom + 0.05
    end
end)

local zoom_out =
Gui.Element{
    type = 'button',
    caption = '-'
}:style{
    width = 36
}:on_click(function(_, element, _)
    if element.parent.parent.cctv_display.zoom > 0.2 then
        element.parent.parent.cctv_display.zoom = element.parent.parent.cctv_display.zoom - 0.05
    end
end)

local camera_set =
Gui.Element(function(_, parent)
    local camera_set = parent.add{type='flow'}
    local buttons = Gui.scroll_table(camera_set, 400, 6, 'buttons')

    cctv_player(buttons)
    cctv_type(buttons)
    cctv_status(buttons)
    cctv_location(buttons)
    zoom_out(buttons)
    zoom_in(buttons)

    local camera = camera_set.add{
        type = 'camera',
        name = 'cctv_display',
        position = {x=0, y=0},
        surface_index = game.surfaces['nauvis'].index,
        zoom = 0.75,
    }

    camera.style.minimal_width = 400
    camera.style.minimal_height = 300
    return camera_set
end)

cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 480)
    local scroll_table_1 = Gui.scroll_table(container, 400, 6, 'cctv_st_1')
    local scroll_table_2 = Gui.scroll_table(container, 400, 6, 'cctv_st_2')
    player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    camera_set(scroll_table_1)
    camera_set(scroll_table_2)

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/radar', 'Surveillance GUI', cctv_container, function(player)
	return Roles.player_allowed(player, 'gui/surveillance')
end)

local function gui_update()
    player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        frame.container['cctv_st_1'].table.flow['buttons']['cctv_player'].items = player_list
        frame.container['cctv_st_2'].table.flow['buttons']['cctv_player'].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, gui_update)
Event.add(defines.events.on_player_left_game, gui_update)

Event.add(defines.events.on_tick, function(_)
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)

        for i=1, 2 do
            local scroll_table_name = 'cctv_st_' .. i
            local switch_index = frame.container[scroll_table_name].table.flow['cctv_status'].selected_index

            if switch_index == 1 then
                local selected_index = frame.container[scroll_table_name].table.flow['cctv_player'].selected_index

                if selected_index ~= nil or selected_index ~= 0 then
                    frame.container[scroll_table_name].table.flow['cctv_display'].position = game.players[selected_index].position
                    frame.container[scroll_table_name].table.flow['cctv_display'].surface_index = game.players[selected_index].surface_index

                else
                    frame.container[scroll_table_name].table.flow['cctv_display'].position = {x=0, y=0}
                    frame.container[scroll_table_name].table.flow['cctv_display'].surface_index = game.surfaces['nauvis'].index
                end
            end
        end
    end
end)
