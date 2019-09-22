--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui

Gui.require_concept 'table' --- @dep gui.concept.table
Gui.require_concept 'scroll' --- @dep gui.concept.scroll

local scroll_area =
Gui.new_concept('scroll')
:set_vertical_scroll('auto-and-reserve-space')
:set_horizontal_scroll('never')

--[[-- A table that is inside a vertical scroll area
@element scroll_table
@tparam number hight the max hight of the scroll area
@usage-- Concept Structure
-- Root
--> [scroll_table] - the scroll area
-->> table - the table area
]]

Gui.new_concept('table')
:save_as('scroll_table')
:new_property('hight',nil,100)

-- Add a scroll before the table is drawn
:define_pre_draw(function(properties,parent,element)
    local scroll = scroll_area:draw(parent,properties.name)

    -- Set the scroll style
    Gui.set_padding(scroll,1,1,2,2)
    scroll.style.horizontally_stretchable = true
    scroll.style.maximal_height = properties.hight

    -- Change the name of the element to table before it is drawn
    properties.name = 'table'

    return element, scroll
end)

-- Draw
:define_draw(function(properties,parent,element)
    -- Update the table style
    local style = element.style
    style.padding = 0
    style.horizontally_stretchable = true
    style.vertical_align = 'center'
    style.cell_padding = 0

    -- Change the stored name back to the actual name
    properties.name = element.parent.name

    return element
end)