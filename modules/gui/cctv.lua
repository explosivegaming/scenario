---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.cctv' --- @dep config.cctv

local cctv_container

local button_zoom_a =
Gui.element{
    name = 'cctv_display_m_z_a',
    type = 'button',
    caption = '+',
    style = 'button'
}:on_click(function(player)
    local frame = Gui.get_left_element(player, cctv_container)
    frame.container['cctv_st_2'].table['cctv_display_f']['cctv_display_m'].zoom = frame.container['cctv_st_2'].table['cctv_display_f']['cctv_display_m'].zoom + 0.05
end)

local button_zoom_b =
Gui.element{
    name = 'cctv_display_m_z_b',
    type = 'button',
    caption = '-',
    style = 'button'
}:on_click(function(player)
    local frame = Gui.get_left_element(player, cctv_container)
    frame.container['cctv_st_2'].table['cctv_display_f']['cctv_display_m'].zoom = frame.container['cctv_st_2'].table['cctv_display_f']['cctv_display_m'].zoom - 0.05
end)

cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 400)
    Gui.header(container, 'CH01', '', true)
    local scroll_table_1 = Gui.scroll_table(container, 400, 3, 'cctv_st_1')
    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    scroll_table_1.add{
        type = 'drop-down',
        name = 'cctv_display_p',
        items = player_list,
        selected_index = 1
    }

    button_zoom_a(scroll_table_1)
    button_zoom_b(scroll_table_1)

    local scroll_table_2 = Gui.scroll_table(container, 400, 1, 'cctv_st_2')
    container['cctv_st_2'].vertical_scroll_policy = 'never'

    local frame = scroll_table_2.add{
        type = 'frame',
        name = 'cctv_display_f',
        direction = 'vertical'
    }

    local camera = frame.add{
        type = 'camera',
        name = 'cctv_display_m',
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
        frame.container['cctv_st_1'].table['cctv_display_p'].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, function(_)
    gui_update()
end)

Event.add(defines.events.on_player_left_game, function(_)
    gui_update()
end)

Event.on_nth_tick(config.update_tick, function()
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        local selected_index = frame.container['cctv_st_1'].table['cctv_display_p'].selected_index

        if selected_index ~= nil or selected_index ~= 0 then
            frame.container['cctv_st_2'].table['cctv_display_f']['cctv_display_m'].position = game.players[selected_index].position
        end
    end
end)
