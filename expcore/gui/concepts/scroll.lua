--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- Similar to a flow but includes the ability to show and use scroll bars.
@element scroll
@tparam string horizontal_scroll the horizontal scroll policy for this scroll pane
@tparam string vertical_scroll the vertical scroll policy for this scroll pane
@usage-- Making a basic flow, contains a label with hello world
local basic_scroll =
Gui.clone_concept('scroll','basic_scroll')
:define_draw(function(properties,parent,element)
    element.style.hieght = 50
    for i = 1,10 do
        element.add{
            type = 'label',
            caption = i
        }
    end
end)
]]
Gui.new_concept('scroll')
:new_property('horizontal_scroll')
:new_property('vertical_scroll')
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'scroll-pane',
        horizontal_scroll_policy = properties.horizontal_scroll,
        vertical_scroll_policy = properties.vertical_scroll
    }

    return element
end)