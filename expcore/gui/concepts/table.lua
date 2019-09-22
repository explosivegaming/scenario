--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- An invisible container that lays out children in a specific number of columns. Column width is given by the largest element contained in that row.
@element table

@tparam ?number|function column_count the column count of the table or a function that returns the count being given then parent element
@tparam boolean vertical_lines when true vertical lines will be drawn on the table
@tparam boolean horizontal_lines when true horizontal lines will be drawn on the table
@tparam boolean header_lines when true horizontal lines will be drawn under the first row
@tparam boolean vertical_centering when true element will be vertically centered with in the table

@usage-- Making a basic table, contains 25 labels
local basic_table =
Gui.new_concept('table')
:set_column_count(5)
:define_draw(function(properties,parent,element)
    for i = 1,25 do
        element.add{
            type = 'lable',
            caption = i
        }
    end
end)

]]

Gui.new_concept()
:save_as('table')

-- Properties
:new_property('column_count')
:new_property('vertical_lines')
:new_property('horizontal_lines')
:new_property('header_lines')
:new_property('vertical_centering')

-- Draw
:define_draw(function(properties,parent,element)
    local column_count = Gui.resolve_property(properties.column_count,parent)

    -- Draw a table
    element = parent.add{
        name = properties.name,
        type = 'table',
        column_count = column_count,
        draw_vertical_lines = properties.vertical_lines,
        draw_horizontal_lines = properties.horizontal_lines,
        draw_horizontal_line_after_headers = properties.header_lines,
        vertical_centering = properties.vertical_centering
    }

    return element
end)