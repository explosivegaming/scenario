--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- A empty widget that just exists. The root GUI element screen is an empty-widget.
@element empty

@tparam string style the style that the element will have

@usage-- Making a draggable space styled widget
local draggable_space =
Gui.new_concept('empty')
:set_style('draggable_space')

]]

Gui.new_concept()
:save_as('empty')

-- Properties
:new_property('style')

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw an empty widget
    element = parent.add{
        name = properties.name,
        type = 'empty-widget',
        style = properties.style
    }

    return element
end)