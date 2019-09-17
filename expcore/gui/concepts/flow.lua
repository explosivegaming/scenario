--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- Invisible containers that lay out children either horizontally or vertically. The root GUI elements (top, left and center; see LuaGui) are flows.
@element flow
@tparam string direction the direction that children will be added
@usage-- Making a basic flow, contains a label with hello world
local basic_flow =
Gui.clone_concept('flow','basic_flow')
:define_draw(function(properties,parent,element)
    element.add{
        type = 'label',
        caption = 'Hello, World!'
    }
end)
]]
Gui.new_concept('flow')
:new_property('direction')
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'flow',
        caption = properties.title,
        direction = properties.direction
    }

    return element
end)