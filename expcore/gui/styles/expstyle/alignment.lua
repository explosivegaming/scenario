--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui

Gui.require_concept 'flow' --- @dep gui.concept.flow

--[[-- A flow which can be used to align text and other elements
@element alignment
@usage-- Concept Structure
-- Root
--> [alignment] - the alignment area
Gui.new_concept('alignment')
:set_horizontal_align('center')
]]

Gui.new_concept('flow')
:save_as('alignment')

:new_property('horizontal_align',nil,'right')
:new_property('vertical_align',nil,'center')
:new_property('width')
:new_property('height')

:define_draw(function(properties,parent,element)
    local style = element.style
    Gui.set_padding(element,1,1,2,2)

    -- Set the alignment of the flow
    style.horizontal_align = properties.horizontal_align
    style.vertical_align = properties.vertical_align

    -- Set the stretchablity based on the alignment
    style.horizontally_stretchable = style.horizontal_align ~= 'center'
    style.vertically_stretchable  = style.vertical_align ~= 'center'

    -- Set the width if given
    local width = properties.width
    if width then style.width = width end

    -- Set the hieght if given
    local height = properties.height
    if height then style.height = height end

    return element
end)