--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic dropdown element
@element elem_button
@param on_selection_changed fired when the selected value is changed
@tparam ?string|Concepts.SignalID|function default the option which is selected by default, or a function which returns the default
@tparam string elem_type the type of elem selection that this is, default is item selection
@usage-- Making a basic elem button
local basic_elem_button =
Gui.clone_concept('elem_button','basic_elembutton')
:on_selection_changed(function(event)
    event.player.print('Basic elem button is now: '..event.element.elem_value)
end)
]]
Gui.new_concept('elem_button')
:new_event('on_selection_changed',defines.events.on_gui_elem_changed)
:new_property('default')
:new_property('elem_type','item')
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'choose-elem-button',
        elem_type = properties.elem_type
    }

    local default = Gui.resolve_property(properties.default,element)
    if default then
        element.elem_value = default
    end

    return element
end)