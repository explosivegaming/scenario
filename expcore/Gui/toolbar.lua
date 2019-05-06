local Buttons = require './buttons'
local Gui = require './core'
local Roles = require 'expcore.roles'
local Event = require 'utils.event'
local Game = require 'utils.game'

local Toolbar = {
    buttons = {}
}

function Toolbar.new_button(name)
    name = name or #Toolbar.buttons+1
    local button = Buttons.new_button('toolbar/'..name)
    button:set_authenticator(Roles.player_allowed)
    Toolbar.add_button(button)
    return button
end

function Toolbar.add_button(button)
    table.insert(Toolbar.buttons,button)
    Gui.allow_player_to_toggle_top_element_visibility(button.name)
    Gui.on_player_show_top(button.name,function(event)
        if not button.authenticator(player,button.clean_name or button.name) then
            event.element.visible = false
        end
    end)
    if not button.authenticator then
        button:set_authenticator(function() return true end)
    end
end

function Toolbar.update(player)
    local top = Gui.get_top_element_flow(player)
    if not top then return end
    for _,button in pairs(Toolbar.buttons) do
        local element
        if top[button.name] then element = top[button.name]
        else element = button:draw_to(top) end
        if button.authenticator(player,button.clean_name or button.name) then
            element.visible = true
            element.enabled = true
        else
            element.visible = false
            element.enabled = false
        end
    end
end

Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    Toolbar.update(player)
end)

Event.add(Roles.player_role_assigned,function(event)
    local player = Game.get_player_by_index(event.player_index)
    Toolbar.update(player)
end)

Event.add(Roles.player_role_unassigned,function(event)
    local player = Game.get_player_by_index(event.player_index)
    Toolbar.update(player)
end)

return Toolbar