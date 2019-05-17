--- Gui structure for the toolbar (top left)
--[[
>>>> Functions
    Toolbar.new_button(name) --- Adds a new button to the toolbar
    Toolbar.add_button(button) --- Adds an existing buttton to the toolbar
    Toolbar.update(player) --- Updates the player's toolbar with an new buttons or expected change in auth return
]]
local Buttons = require './buttons'
local Gui = require './core'
local Roles = require 'expcore.roles'
local Event = require 'utils.event'
local Game = require 'utils.game'

local Toolbar = {
    buttons = {}
}

--- Adds a new button to the toolbar
-- @tparam[opt] name string the name of the button to be added
-- @treturn table the button define
function Toolbar.new_button(name)
    name = name or #Toolbar.buttons+1
    local button = Buttons.new_button('toolbar/'..name)
    button:set_post_authenticator(Roles.player_allowed)
    Toolbar.add_button(button)
    return button
end

--- Adds an existing buttton to the toolbar
-- @tparam button table the button define for the button to be added
function Toolbar.add_button(button)
    table.insert(Toolbar.buttons,button)
    Gui.allow_player_to_toggle_top_element_visibility(button.name)
    Gui.on_player_show_top(button.name,function(event)
        if not button.post_authenticator(event.player,button.name) then
            event.element.visible = false
        end
    end)
    if not button.post_authenticator then
        button:set_post_authenticator(function() return true end)
    end
end

--- Updates the player's toolbar with an new buttons or expected change in auth return
-- @tparam player LuaPlayer the player to update the toolbar for
function Toolbar.update(player)
    local top = Gui.get_top_element_flow(player)
    if not top then return end
    local visible = top[Gui.top_toggle_button_name].caption == '<'
    for _,button in pairs(Toolbar.buttons) do
        local element
        if top[button.name] then element = top[button.name]
        else element = button:draw_to(top) end
        if button.post_authenticator(player,button.name) then
            element.visible = visible
            element.enabled = true
        else
            element.visible = false
            element.enabled = false
        end
    end
end

--- When there is a new player they will have the toolbar update
Event.add(defines.events.on_player_created,function(event)
    local player = Game.get_player_by_index(event.player_index)
    Toolbar.update(player)
end)

--- When a player gets a new role they will have the toolbar updated
Event.add(Roles.player_role_assigned,function(event)
    local player = Game.get_player_by_index(event.player_index)
    Toolbar.update(player)
end)

--- When a player loses a role they will have the toolbar updated
Event.add(Roles.player_role_unassigned,function(event)
    local player = Game.get_player_by_index(event.player_index)
    Toolbar.update(player)
end)

return Toolbar