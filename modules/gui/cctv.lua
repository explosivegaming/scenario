---- module cctv
-- @addon cctv

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local config = require 'config.cctv' --- @dep config.cctv
local cctv_container

cctv_container =
Gui.element(function(event_trigger, parent)
    local container = Gui.container(parent, event_trigger, 300)
    Gui.header(container, 'CCTV', '', true)

    local scroll_table = Gui.scroll_table(container, 300, 1)
    local frame = scroll_table.add{
        type = 'frame',
        name = 'cctv_display_f',
        direction = 'vertical'
    }
    frame.add{
        type = 'minimap',
        name = 'cctv_display_0',
        -- position = {x=0, y=0},
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
Event.on_nth_tick(config.update_tick, function()
    for _, player in pairs(game.connected_players) do
        local frame = Gui.get_left_element(player, cctv_container)
        frame.container.scroll.table['cctv_display_f']['cctv_display_0'].position = game.connected_players[1].position
    end
end)
]]
