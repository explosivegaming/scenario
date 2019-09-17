--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- A vertical or horizontal line.
@element line
@tparam string direction the direction that children will be added
@usage-- Making a basic frame, contains a label with hello world
local basic_line =
Gui.clone_concept('line','basic_line')
]]
Gui.new_concept('line')
:new_property('direction')
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'line',
        direction = properties.direction
    }

    return element
end)