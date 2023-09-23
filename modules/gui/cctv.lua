---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.cctv' --- @dep config.cctv

local cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 320)
    Gui.header(container, 'CCTV', '', true)

    local scroll_table = Gui.scroll_table(container, 320, 1)

    local player_list = {}

    for _, player in pairs(game.connected_players) do
        table.insert(player_list, player.name)
    end

    scroll_table.add{
        type = 'drop-down',
        name = 'cctv_display_p',
        items = player_list,
        selected_index = 1
    }

    local frame = scroll_table.add{
        type = 'frame',
        name = 'cctv_display_f',
        direction = 'vertical',
        vertical_scroll_policy = 'never'
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
        frame.container.scroll.table['cctv_display_p'].items = player_list
    end
end

Event.add(defines.events.on_player_joined_game, function(_)
    gui_update()
end)

Event.add(defines.events.on_player_left_game, function(_)
    gui_update()
end)

-- player_list[frame.container.scroll.table['cctv_display_p'].selected_index]
Event.on_nth_tick(config.update_tick, function()
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        frame.container.scroll.table['cctv_display_f']['cctv_display_m'].position = game.players[frame.container.scroll.table['cctv_display_p'].selected_index].position
    end
end)
