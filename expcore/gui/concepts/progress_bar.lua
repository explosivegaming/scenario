--[[-- Core Module - Gui
    @module Gui
    @alias Gui
]]

local Gui = require 'expcore.gui.core'

--[[-- Indicate progress by displaying a partially filled bar.
@element progress_bar

@param on_completion fired when increment reaches the maxium value set by set_maximum

@tparam ?string|Concepts.LocalisedString tooltip the tooltip that will show for this element
@tparam number maximum the maxium amount an instance can be increased, default 100
@tparam boolean delay_completion when true the progress will be completed untill after the maximum rather than at the maximum
@tparam boolean inverted although this will NOT effect how you use the functions it will make the element start full and reduce as you call increase, note issues with 0 detections

@usage-- Making a basic progress bar, will increase when pressed then will reset when full
local basic_progress_bar =
Gui.new_concept('progress_bar')
:set_tooltip('Basic progress bar')
:set_maximum(5)
:new_event('on_click',defines.events.on_gui_click)
:on_click(function(event)
    event.concept:increment(event.element)
end)
:set_delay_completion(true)
:on_completion(function(event)
    event.concept:reset(event.element)
end)

]]

local progress_bar =
Gui.new_concept()
:save_as('progress_bar')

-- Events
:new_event('on_completion')

-- Properties
:new_property('tooltip')
:new_property('maximum',nil,100)
:new_property('delay_completion',nil,false)
:new_property('inverted',nil,false)

-- Draw
:define_draw(function(properties,parent,element)
    -- Draw a progress bar
    element = parent.add{
        name = properties.name,
        tooltip = properties.tooltip,
        type = 'progressbar',
        value = properties.inverted and 1 or 0
    }

    return element
end)

--- Progress Bars.
-- functions used with progress bars
-- @section progress_bars

-- logic for changing the value of a progress bar
local function raw_update(concept,element,amount)
    local old_value = element.value
    local new_value = old_value + amount
    element.value = new_value

    local check_value = concept.properties.delay_completion and old_value or new_value
    if amount < 0 and check_value <= 0 or amount > 0 and check_value >= 1 then
        concept:raise_event('on_completion',{
            element = element
        })
    else
        return new_value

    end

end

--[[-- Will increase the progress of a progress bar based on this concept, if the concept has an instance store then element acts as the category, if you have a combined store it will NOT update all instances
@tparam ?LuaGuiElement|string element either the element that is changed or the category that is being changed (only if an instance store is defined)
@tparam[opt=1] number amount the amount that will bar will increase, note that this amount must be less than the max
@treturn ?number|nil the new value of the element, use this to sync a data store, if the return is nil then either a instance store was used or the new value may have changed
@usage-- Incrementing progress bar with no instance store
local new_value = progress_bar:increment(element)
@usage-- Incrementing progress bar with an instance store
progress_bar:increment(category)
]]
function progress_bar:increment(element,amount)
    local properties = self.properties
    local inverted = properties.inverted
    local maximum = properties.maximum
    amount = amount and amount/maximum or 1/maximum
    amount = inverted and -amount or amount

    if self.instance_store and not self.sync_instance then
        self.update_instances(element,function(next_element)
            raw_update(self,next_element,amount)
        end)

    else
        return raw_update(self,element,amount)

    end
end

--[[-- Will decrease the progress of a progress bar based on this concept, if the concept has an instance store then element acts as the category, if you have a combined store it will NOT update all instances
@tparam ?LuaGuiElement|string element either the element that is changed or the category that is being changed (only if an instance store is defined)
@tparam[opt=1] number amount the amount that will bar will decrease, note that this amount must be less than the max
@treturn number the new value of the element, use this to sync a data store, if the return is nil then either a instance store was used or the new value may have changed
@usage-- Decrementing progress bar with no instance store
local new_value = progress_bar:decrement(element)
@usage-- Decrementing progress bar with an instance store
progress_bar:decrement(category)
]]
function progress_bar:decrement(element,amount)
    self:increment(element,-amount)
end

--[[-- Resets the progress back to 0% for this element, if the concept has an instance store then element acts as the category, if you have a combined store it will NOT update all instances
@tparam ?LuaGuiElement|string element either the element that is changed or the category that is being changed (only if an instance store is defined)
@treturn ?number|nil the new value of the element, use this to sync a data store, if the return is nil then either a instance store was used or the new value may have changed
@usage-- Reseting a progress bar with no instance store
local new_value = progress_bar:reset(element)
@usage-- Reseting a progress bar with an instance store
progress_bar:reset(category)
]]
function progress_bar:reset(element)
    local new_value = self.properties.inverted and 1 or 0
    if self.instacne_store and not self.sync_instance then
        self.update_instances(element,function(next_element)
            next_element.value = new_value
        end)

    else
        element.value = new_value
        return new_value

    end
end

--[[-- Increment any progress bar by the given percentage
@tparam LuaGuiElement element the progress bar that you want to update
@tparam[opt=0.01] number amount the percentage that you want to increment the progress bar by
@treturn boolean true if the bar is now full
@usage-- Increment any progress bar by 10%
Gui.increment_progress_bar(element,0.1)
]]
function Gui.increment_progress_bar(element,amount)
    amount = amount or 0.01
    element.value = element.value + amount
    return element.value >= 1
end

--[[-- Decrement any progress bar by the given percentage
@tparam LuaGuiElement element the progress bar that you want to update
@tparam[opt=0.01] number amount the percentage that you want to decrement the progress bar by
@treturn boolean true if the bar is now empty
@usage-- Decrement any progress bar by 10%
Gui.decrement_progress_bar(element,0.1)
]]
function Gui.decrement_progress_bar(element,amount)
    amount = amount or 0.01
    element.value = element.value - amount
    return element.value <= 0
end