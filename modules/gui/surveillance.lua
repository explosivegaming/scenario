---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event

local cctv_container

cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 400)

    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for i=1, 2 do
        local scroll_table_1 = Gui.scroll_table(container, 400, 4, 'cctv_st_' .. i .. '1')

        scroll_table_1.add{
            type = 'drop-down',
            name = 'cctv_display_' .. i .. 'p',
            items = player_list,
            selected_index = 1
        }

        scroll_table_1.add{
            type = 'drop-down',
            name = 'cctv_display_' .. i .. 'e',
            items = {'Enable', 'Disable'},
            selected_index = 1
        }

        local button_za =
        Gui.element{
            name = 'cctv_display_' .. i .. 'mza',
            type = 'button',
            caption = '+',
            style = 'button'
        }:on_click(function(player)
            local frame = Gui.get_left_element(player, cctv_container)
            frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom = frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom + 0.05
        end):style{
            maximal_width = 36
        }

        local button_zb =
        Gui.element{
            name = 'cctv_display_' .. i .. 'mzb',
            type = 'button',
            caption = '-',
            style = 'button'
        }:on_click(function(player)
            local frame = Gui.get_left_element(player, cctv_container)
            frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom = frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom - 0.05
        end):style{
            maximal_width = 36
        }

        button_za(scroll_table_1)
        button_zb(scroll_table_1)

        local scroll_table_2 = Gui.scroll_table(container, 400, 1, 'cctv_st_' .. i .. '2')
        container['cctv_st_' .. i .. '2'].vertical_scroll_policy = 'never'

        local frame = scroll_table_2.add{
            type = 'frame',
            name = 'cctv_display_' .. i .. 'f',
            direction = 'vertical'
        }

        local camera = frame.add{
            type = 'camera',
            name = 'cctv_display_' .. i .. 'm',
            position = {x=0, y=0},
            surface_index = game.surfaces['nauvis'].index,
            zoom = 0.75,
        }

        camera.style.minimal_width = 400
        camera.style.minimal_height = 300
    end

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
        for i=1, 2 do
            frame.container['cctv_st_' .. i .. '1'].table['cctv_display_' .. i .. 'p'].items = player_list
        end
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

        for i=1, 2 do
            local selected_index = frame.container['cctv_st_' .. i .. '1'].table['cctv_display_' .. i .. 'p'].selected_index

            if selected_index ~= nil or selected_index ~= 0 then
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].position = game.players[selected_index].position
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].surface_index = game.players[selected_index].surface_index

            else
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].position = {x=0, y=0}
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].surface_index = game.surfaces['nauvis'].index
            end

            if frame.container['cctv_st_' .. i .. '1'].table['cctv_display_' .. i .. 'e'].selected_index == 1 then
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].visible = true
            else
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].visible = false
            end
        end
    end
end)
