--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic checkbox element
@element checkbox
@param on_state_change fired when the state of the element is changed
@tparam ?string|Concepts.LocalisedString caption the message that is shown next to the checkbox
@tparam ?string|Concepts.LocalisedString tooltip the tooltip that shows when a player hovers over the checkbox
@tparam boolean use_radio setting to true will use radio buttons rather than checkboxs
@usage-- Making a basic checkbox
local basic_checkbox =
Gui.clone_concept('checkbox','basic_checkbox')
:set_caption('Basic Checkbox')
:set_tooltip('Basic checkbox')
:on_state_change(function(event)
    event.player.print('Basic checkbox is now: '..tostring(event.element.state))
end)
]]
Gui.new_concept('checkbox')
:new_event('on_state_change',defines.events.on_gui_checked_state_changed)
:new_property('tooltip')
:new_property('caption')
:new_property('default_state',false)
:new_property('use_radio',false)
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = properties.use_radio and 'radiobutton' or 'checkbox',
        caption = properties.caption,
        tooltip = properties.tooltip,
        state = properties.default_state
    }

    return element
end)