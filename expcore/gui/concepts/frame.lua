--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic frame element
@element frame
@tparam ?string|Concepts.LocalisedString title the title that will show in the frame
]]
Gui.new_concept('frame')
:new_property('title',function(properties,value)
    properties.title = value
end)
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'frame',
        caption = properties.title
    }

    return element
end)