--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic dropdown element
@element elem_button
@param on_selection_change fired when the selected value is changed
@tparam ?string|Concepts.SignalID|function default_selection the option which is selected by default, or a function which returns the default
@tparam string elem_type the type of elem selection that this is, default is item selection
@usage-- Making a basic elem button
local basic_elem_button =
Gui.clone_concept('elem_button',TEST 'basic_elembutton')
:on_selection_change(function(event)
    event.player.print('Basic elem button is now: '..event.element.elem_value)
end)
]]
Gui.new_concept('elem_button')
:new_event('on_selection_change',defines.events.on_gui_elem_changed)
:new_property('default_selection')
:new_property('elem_type','item')
:define_draw(function(properties,parent,element,selection)
    element = parent.add{
        name = properties.name,
        type = 'choose-elem-button',
        elem_type = properties.elem_type
    }

    if properties.default_selection and not selection then
        local default = properties.default_selection
        if type(default) == 'function' then
            default = default(element)
        end

        element.elem_value = default

    elseif selection then
        if type(selection) == 'function' then
            selection = selection(element)
        end

        element.elem_value = selection

    end

    return element
end)