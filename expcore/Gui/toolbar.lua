--- Gui structure for the toolbar (top left)
--[[
>>>> Example format
    -- this is the same as any other button define, this just automatically draws it
    -- you can use add_button if you already defined the button
    local toolbar_button =
    Toolbar.new_button('print-click')
    :on_click(function(player,_element)
        player.print('You clicked a button!')
    end)

>>>> Functions
    Toolbar.new_button(name) --- Adds a new button to the toolbar
    Toolbar.add_button(button) --- Adds an existing buttton to the toolbar
    Toolbar.update(player) --- Updates the player's toolbar with an new buttons or expected change in auth return
]]
local Buttons = require 'expcore.gui.buttons'
local Gui = require 'expcore.gui.core'
local Roles = require 'expcore.roles'
local Event = require 'utils.event'
local Game = require 'utils.game'

local Toolbar = {
    permisison_names = {},
    buttons = {}
}

function Toolbar.allowed(player,define_name)
    local permisison_name = Toolbar.permisison_names[define_name] or define_name
    return Roles.player_allowed(player,permisison_name)
end

function Toolbar.permission_alias(define_name,permisison_name)
    Toolbar.permisison_names[define_name] = permisison_name
end

--- Adds a new button to the toolbar
-- @tparam[opt] name string when given allows an alias to the button for the permission system
-- @treturn table the button define
function Toolbar.new_button(name)
    local button = Buttons.new_button()
    button:set_post_authenticator(Toolbar.allowed)
    Toolbar.add_button(button)
    Toolbar.permission_alias(button.name,name)
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