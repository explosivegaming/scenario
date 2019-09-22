--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- Grey semi-transparent boxes that contain other elements. They have a caption, and, just like flows, they lay out children either horizontally or vertically.
@element frame

@tparam ?string|Concepts.LocalisedString title the title that will show in the frame
@tparam string direction the direction that children will be added

@usage-- Making a basic frame, contains a label with hello world
local basic_frame =
Gui.new_concept('frame')
:set_title('Basic Frame')
:define_draw(function(properties,parent,element)
    element.add{
        type = 'label',
        caption = 'Hello, World!'
    }
end)

]]

Gui.new_concept()
:save_as('frame')

-- Properties
:new_property('title')
:new_property('direction')

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw a frame
    element = parent.add{
        name = properties.name,
        type = 'frame',
        caption = properties.title,
        direction = properties.direction
    }

    return element
end)