--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The text field element
@element text_field
@param on_text_changed fired when the text within the text field is changed
@param on_confirmation fired when the player presses enter with the text field forcused
@tparam ?string|Concepts.LocalisedString tooltip the tooltip that shows when a player hovers over the text field
@tparam ?string|function default the default text that will appear in the text field, or a function that returns it
@tparam boolean clear_on_rmb if the text field will be cleared and forcused on a right click
@tparam boolean lose_forcus if the text field will lose forcus after the confirmation event
@tparam boolean is_number if this text field contains a number value, can be ignored if is_decimal or is_negitive is used
@tparam boolean is_decimal if this text field contains a decimal value
@tparam boolean is_negative if this text field contains a negative value
@tparam boolean is_password if this text field contains a password value
@usage-- Making a text field
local basic_text_field =
Gui.clone_concept('text_field','basic_text_field')
:on_confirmation(function(event)
    event.player.print('Basic text field is now: '..event.element.text)
end)
@usage-- Making a text field which will clear on right click and un forcus on confirmation
local better_text_field =
Gui.clone_concept('text_field','better_text_field')
:set_clear_on_rmb(true)
:set_lose_forcus(true)
:on_confirmation(function(event)
    event.player.print('Better text field is now: '..event.element.text)
end)
@usage-- Making a decimal input
local decimal_text_field =
Gui.clone_concept('text_field','decimal_text_field')
:set_is_decimal(true)
:on_confirmation(function(event)
    event.player.print('Decimal text field is now: '..event.element.text)
end)
]]
Gui.new_concept('text_field')
:new_event('on_text_changed',defines.events.on_gui_text_changed)
:new_event('on_confirmation',defines.events.on_gui_confirmed)
:new_property('tooltip')
:new_property('default')
:new_property('clear_on_rmb',false)
:new_property('lose_forcus',false)
:new_property('is_number',false)
:new_property('is_decimal',false)
:new_property('is_negative',false)
:new_property('is_password',false)
:define_draw(function(properties,parent,element)
    local default = properties.default
    local text = type(default) == 'string' and default or nil

    element = parent.add{
        name = properties.name,
        type = 'textfield',
        tooltip = properties.tooltip,
        clear_and_focus_on_right_click = properties.clear_on_rmb,
        lose_focus_on_confirm = properties.lose_forcus,
        numeric = properties.is_number or properties.is_decimal or properties.is_negative,
        allow_decimal = properties.is_decimal,
        allow_negative = properties.is_negative,
        is_password = properties.is_password,
        text = text
    }

    default = Gui.resolve_property(default,element)
    if default and default ~= text then
        element.text = default
    end

    return element
end)