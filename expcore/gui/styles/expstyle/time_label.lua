--[[-- Core Module - ExpStyle
    @module ExpStyle
]]

local Gui = require 'expcore.gui' -- @dep expcore.gui
local format_time = ext_require('expcore.common','format_time') --- @dep expcore.common

--- Converts a tick into string format with workds and symbols
local function get_format(properties,time)
    local caption, tooltip

    -- Check if a custom format is wanted
    if properties.time_format then
        -- Get the caption
        local format = table.deep_copy(properties.time_format)
        caption = format_time(time,format)

        -- Get the tooltip, always long format
        format.long = true
        tooltip = format_time(time,format)

    else
        -- Get the caption
        caption = format_time(time,{
            hours = properties.use_hours,
            minutes = true,
            seconds = true
        })

        -- Get the tooltip, same as the caption but long format
        tooltip = format_time(time,{
            hours = properties.use_hours,
            minutes = true,
            seconds = true,
            long = true
        })

    end

    return caption, tooltip
end

--[[-- A label that show time in a nice, user friendly way
@element time_label
@tparam number time the time to display in tick
@usage-- Concept Structure
-- Root
--> [time_label] - the label with the time
local time_label =
Gui.new_concept('time_label')
:set_use_hours(true)
:set_time(game.tick)

time_label:update_time(element,game.tick)
]]

local time_label =
Gui.new_concept()
:save_as('time_label')

-- Properties
:new_property('time')
:new_property('use_hours',nil,false)
:new_property('time_format')

-- Draw
:define_draw(function(properties,parent,element,time)
    -- Get the caption and tooltip
    local caption, tooltip = get_format(properties,time or properties.time)

    -- Draw a label
    element = parent.add{
        name = properties.name,
        type = 'label',
        caption = caption,
        tooltip = tooltip
    }

    return element
end)

--[[-- Updates the time that is on a label
@tparam LuaGuiElement element the label that you want to update
@tparam number time the number of tick you want it to show
@usage-- Update the time to show game time
time_label:update_time(element,game.time)
]]
function time_label:update_time(element,time)
    local caption, tooltip = get_format(self.properties,time)
    element.caption = caption
    element.tooltip = tooltip
end