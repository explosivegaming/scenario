--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- A piece of text.
@element label

@tparam ?string|Concepts.LocalisedString caption the caption that will show in the label
@tparam ?string|Concepts.LocalisedString description the description that will show on the label
@tparam defines.rich_text_setting rich_text how this element handles rich text

@usage-- Making a basic label
local basic_label =
Gui.new_concept('label')
:set_caption('Hello, World!')

]]
Gui.new_concept()
:save_as('label')

-- Properties
:new_property('caption')
:new_property('description')
:new_property('rich_text')

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw a label
    element = parent.add{
        name = properties.name,
        type = 'label',
        caption = properties.caption,
        description = properties.description
    }

    -- Change rich text setting if present
    local rich_text = properties.rich_text
    if rich_text then
        element.style.rich_text_setting = rich_text
    end

    return element
end)