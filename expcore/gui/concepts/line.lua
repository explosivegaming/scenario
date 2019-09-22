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
Gui.new_concept('line')

]]

Gui.new_concept()
:save_as('line')

-- Properties
:new_property('direction')

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw a line
    element = parent.add{
        name = properties.name,
        type = 'line',
        direction = properties.direction
    }

    return element
end)