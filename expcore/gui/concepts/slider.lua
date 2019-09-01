--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- The basic slider element
@element slider
@param on_value_changed fired when the value of the slider is changed
@tparam number value_step the minimum amount by which the value of the slider can be changed
@tparam ?number|function default the default value of the slider or a function which returns the default value
@tparam boolean discrete_slider makes this slider a discrete slider, this means that the slider button will stop at the same interval as the values do
@tparam ?number|function range accepts two params the minimum and the maximum for this slider, or a single function to return both
@usage-- Making a basic slider
local basic_slider =
Gui.clone_concept('slider','basic_slider')
:set_range(1,10)
:on_value_changed(function(event)
    event.player.print('Basic slider is now: '..event.element.slider_value)
end)
@usage-- Making a discrete_slider
local discrete_slider =
Gui.clone_concept('slider','discrete_slider')
:set_range(1,10)
:set_value_step(1)
:set_discrete_slider(true)
:on_value_changed(function(event)
    event.player.print('Interval slider is now: '..event.element.slider_value)
end)
]]
Gui.new_concept('slider')
:new_event('on_value_changed',defines.events.on_gui_value_changed)
:new_property('value_step')
:new_property('default')
:new_property('discrete_slider',false)
:new_property('range',nil,function(properties,minimum,maximum)
    if type(minimum) == 'function' then
        properties.range = minimum
    else
        properties.minimum = minimum
        properties.maximum = maximum
    end
end)
:define_draw(function(properties,parent,element)
    local default = properties.default
    local value = type(default) == 'number' and default
    local value_step = properties.value_step

    element = parent.add{
        name = properties.name,
        type = 'slider',
        caption = properties.caption,
        minimum_value = properties.minimum,
        maximum_value = properties.maximum,
        discrete_slider = properties.discrete_slider,
        discrete_values = value_step ~= nil,
        value_step = value_step,
        value = value
    }

    local min, max = Gui.resolve_property(properties.range,element)
    if min or max then
        min = min or element.get_slider_minimum()
        max = max or element.get_slider_maximum()
        element.set_slider_minimum_maximum(min,max)
    end

    default = Gui.resolve_property(default,element)
    if default and default ~= value then
        element.slider_value = default
    end

    return element
end)