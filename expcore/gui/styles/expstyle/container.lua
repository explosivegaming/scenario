--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' --- @dep expcore.gui

Gui.require_concept 'frame' --- @dep gui.concept.frame

--[[-- A container frame that can be used to add a boader around your content
@see frame
@element container
@usage-- Concept Structure
-- Root
--> [container] - the outer frame
-->> container - the content area
Gui.new_concept('container')
]]

Gui.new_concept('frame')
:save_as('container')
:define_draw(function(properties,parent,element)
    -- Update the outter frame padding
    element.style.padding = 2

    -- Add the inner frame
    element = element.add{
        name = 'container',
        type = 'frame',
        direction = properties.direction,
        style = 'window_content_frame_packed'
    }

    -- Update the inner frame padding
    element.style.padding = 0

    return element
end)