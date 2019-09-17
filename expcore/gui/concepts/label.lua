--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- A piece of text.
@element frame
@tparam ?string|Concepts.LocalisedString caption the caption that will show in the label
@tparam ?string|Concepts.LocalisedString description the description that will show on the label
@usage-- Making a basic label
local basic_label =
Gui.clone_concept('label','basic_label')
:set_caption('Hello, World!')
]]
Gui.new_concept('label')
:new_property('caption')
:new_property('description')
:define_draw(function(properties,parent,element)
    element = parent.add{
        name = properties.name,
        type = 'label',
        caption = properties.caption,
        description = properties.description
    }

    return element
end)