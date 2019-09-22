--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- A button that lets the player pick one of an: item, entity, tile, or signal similar to the filter-select window.
@element elem_button

@param on_selection_changed fired when the selected value is changed

@tparam ?string|Concepts.SignalID|function default the option which is selected by default, or a function which returns the default
@tparam string elem_type the type of elem selection that this is, default is item selection

@usage-- Making a basic elem button
local basic_elem_button =
Gui.new_concept('elem_button')
:on_selection_changed(function(event)
    event.player.print('Basic elem button is now: '..event.element.elem_value)
end)

]]

Gui.new_concept()
:save_as('elem_button')

-- Events
:new_event('on_selection_changed',defines.events.on_gui_elem_changed)

-- Properties
:new_property('default')
:new_property('elem_type',nil,'item')

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw a chose elem button
    element = parent.add{
        name = properties.name,
        type = 'choose-elem-button',
        elem_type = properties.elem_type
    }

    -- If there is a default, select it
    local default = Gui.resolve_property(properties.default,element)
    if default then
        element.elem_value = default
    end

    return element
end)