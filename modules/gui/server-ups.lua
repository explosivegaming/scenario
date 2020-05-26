--[[-- Gui Module - Server UPS
    - Adds a server ups counter in the top right and a command to toggle is
    @gui server-ups
    @alias server_ups
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Event = require 'utils.event' --- @dep utils.event
local Commands = require 'expcore.commands' --- @dep expcore.commands

--- Label to show the server ups
-- @element server_ups
local server_ups =
Gui.element{
    type = 'label',
    caption = 'SUPS = 60.0'
}
:style{
    font = 'default-game'
}

--- Toggles if the server ups is visbile
-- @command server-ups
Commands.new_command('server-ups', 'Toggle the server ups display')
:add_alias('sups', 'ups')
:register(function(player)
    local label = player.gui.screen[server_ups.name]
    if not global.ext or not global.ext.server_ups then
        return Commands.error{'expcom-server-ups.no-ext'}
    end
    label.visible = not label.visible
end)

-- Set the location of the label
-- 1920x1080: x=1455, y=30 (ui scale 100%)
local function set_location(event)
    local player = game.players[event.player_index]
    local label = player.gui.screen[server_ups.name]
    local res = player.display_resolution
    local uis = player.display_scale
    label.location = { x=res.width-423*uis, y=30*uis }
end

-- Draw the label when the player joins
Event.add(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    local label = server_ups(player.gui.screen)
    label.visible = false
    set_location(event)
end)

-- Update the caption for all online players
Event.on_nth_tick(60, function()
    if global.ext and global.ext.server_ups then
        local caption = 'SUPS = '..global.ext.server_ups
        for _, player in pairs(game.connected_players) do
            player.gui.screen[server_ups.name].caption = caption
        end
    end
end)

-- Update when res or ui scale changes
Event.add(defines.events.on_player_display_resolution_changed, set_location)
Event.add(defines.events.on_player_display_scale_changed, set_location)