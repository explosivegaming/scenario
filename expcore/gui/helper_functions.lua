--[[-- Core Module - Gui
- Used to define new gui elements and gui event handlers
@module Gui
]]

local Gui = require 'expcore.gui.prototype'

--- Helper Functions.
-- @section helperFunctions

--[[-- Get the player that owns a gui element
@tparam LuaGuiElement element the element that you want to get the owner of
@treturn LuaPlayer the player that owns this element

@usage-- Geting the owner of an element
local player = Gui.get_player_from_element(element)

]]
function Gui.get_player_from_element(element)
    if not element or not element.valid then return end
    return game.players[element.player_index]
end

--[[-- Will toggle the enabled state of an element or set it to the one given
@tparam LuaGuiElement element the element that you want to toggle the state of
@tparam[opt] boolean state the state that you want to set
@treturn boolean the new enabled state that the element has

@usage-- Toggling the the enabled state
local new_enabled_state = Gui.toggle_enabled_state(element)

]]
function Gui.toggle_enabled_state(element,state)
    if not element or not element.valid then return end
    if state == nil then state = not element.enabled end
    element.enabled = state
    return state
end

--[[-- Will toggle the visible state of an element or set it to the one given
@tparam LuaGuiElement element the element that you want to toggle the state of
@tparam[opt] boolean state the state that you want to set
@treturn boolean the new visible state that the element has

@usage-- Toggling the the visible state
local new_visible_state = Gui.toggle_visible_state(element)

]]
function Gui.toggle_visible_state(element,state)
    if not element or not element.valid then return end
    if state == nil then state = not element.visible end
    element.visible = state
    return state
end

--[[-- Destory a gui element without causing any errors, likly if the element may have already been removed
@tparam LuaGuiElement element the element that you want to remove
@treturn boolean true if the element was valid and has been removed

@usage-- Likely use case for element not existing
Gui.destroy_if_valid(element[child_name])

]]
function Gui.destroy_if_valid(element)
    if not element or not element.valid then return false end
    element.destroy()
    return true
end

--[[-- Returns a table to be used as a style on sprite buttons, produces a sqaure button
@tparam number size the size that you want the button to be
@tparam[opt=-2] number padding the padding that you want on the sprite
@tparam[opt] table style any extra style settings that you want to have
@treturn table the style table to be used with element_define:style()

@usage-- Adding a sprite button with size 20
local button =
Gui.element{
    type = 'sprite-button',
    sprite = 'entity/inserter'
}
:style(Gui.sprite_style(20))

]]
function Gui.sprite_style(size,padding,style)
    style = style or {}
    style.padding = padding or -2
    style.height = size
    style.width = size
    return style
end