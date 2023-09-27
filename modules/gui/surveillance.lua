---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event

local cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 480)

    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    for i=1, 2 do
        local scroll_table_1 = Gui.scroll_table(container, 400, 6, 'cctv_st_' .. i .. '1')

        scroll_table_1.add{
            type = 'drop-down',
            name = 'cctv_display_' .. i .. 'p',
            items = player_list,
            selected_index = 1
        }

        local s = scroll_table_1.add{
            type = 'drop-down',
            name = 'cctv_display_' .. i .. 's',
            items = {'Player', 'Static'},
            selected_index = 1
        }

        local e = scroll_table_1.add{
            type = 'drop-down',
            name = 'cctv_display_' .. i .. 'e',
            items = {'Enable', 'Disable'},
            selected_index = 1
        }

        local l = scroll_table_1.add{
            type = 'button',
            name = 'cctv_display_' .. i .. 'l',
            caption = 'set',
            style = 'button'
        }

        local a = scroll_table_1.add{
            type = 'button',
            name = 'cctv_display_' .. i .. 'a',
            caption = '+',
            style = 'button'
        }

        local b = scroll_table_1.add{
            type = 'button',
            name = 'cctv_display_' .. i .. 'b',
            caption = '-',
            style = 'button'
        }

        s.style.width = 96
        e.style.width = 96
        l.style.width = 48
        a.style.width = 36
        b.style.width = 36

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

Event.add(defines.events.on_player_joined_game, gui_update)
Event.add(defines.events.on_player_left_game, gui_update)

Event.add(defines.events.on_gui_click, function(event)
    if event.element.name:sub(1, 13) == 'cctv_display_' then
        local frame = Gui.get_left_element(game.players[event.player_index], cctv_container)
        local i = event.element.name:sub(-2):sub(1, 1)

        if event.element.name:sub(-1) == 'l' then
            frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].position = game.players[event.player_index].position

        elseif event.element.name:sub(-1) == 'a' then
            if frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom < 2.0 then
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom = frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom + 0.05
            end

        elseif event.element.name:sub(-1) == 'b' then
            if frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom > 0.2 then
                frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom = frame.container['cctv_st_' .. i .. '2'].table['cctv_display_' .. i .. 'f']['cctv_display_' .. i .. 'm'].zoom - 0.05
            end
        end
    end
end)

Event.add(defines.events.on_tick, function(_)
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)

        for i=1, 2 do
            local switch_index = frame.container['cctv_st_' .. i .. '1'].table['cctv_display_' .. i .. 's'].selected_index
            if switch_index == 1 then
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
    end
end)
