---- module surveillance
-- @addon surveillance

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event

local cctv_container

local cctv_player =
Gui.element(function(name, parent, player_list)
    return parent.add{
        name = name,
        type = 'drop-down',
        items = player_list,
        selected_index = #player_list > 0 and 1
    }
end)
:style{
    horizontally_stretchable = true
}

local cctv_type =
Gui.element{
    type = 'drop-down',
    name = 'cctv_status',
    items = {'Enable', 'Disable'},
    selected_index = 2
}:style{
    width = 96
}:on_selection_changed(function(_, element, _)
    if element.selected_index == 1 then
        element.parent.parent.parent.cctv_display.visible = true
    else
        element.parent.parent.parent.cctv_display.visible = false
    end
end)

local cctv_status =
Gui.element{
    type = 'drop-down',
    name = 'cctv_status',
    items = {'Player', 'Static'},
    selected_index = 1
}:style{
    width = 96
}

local cctv_location =
Gui.element{
    type = 'button',
    caption = 'set'
}:style{
    width = 48
}:on_click(function(player, element, _)
    element.parent.parent.parent.cctv_display.position = player.position
end)

local zoom_in =
Gui.element{
    type = 'button',
    caption = '+'
}:style{
    width = 32
}:on_click(function(_, element, _)
    local display = element.parent.parent.parent.cctv_display
    if display.zoom < 2.0 then
        display.zoom = display.zoom + 0.05
    end
end)

local zoom_out =
Gui.element{
    type = 'button',
    caption = '-'
}:style{
    width = 32
}:on_click(function(_, element, _)
    local display = element.parent.parent.parent.cctv_display
    if display.zoom > 0.2 then
        display.zoom = display.zoom - 0.05
    end
end)

local camera_set =
Gui.element(function(_, parent, name, player_list)
    local camera_set = parent.add{type='flow', direction='vertical', name=name}
    local buttons = Gui.scroll_table(camera_set, 480, 6, 'buttons')

    cctv_player(buttons, player_list)
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

    camera.visible = false
    camera.style.minimal_width = 400
    camera.style.minimal_height = 300
    return camera_set
end)

cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 400)
    local scroll = container.add{name='scroll', type='scroll-pane', direction='vertical'}
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    camera_set(scroll, 'cctv_st_1', player_list)
    camera_set(scroll, 'cctv_st_2', player_list)

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/radar', 'Surveillance GUI', cctv_container, function(player)
	return Roles.player_allowed(player, 'gui/surveillance')
end)

local function gui_update()
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        frame.container.scroll['cctv_st_1'].buttons.table[cctv_player.name].items = player_list
        frame.container.scroll['cctv_st_2'].buttons.table[cctv_player.name].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, gui_update)
Event.add(defines.events.on_player_left_game, gui_update)

Event.add(defines.events.on_tick, function(_)
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)

        for i=1, 2 do
            local scroll_table_name = 'cctv_st_' .. i
            local current_camera_set = frame.container.scroll[scroll_table_name]
            local switch_index = current_camera_set.buttons.table[cctv_status.name].selected_index

            if switch_index == 1 then
                local selected_index = current_camera_set.buttons.table[cctv_player.name].selected_index

                if selected_index ~= nil or selected_index ~= 0 then
                    current_camera_set['cctv_display'].position = game.players[selected_index].position
                    current_camera_set['cctv_display'].surface_index = game.players[selected_index].surface_index

                else
                    current_camera_set['cctv_display'].position = {x=0, y=0}
                    current_camera_set['cctv_display'].surface_index = game.surfaces['nauvis'].index
                end
            end
        end
    end
end)
