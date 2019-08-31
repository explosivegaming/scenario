--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic frame element
@element frame
@tparam ?string|Concepts.LocalisedString title the title that will show in the frame
@tparam string direction the direction that children will be added
@usage-- Making a basic frame, contains a label with hello world
local basic_frame =
Gui.clone_concept('dropdown','basic_frame')
:set_title('Basic Frame')
:define_draw(function(properties,parent,element)
    element.add{
        type = 'label',
        caption = 'Hello, World!'
    }
end)
]]
Gui.new_concept('frame')
:new_property('title')
:new_property('direction')
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'frame',
        caption = properties.title,
        direction = properties.direction
    }

    return element
end)