--[[-- Gui Module - Readme
    - Adds a main gui that contains lots of important information about our server
    @gui Readme
    @alias readme
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui
local Roles = require 'expcore.roles' --- @dep expcore.roles
local Event = require 'utils.event' --- @dep utils.event
local Game = require 'utils.game' --- @dep utils.game

--- Main readme container for the center flow
-- @element readme
local readme_toggle
local readme =
Gui.element(function(event_trigger,parent)
    local container = Gui.container(parent,event_trigger,200)
    return container.parent
end)
:on_open(function(player)
    local toggle_button = Gui.get_top_element(player, readme_toggle)
    Gui.toolbar_button_style(toggle_button, true)
end)
:on_close(function(player,element)
    local toggle_button = Gui.get_top_element(player, readme_toggle)
    Gui.toolbar_button_style(toggle_button, false)
    Gui.destroy_if_valid(element)
end)

--- Toggle button for the readme gui
-- @element readme_toggle
readme_toggle =
Gui.toolbar_button('virtual-signal/signal-info','Readme',function(player)
    return Roles.player_allowed(player,'gui/readme')
end)
:on_click(function(player,element)
    local center = player.gui.center
    if center[readme.name] then
        player.opened = nil
    else
        player.opened = readme(center)
    end
end)

--- When a player joins the game for the first time show this gui
Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    player.opened = readme(player.gui.center)
end)