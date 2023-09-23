---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event

local cctv_container

local button_1_zoom_a =
Gui.element{
    name = 'cctv_display_m1_za',
    type = 'button',
    caption = '+',
    style = 'button'
}:on_click(function(player)
    local frame = Gui.get_left_element(player, cctv_container)
    frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].zoom = frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].zoom + 0.05
end):style{
    maximal_width = 36
}


local button_1_zoom_b =
Gui.element{
    name = 'cctv_display_m1_zb',
    type = 'button',
    caption = '-',
    style = 'button'
}:on_click(function(player)
    local frame = Gui.get_left_element(player, cctv_container)
    frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].zoom = frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].zoom - 0.05
end):style{
    maximal_width = 36
}

local button_2_zoom_a =
Gui.element{
    name = 'cctv_display_m2_za',
    type = 'button',
    caption = '+',
    style = 'button'
}:on_click(function(player)
    local frame = Gui.get_left_element(player, cctv_container)
    frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].zoom = frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].zoom + 0.05
end):style{
    maximal_width = 36
}


local button_2_zoom_b =
Gui.element{
    name = 'cctv_display_m2_zb',
    type = 'button',
    caption = '-',
    style = 'button'
}:on_click(function(player)
    local frame = Gui.get_left_element(player, cctv_container)
    frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].zoom = frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].zoom - 0.05
end):style{
    maximal_width = 36
}


cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 400)
    Gui.header(container, 'CCTV', '', true)
    local scroll_table_11 = Gui.scroll_table(container, 400, 4, 'cctv_st_11')
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    scroll_table_11.add{
        type = 'drop-down',
        name = 'cctv_display_1p',
        items = player_list,
        selected_index = 1
    }

    scroll_table_11.add{
        type = 'drop-down',
        name = 'cctv_display_1e',
        items = {'Enable', 'Disable'},
        selected_index = 1
    }

    button_1_zoom_a(scroll_table_11)
    button_1_zoom_b(scroll_table_11)

    local scroll_table_12 = Gui.scroll_table(container, 400, 1, 'cctv_st_12')
    container['cctv_st_12'].vertical_scroll_policy = 'never'

    local frame = scroll_table_12.add{
        type = 'frame',
        name = 'cctv_display_1f',
        direction = 'vertical'
    }

    local camera = frame.add{
        type = 'camera',
        name = 'cctv_display_1m',
        position = {x=0, y=0},
        surface_index = game.surfaces['nauvis'].index,
        zoom = 0.75,
    }
    camera.style.minimal_width = 400
    camera.style.minimal_height = 300

    local scroll_table_21 = Gui.scroll_table(container, 400, 4, 'cctv_st_21')

    scroll_table_21.add{
        type = 'drop-down',
        name = 'cctv_display_2p',
        items = player_list,
        selected_index = 1
    }

    scroll_table_21.add{
        type = 'drop-down',
        name = 'cctv_display_2e',
        items = {'Enable', 'Disable'},
        selected_index = 1
    }

    button_2_zoom_a(scroll_table_21)
    button_2_zoom_b(scroll_table_21)

    local scroll_table_22 = Gui.scroll_table(container, 400, 1, 'cctv_st_22')
    container['cctv_st_22'].vertical_scroll_policy = 'never'

    frame = scroll_table_22.add{
        type = 'frame',
        name = 'cctv_display_2f',
        direction = 'vertical'
    }

    camera = frame.add{
        type = 'camera',
        name = 'cctv_display_2m',
        position = {x=0, y=0},
        surface_index = game.surfaces['nauvis'].index,
        zoom = 0.75,
    }

    camera.style.minimal_width = 400
    camera.style.minimal_height = 300

    return container.parent
end)
:add_to_left_flow()

Gui.left_toolbar_button('entity/radar', 'CCTV GUI', cctv_container, function(player)
	return Roles.player_allowed(player, 'gui/cctv')
end)

local function gui_update()
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        frame.container['cctv_st_11'].table['cctv_display_1p'].items = player_list
        frame.container['cctv_st_21'].table['cctv_display_2p'].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, function(_)
    gui_update()
end)

Event.add(defines.events.on_player_left_game, function(_)
    gui_update()
end)

Event.on_nth_tick(1, function()
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        local selected_index = frame.container['cctv_st_11'].table['cctv_display_1p'].selected_index

        if selected_index ~= nil or selected_index ~= 0 then
            frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].position = game.players[selected_index].position

        else
            frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].position = {x=0, y=0}
        end

        selected_index = frame.container['cctv_st_21'].table['cctv_display_2p'].selected_index

        if selected_index ~= nil or selected_index ~= 0 then
            frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].position = game.players[selected_index].position

        else
            frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].position = {x=0, y=0}
        end

        if frame.container['cctv_st_11'].table['cctv_display_1e'].selected_index == 1 then
            frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].visible = true
        else
            frame.container['cctv_st_12'].table['cctv_display_1f']['cctv_display_1m'].visible = false
        end

        if frame.container['cctv_st_21'].table['cctv_display_2e'].selected_index == 1 then
            frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].visible = true
        else
            frame.container['cctv_st_22'].table['cctv_display_2f']['cctv_display_2m'].visible = false
        end
    end
end)
