--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' -- @dep expcore.gui

Gui.require_concept 'button' -- @dep gui.concept.table

--[[-- A button that will toggle its caption each time it is pressed
@see Gui.button
@element toggle_button
@tparam string alt_caption the caption to show on the button in its true state
@tparam string alt_tooltip the tooltip to show on the button in its true state
@usage-- Concept Structure
-- Root
--> [toggle_button] - the header button
Gui.new_concept('toggle_button')
:set_caption('<')
:set_tooltip('Press to close.')
:set_alt_caption('>')
:set_alt_tooltip('Press to open.')
:on_click(function(event)
    local state = event.state and 'close' or 'open'
    event.player.print('Toggle button is now: '..state)
end)
]]

Gui.new_concept('button')
:save_as('toggle_button')
:new_property('alt_caption')
:new_property('alt_tooltip')

-- Events
:on_click(function(event)
    local concept = event.concept
    local properties = concept.properties
    local element = event.element
    if element.caption == properties.caption then
        element.caption = properties.alt_caption
        element.tooltip = properties.alt_tooltip or properties.tooltip
        event.state = true

    else
        element.caption = properties.caption
        element.tooltip = properties.tooltip or properties.alt_tooltip
        event.state = false

    end
end)