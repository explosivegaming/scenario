--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' -- @dep expcore.gui

Gui.require_concept 'frame' -- @dep gui.concept.table

local right_align =
Gui.new_concept('alignment')

--[[-- A frame that acts as a footer to a section of content
@see Gui.frame
@element footer
@tparam string tooltip the tooltip to show on the title
@usage-- Concept Structure
-- Root
--> [footer] - the footer frame
-->> footer_caption - the lable with the title in it
-->> footer_content - the area to contain butons
Gui.new_concept('footer')
:set_title('Example Footer')
]]

Gui.new_concept('frame')
:save_as('footer')
:new_property('tooltip')

-- Draw
:define_draw(function(properties,parent,element)
    -- Update the table style
    Gui.set_padding(element,2,2,4,4)
    element.style = 'subfooter_frame'
    element.caption = nil

    local style = element.style
    style.horizontally_stretchable = true
    style.use_header_filler = false

    -- Add the caption to the frame
    element.add{
        type = 'label',
        name = 'footer_caption',
        caption = properties.title,
        tooltip = properties.tooltip
    }

    -- Add the right align area
    local align = right_align:draw(element,'footer_content')

    return align
end)