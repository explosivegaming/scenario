--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui

Gui.require_concept 'frame' --- @dep gui.concept.table

local right_align =
Gui.new_concept('alignment')

--[[-- A frame that acts as a header to a section of content
@element header
@tparam string tooltip the tooltip to show on the title
@usage-- Concept Structure
-- Root
--> [header] - the header frame
-->> header_caption - the lable with the title in it
-->> header_content - the area to contain butons
]]

Gui.new_concept('frame')
:save_as('header')
:new_property('tooltip')

-- Draw
:define_draw(function(properties,parent,element)
    -- Update the table style
    Gui.set_padding(element,2,2,4,4)
    element.style = 'subheader_frame'
    element.caption = nil

    local style = element.style
    style.horizontally_stretchable = true
    style.use_header_filler = false

    -- Add the caption to the frame
    element.add{
        type = 'label',
        name = 'header_caption',
        caption = properties.title,
        tooltip = properties.tooltip
    }

    -- Add the right align area
    local align = right_align:draw(element,'header_content')

    return align
end)